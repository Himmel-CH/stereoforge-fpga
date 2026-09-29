# PYNQ开发板SSH连接问题排查与开发环境完整配置记录

> 本文档记录了从SSH连接失败到搭建完整PYNQ开发环境的全过程，包含所有问题排查步骤、解决方案和最终配置，可供他人参考和复现。

## 目录
- [问题背景](#问题背景)
- [问题排查过程](#问题排查过程)
- [根本原因分析](#根本原因分析)
- [解决方案详细步骤](#解决方案详细步骤)
- [SSH免密登录配置](#ssh免密登录配置)
- [VSCode开发环境搭建](#vscode开发环境搭建)
- [文件系统与工作流程](#文件系统与工作流程)
- [完整配置文件](#完整配置文件)
- [使用指南](#使用指南)
- [常见问题FAQ](#常见问题faq)

---

## 问题背景

### 初始状态
- **Windows电脑**：可以ping通192.168.2.99
- **PYNQ设备**：IP地址192.168.2.99，用户名xilinx
- **问题现象**：SSH连接总是失败，报错"无法建立连接"

### 错误信息
```bash
C:\Users\eziochen>ssh xilinx@192.168.2.99
kex_exchange_identification: read: Connection reset
Connection reset by 192.168.2.99 port 22
```

后续尝试显示：
```
kex_exchange_identification: read: Software caused connection abort
banner exchange: Connection to 192.168.2.99 port 22: Software caused connection abort
```

---

## 问题排查过程

### 第一步：网络层验证

**测试ping连通性：**
```bash
ping -n 4 192.168.2.99
```

**结果：**
```
192.168.2.99 的 Ping 统计信息:
    数据包: 已发送 = 4，已接收 = 4，丢失 = 0 (0% 丢失)，
往返行程的估计时间(以毫秒为单位):
    最短 = 0ms，最长 = 1ms，平均 = 0ms
```

✅ **结论：网络层正常，延迟极低**

### 第二步：TCP端口检测

**使用PowerShell测试SSH端口：**
```powershell
Test-NetConnection -ComputerName 192.168.2.99 -Port 22
```

**结果：**
```
ComputerName     : 192.168.2.99
RemoteAddress    : 192.168.2.99
RemotePort       : 22
InterfaceAlias   : 以太网
SourceAddress    : 192.168.2.1
TcpTestSucceeded : True
```

✅ **结论：SSH端口22开放，TCP连接正常**

### 第三步：SSH详细调试

**执行详细调试：**
```bash
ssh -v 192.168.2.99
```

**关键输出：**
```
debug1: OpenSSH_10.2p1, OpenSSL 3.5.5 27 Jan 2026
debug1: Connecting to 192.168.2.99 [192.168.2.99] port 22.
debug1: Connection established.
debug1: Local version string SSH-2.0-OpenSSH_10.2
kex_exchange_identification: read: Software caused connection abort
banner exchange: Connection to 192.168.2.99 port 22: Software caused connection abort
```

⚠️ **关键发现：**
- TCP连接成功建立
- 客户端发送版本标识后，服务器立即断开连接
- 问题发生在SSH密钥交换（KEX）阶段之前

### 第四步：通过串口访问PYNQ设备

由于SSH无法连接，使用UART串口直接登录PYNQ设备进行诊断。

**检查SSH服务状态：**
```bash
xilinx@pynq:~$ ps aux | grep sshd
root       547  0.0  1.2  11180  6272 ?        Ss   21:17   0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
```

**检查SSH端口监听：**
```bash
xilinx@pynq:~$ netstat -tlnp | grep :22
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp6       0      0 :::22                   :::*                    LISTEN      -
```

**检查SSH服务状态：**
```bash
xilinx@pynq:~$ systemctl status sshd
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2025-05-03 21:17:24 UTC; 7min ago
   Main PID: 547 (sshd)
```

✅ **结论：SSH服务运行正常**

### 第五步：查看SSH服务器日志

**查看完整的连接失败日志：**
```bash
xilinx@pynq:~$ sudo journalctl -u ssh --no-pager | grep "Unable to negotiate"
```

**关键输出：**
```
May 03 21:21:00 pynq sshd[1096]: Unable to negotiate with 192.168.2.1 port 61424: no matching key exchange method found. Their offer: diffie-hellman-group1-sha1,ext-info-c,kex-strict-c-v00@openssh.com [preauth]
```

🎯 **问题找到了！**

---

## 根本原因分析

### SSH版本信息

**客户端（Windows）：**
```
OpenSSH_10.2p1, OpenSSL 3.5.5 27 Jan 2026
```

**服务器（PYNQ）：**
```
OpenSSH_8.9p1 Ubuntu-3, OpenSSL 3.0.2 15 Mar 2022
```

### 加密算法不匹配

**问题本质：**
1. Windows客户端配置了只使用旧的加密算法（`diffie-hellman-group1-sha1`）
2. PYNQ的OpenSSH 8.9默认已禁用这些不安全的旧算法
3. 双方无法协商出共同支持的密钥交换算法
4. 服务器在版本交换后立即断开连接

**为什么客户端只发送旧算法？**
- 检查发现客户端的SSH配置文件已经配置了旧算法，可能是为了兼容其他旧设备

---

## 解决方案详细步骤

### 方案概述

由于客户端已配置为使用旧算法（可能是为了其他设备），最简单的解决方案是在**PYNQ服务器端启用对旧算法的支持**。

### 步骤1：通过串口连接PYNQ

使用UART串口线连接PYNQ设备，登录后执行后续操作。

### 步骤2：备份SSH配置

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
```

### 步骤3：修改SSH服务器配置

**编辑配置文件：**
```bash
sudo nano /etc/ssh/sshd_config
```

**在文件末尾添加以下内容：**
```
KexAlgorithms +diffie-hellman-group1-sha1,diffie-hellman-group14-sha1
HostKeyAlgorithms +ssh-rsa
PubkeyAcceptedAlgorithms +ssh-rsa
Ciphers +aes128-cbc,aes256-cbc,3des-cbc
MACs +hmac-sha1,hmac-md5
```

**配置说明：**
- `KexAlgorithms`: 启用旧的密钥交换算法
- `HostKeyAlgorithms`: 启用ssh-rsa主机密钥
- `PubkeyAcceptedAlgorithms`: 接受ssh-rsa公钥认证
- `Ciphers`: 启用旧的加密算法
- `MACs`: 启用旧的消息认证码算法
- `+` 前缀表示在默认列表基础上**添加**这些算法，而不是替换


**保存文件：**
- 按 `Ctrl+O` 保存
- 按 `Enter` 确认文件名
- 按 `Ctrl+X` 退出

### 步骤4：创建SSH运行目录

```bash
sudo mkdir -p /run/sshd
```

**说明：** OpenSSH需要这个目录用于特权分离

### 步骤5：测试配置文件

```bash
sudo sshd -t
```

**期望输出：** 无输出表示配置正确

**如果有错误：**
- 检查算法名称拼写（连字符 vs 下划线）
- 检查配置文件语法

### 步骤6：重启SSH服务

```bash
sudo systemctl restart ssh
```

**验证服务状态：**
```bash
sudo systemctl status ssh
```

**期望输出：**
```
● ssh.service - OpenBSD Secure Shell server
     Active: active (running)
```

### 步骤7：从Windows测试连接

```bash
ssh xilinx@192.168.2.99
```

**期望输出：**
```
xilinx@192.168.2.99's password:
```

**重要提示：** 输入密码时屏幕**不会显示任何字符**（包括星号），这是SSH的正常安全特性。直接输入密码后按Enter即可。

**成功登录后显示：**
```
Welcome to PYNQ Linux, based on Ubuntu 22.04 (GNU/Linux 6.6.10-xilinx-v2024.1-g3c0eca68c652 armv7l)

Last login: Sat May  3 21:17:23 2025
xilinx@pynq:~$
```

✅ **SSH连接成功！**

---

## SSH免密登录配置

为了避免每次输入密码，配置SSH密钥认证。

### 步骤1：在Windows生成SSH密钥对

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -C "eziochen@windows"
```

**输出：**
```
Generating public/private rsa key pair.
Your identification has been saved in /c/Users/eziochen/.ssh/id_rsa
Your public key has been saved in /c/Users/eziochen/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:KgLZABmrNL593g5QTeWwlnHBg5jR6CZ1gJZa68lT4jM eziochen@windows
```

**生成的文件：**
- `~/.ssh/id_rsa` - 私钥（保密，不要分享）
- `~/.ssh/id_rsa.pub` - 公钥（可以分享）

### 步骤2：查看公钥内容

```bash
cat ~/.ssh/id_rsa.pub
```

**示例输出：**
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC...完整的公钥字符串... eziochen@windows
```

### 步骤3：在PYNQ设备上配置（通过串口）

**创建.ssh目录和authorized_keys文件：**
```bash
# 确保在home目录
cd ~

# 创建.ssh目录
mkdir -p .ssh

# 创建authorized_keys文件并添加公钥（将下面的公钥替换成你的）
cat > .ssh/authorized_keys << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw3ReTES9vVw1SfvAYOI8mc2hDXQ2X9Y1uLunppAnqhFGp+ww//zkVJ+nlyGDv7iQkkoRRIWLB8v/7PAju+9KKloHInJRsfYwHeWEn1LhDTWAfetXIUxI5/o/1vFCZxo++ITLNI9xudBS0wO+3CCU66McqUHaI9CPQbyi/9seQbHFuJkoR8QoyVuVIlAb3rL18vphBcRFy7D5meBevV0Wl3VI7hZ0OrMSuaKyBHmg6v8/hrrsUNbBnhYgaQlZpEnRkKwNTgMegnv5IcyZsZWG6hkrA2sZbbl2FPho1RWoAcAKKUY+qm1PqllpDtav/jx82FTvxE+H2aRKkmA+VGnvH4C7VWEcu4aztYgKmmZt11iu9OiE4jIYCmmBJpm29g9g+b5UfzDU2eKdRWTgW9QlNzYu1/8E3hjkNZLpoM1W1+5gJ4bL6JyuY7ApJXuIhKhQ6EkFT4/0NTKbTn0Hs9sytYQZA6HGxdjIJa4w8jINZYcjLH9XtEDLoKsKyIB3eRhaYnFiaSFNwuTnOCVwvV7ADDDbVO8Ag99C/8sm6Io8yiD3pxxE13NECxLTRrn+Lp4dk8s4wj6sK/KXK5v4XbX0YATmMMD9a0NlqEpURnQTWj1J+Uv9uworQgXaZWRO1zX1Gl8tm4JdOpQHcgB3FAURS42TilQvw6AASvYbWos5O2w== eziochen@windows
EOF

# 设置正确的权限（非常重要！）
chmod 700 .ssh
chmod 600 .ssh/authorized_keys

# 验证配置
ls -la .ssh/
cat .ssh/authorized_keys
```

⚠️ **权限设置至关重要：**
- `.ssh/` 目录必须是 `700` (drwx------)
- `authorized_keys` 文件必须是 `600` (-rw-------)
- 如果权限不正确，SSH会拒绝使用密钥认证

### 步骤4：测试免密登录

从Windows测试：
```bash
ssh xilinx@192.168.2.99
```

**期望结果：** 直接登录，不需要输入密码

**如果仍然要求输入密码：**
1. 检查PYNQ上的文件权限
2. 检查公钥是否正确复制
3. 查看SSH日志：`sudo tail -f /var/log/auth.log`

✅ **免密登录配置完成！**

---

## VSCode开发环境搭建

### 为什么不能使用VSCode Remote SSH？

**原因：**
- PYNQ设备是 **armv7l架构**（32位ARM）
- VSCode Remote SSH只支持：
  - x64 (AMD64)
  - ARM64 (aarch64)
  - **不支持32位ARM (armv7l)**

**解决方案：**
使用"本地编辑 + SSH上传运行"的工作流程

### 项目目录结构

```
C:\Users\eziochen\Desktop\fpga_project\python_project\
├── .vscode\
│   └── tasks.json              # VSCode任务配置
├── .gitignore                  # Git忽略文件
├── README.md                   # 项目说明
├── test.py                     # 示例Python文件
├── download_from_pynq.bat      # 从PYNQ下载文件的脚本
└── PYNQ开发环境完整配置记录.md  # 本文档
```

### 创建项目目录

```bash
mkdir -p ~/Desktop/fpga_project/python_project
cd ~/Desktop/fpga_project/python_project
```

### VSCode任务配置

创建文件：`.vscode/tasks.json`

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "上传并运行到PYNQ",
            "type": "shell",
            "command": "scp ${file} xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/ && ssh xilinx@192.168.2.99 'cd /home/xilinx/jupyter_notebooks && python3 ${fileBasename}'",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "仅上传到PYNQ",
            "type": "shell",
            "command": "scp ${file} xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/",
            "presentation": {
                "reveal": "always"
            },
            "problemMatcher": []
        },
        {
            "label": "SSH连接到PYNQ",
            "type": "shell",
            "command": "ssh xilinx@192.168.2.99",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "从PYNQ下载所有文件",
            "type": "shell",
            "command": "scp -r xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/* .",
            "presentation": {
                "reveal": "always"
            },
            "problemMatcher": []
        },
        {
            "label": "从PYNQ下载当前文件",
            "type": "shell",
            "command": "scp xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/${fileBasename} ${file}",
            "presentation": {
                "reveal": "always"
            },
            "problemMatcher": []
        }
    ]
}
```

**任务说明：**
1. **上传并运行到PYNQ** - 默认任务（Ctrl+Shift+B），上传当前文件到PYNQ并执行
2. **仅上传到PYNQ** - 只上传文件，不运行
3. **SSH连接到PYNQ** - 打开SSH终端
4. **从PYNQ下载所有文件** - 将jupyter_notebooks目录的所有文件下载到本地
5. **从PYNQ下载当前文件** - 只下载当前打开的文件

### Git配置文件

创建文件：`.gitignore`

```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
*.egg-info/
dist/
build/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Project specific
*.log
```

### 下载脚本

创建文件：`download_from_pynq.bat`

```batch
@echo off
REM 从PYNQ下载jupyter_notebooks目录中的所有文件到本地
scp -r xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/* "%~dp0"
echo 文件已下载到本地
pause
```

### 测试项目

创建文件：`test.py`

```python
#!/usr/bin/env python3
# 测试脚本 - 在PYNQ板子上运行

print("=" * 50)
print("Hello from PYNQ Board!")
print("=" * 50)

import sys
import platform

print(f"\nPython版本: {sys.version}")
print(f"平台: {platform.platform()}")
print(f"处理器: {platform.processor()}")
print(f"架构: {platform.machine()}")

# 测试简单计算
numbers = [1, 2, 3, 4, 5]
result = sum(numbers)
print(f"\n计算测试: sum({numbers}) = {result}")

print("\n测试完成!")
```

### 测试工作流程

1. **在VSCode中打开项目目录**
   ```bash
   code C:\Users\eziochen\Desktop\fpga_project\python_project
   ```

2. **打开test.py文件**

3. **按 Ctrl+Shift+B 运行**

**期望输出：**
```
==================================================
Hello from PYNQ Board!
==================================================

Python版本: 3.10.4 (main, Apr  2 2022, 09:04:19) [GCC 11.2.0]
平台: Linux-6.6.10-xilinx-v2024.1-g3c0eca68c652-armv7l-with-glibc2.35
处理器: armv7l
架构: armv7l

计算测试: sum([1, 2, 3, 4, 5]) = 15

测试完成!
```

✅ **VSCode开发环境配置完成！**

---

## 文件系统与工作流程

### PYNQ文件系统结构

**用户主目录：** `/home/xilinx/`
```
/home/xilinx/
├── .ssh/                    # SSH配置和密钥
├── .bashrc                  # Bash配置
├── jupyter_notebooks/       # Jupyter工作目录 ⭐
│   ├── base/               # PYNQ官方示例
│   ├── common/             # PYNQ公共示例
│   ├── getting_started/    # 入门教程
│   ├── logictools/         # 逻辑工具示例
│   ├── pynq_peripherals/   # 外设示例
│   └── test.py             # 用户上传的文件
├── pynq -> /usr/local/...  # PYNQ库符号链接
└── REVISION                # 版本信息
```

### Jupyter Notebook访问

**访问地址：**
- `http://pynq:9090/tree`
- `http://192.168.2.99:9090/tree`

**显示内容：**
- Jupyter **只显示** `/home/xilinx/jupyter_notebooks/` 目录
- 不显示 `/home/xilinx/` 下的其他文件（如.ssh、.bashrc等）
- 这是PYNQ的设计，将用户文件和系统文件分离

### 文件流向关系

```
┌─────────────────────────────────┐
│   Windows本地开发环境           │
│   C:\Users\eziochen\Desktop\    │
│   fpga_project\python_project\  │
│                                 │
│   ├── test.py                   │
│   ├── script.py                 │
│   └── mycode.py                 │
│                                 │
│   ✅ Git版本控制                │
│   ✅ VSCode编辑                 │
└─────────────────────────────────┘
         │                 ▲
         │ scp上传         │ scp下载
         │ Ctrl+Shift+B    │ download_from_pynq.bat
         ▼                 │
┌─────────────────────────────────┐
│   PYNQ设备                      │
│   /home/xilinx/                 │
│   jupyter_notebooks/            │
│                                 │
│   ├── test.py      ◄─┐          │
│   ├── script.py      │          │
│   └── mycode.py      │          │
│   ├── base/          │          │
│   └── common/        │          │
│                      │          │
│   ✅ Python运行       │          │
│   ✅ Jupyter访问      │          │
└──────────────────────┼──────────┘
                       │
                       │
              ┌────────┴─────────┐
              │  Jupyter Web界面  │
              │  http://pynq:9090│
              │                  │
              │  可以看到所有     │
              │  .py和.ipynb文件  │
              └──────────────────┘
```

### 工作流程说明

#### 场景1：VSCode主力开发

**步骤：**
1. 在VSCode中编辑Python代码（本地）
2. 按 `Ctrl+Shift+B` 上传并运行
3. 代码在PYNQ板子上执行
4. 结果显示在VSCode终端
5. 使用Git提交代码

**特点：**
- 代码保存在本地
- 有Git版本控制
- 运行在PYNQ板子上
- 开发体验类似本地开发

#### 场景2：Jupyter交互式开发

**步骤：**
1. 浏览器访问 `http://pynq:9090`
2. 在Jupyter中创建/编辑`.ipynb`或`.py`文件
3. 交互式运行和测试
4. 运行 `download_from_pynq.bat` 下载到本地
5. 使用Git提交代码

**特点：**
- 交互式开发体验
- 可以看到中间结果
- 适合探索和实验
- 需要手动下载才能保存到本地

#### 场景3：混合开发

**步骤：**
1. 在Jupyter中做交互式探索
2. 在VSCode中编写正式代码
3. 两边的文件都在 `/home/xilinx/jupyter_notebooks/`
4. 定期下载同步到本地
5. 使用Git管理版本

**特点：**
- 结合两种开发方式的优点
- Jupyter适合快速实验
- VSCode适合正式开发
- 文件可以在两边互相访问

### 代码执行位置

⚠️ **重要说明：**
- 代码**完全在PYNQ板子上运行**
- 运行速度**取决于PYNQ板子的ARM处理器性能**
- **与Windows电脑的性能无关**
- Windows电脑只负责编辑代码和显示结果

### Git版本控制

**推荐做法：**
1. 在本地项目目录初始化Git仓库
2. 定期提交代码到Git
3. 推送到GitHub/GitLab等远程仓库
4. PYNQ上的文件是运行时的副本，不需要版本控制

**初始化Git：**
```bash
cd C:\Users\eziochen\Desktop\fpga_project\python_project
git init
git add .
git commit -m "Initial commit: PYNQ development environment"
git remote add origin <your-repo-url>
git push -u origin main
```

---

## 完整配置文件

### PYNQ SSH服务器配置

**文件位置：** `/etc/ssh/sshd_config`

**添加的配置（文件末尾）：**
```
KexAlgorithms +diffie-hellman-group1-sha1,diffie-hellman-group14-sha1
HostKeyAlgorithms +ssh-rsa
PubkeyAcceptedAlgorithms +ssh-rsa
Ciphers +aes128-cbc,aes256-cbc,3des-cbc
MACs +hmac-sha1,hmac-md5
```

### Windows客户端SSH配置

**文件位置：** `C:\Users\eziochen\.ssh\config`

**配置内容：**
```
Host 192.168.2.99
  HostName 192.168.2.99
  User xilinx
  KexAlgorithms diffie-hellman-group1-sha1
  Ciphers aes128-cbc
  MACs hmac-sha1
  HostKeyAlgorithms +ssh-rsa
  PubkeyAcceptedAlgorithms +ssh-rsa
  RequiredRSASize 1024
  Compression no
  TCPKeepAlive yes
  ServerAliveInterval 0
```

### VSCode tasks.json（完整版）

**文件位置：** `C:\Users\eziochen\Desktop\fpga_project\python_project\.vscode\tasks.json`

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "上传并运行到PYNQ",
            "type": "shell",
            "command": "scp ${file} xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/ && ssh xilinx@192.168.2.99 'cd /home/xilinx/jupyter_notebooks && python3 ${fileBasename}'",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "仅上传到PYNQ",
            "type": "shell",
            "command": "scp ${file} xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/",
            "presentation": {
                "reveal": "always"
            },
            "problemMatcher": []
        },
        {
            "label": "SSH连接到PYNQ",
            "type": "shell",
            "command": "ssh xilinx@192.168.2.99",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "从PYNQ下载所有文件",
            "type": "shell",
            "command": "scp -r xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/* .",
            "presentation": {
                "reveal": "always"
            },
            "problemMatcher": []
        },
        {
            "label": "从PYNQ下载当前文件",
            "type": "shell",
            "command": "scp xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/${fileBasename} ${file}",
            "presentation": {
                "reveal": "always"
            },
            "problemMatcher": []
        }
    ]
}
```

### .gitignore（完整版）

**文件位置：** `C:\Users\eziochen\Desktop\fpga_project\python_project\.gitignore`

```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
*.egg-info/
dist/
build/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Project specific
*.log
```

### README.md

**文件位置：** `C:\Users\eziochen\Desktop\fpga_project\python_project\README.md`

```markdown
# PYNQ Python项目

这个项目用于在PYNQ板子上开发和运行Python代码。

## 使用方法

1. 在VSCode中打开此文件夹
2. 编辑Python代码
3. 按 `Ctrl+Shift+B` 上传并运行到PYNQ板子

## 可用任务

- **上传并运行到PYNQ** (Ctrl+Shift+B): 上传当前文件到PYNQ并执行
- **仅上传到PYNQ**: 只上传文件，不运行
- **SSH连接到PYNQ**: 打开SSH终端连接到板子
- **从PYNQ下载所有文件**: 下载jupyter_notebooks目录的所有文件
- **从PYNQ下载当前文件**: 只下载当前打开的文件

## PYNQ设备信息

- IP地址: 192.168.2.99
- 用户名: xilinx
- Python版本: 3.10.4
- 架构: armv7l
- Jupyter访问: http://pynq:9090

## Git使用

代码保存在本地，可以正常使用git进行版本控制：

\`\`\`bash
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-repo-url>
git push -u origin main
\`\`\`
```

---

## 使用指南

### 日常开发工作流程

#### 1. 启动开发环境

```bash
# 打开VSCode项目
code C:\Users\eziochen\Desktop\fpga_project\python_project
```

#### 2. 编写代码

在VSCode中创建或编辑`.py`文件，享受完整的IDE功能：
- 语法高亮
- 代码补全
- 错误提示
- Git集成

#### 3. 运行代码

**方法1：快捷键**
- 按 `Ctrl+Shift+B`

**方法2：命令面板**
1. 按 `Ctrl+Shift+P`
2. 输入 "Tasks: Run Build Task"
3. 选择 "上传并运行到PYNQ"

**方法3：菜单**
- Terminal → Run Build Task

#### 4. 查看结果

代码执行结果会显示在VSCode的终端窗口中。

#### 5. 在Jupyter中查看

1. 打开浏览器
2. 访问 `http://pynq:9090`
3. 可以看到刚刚上传的文件

#### 6. 版本控制

```bash
# 添加文件
git add mycode.py

# 提交
git commit -m "Add new feature"

# 推送到远程仓库
git push
```

### VSCode任务使用说明

#### 任务1：上传并运行到PYNQ（默认）

**触发方式：** `Ctrl+Shift+B`

**功能：**
- 将当前打开的文件上传到PYNQ的 `/home/xilinx/jupyter_notebooks/`
- 在PYNQ上执行该文件
- 显示执行结果

**适用场景：**
- 日常开发和测试
- 快速验证代码

#### 任务2：仅上传到PYNQ

**触发方式：** `Ctrl+Shift+P` → "Tasks: Run Task" → "仅上传到PYNQ"

**功能：**
- 只上传文件，不执行
- 文件保存在PYNQ上

**适用场景：**
- 批量上传多个文件
- 稍后在Jupyter中运行

#### 任务3：SSH连接到PYNQ

**触发方式：** `Ctrl+Shift+P` → "Tasks: Run Task" → "SSH连接到PYNQ"

**功能：**
- 打开SSH终端连接到PYNQ
- 可以执行任意Linux命令

**适用场景：**
- 调试和诊断
- 执行系统命令
- 安装Python包

#### 任务4：从PYNQ下载所有文件

**触发方式：** 
- `Ctrl+Shift+P` → "Tasks: Run Task" → "从PYNQ下载所有文件"
- 或双击 `download_from_pynq.bat`

**功能：**
- 下载 `/home/xilinx/jupyter_notebooks/` 的所有内容到本地项目目录
- 递归下载，包括子目录

**适用场景：**
- 在Jupyter中创建了新文件
- 备份PYNQ上的所有文件
- 同步最新的文件状态

#### 任务5：从PYNQ下载当前文件

**触发方式：** `Ctrl+Shift+P` → "Tasks: Run Task" → "从PYNQ下载当前文件"

**功能：**
- 只下载当前打开的文件
- 覆盖本地版本

**适用场景：**
- 在Jupyter中修改了某个文件
- 只需要更新单个文件

### 常用命令

#### SSH相关

```bash
# 连接到PYNQ
ssh xilinx@192.168.2.99

# 上传单个文件
scp myfile.py xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/

# 上传整个目录
scp -r mydir/ xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/

# 下载单个文件
scp xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/myfile.py .

# 下载整个目录
scp -r xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/ .
```

#### PYNQ上的命令（通过SSH）

```bash
# 查看Python版本
python3 --version

# 运行Python脚本
python3 /home/xilinx/jupyter_notebooks/myfile.py

# 列出文件
ls -la /home/xilinx/jupyter_notebooks/

# 查看文件内容
cat /home/xilinx/jupyter_notebooks/myfile.py

# 安装Python包
pip3 install numpy

# 查看系统信息
uname -a
free -h
df -h
```

---

## 常见问题FAQ

### Q1: SSH连接时输入密码看不到字符？

**A:** 这是SSH的正常安全特性，密码输入时**不会显示任何字符**（包括星号*）。

**解决方法：**
- 直接输入密码
- 输入完成后按 Enter
- 如果密码正确就能登录

### Q2: 为什么VSCode Remote SSH无法连接PYNQ？

**A:** PYNQ是32位ARM架构（armv7l），VSCode Remote SSH不支持。

**支持的架构：**
- ✅ x64 (AMD64)
- ✅ ARM64 (aarch64)
- ❌ ARM32 (armv7l) ← PYNQ是这个

**解决方案：**
使用本文档配置的"本地编辑 + SSH上传"方式

### Q3: 在Jupyter中创建的文件能在VSCode中看到吗？

**A:** 不能直接看到，需要手动下载。

**工作原理：**
- Jupyter创建的文件保存在PYNQ设备上
- 本地VSCode看不到远程文件
- 需要运行下载任务同步到本地

**下载方法：**
- 方法1：双击 `download_from_pynq.bat`
- 方法2：VSCode任务 "从PYNQ下载所有文件"

### Q4: 代码在哪里运行？速度取决于什么？

**A:** 代码**完全在PYNQ板子上运行**。

**详细说明：**
- Windows电脑：负责编辑代码、显示结果
- PYNQ板子：负责执行代码
- 运行速度：取决于PYNQ的ARM处理器性能
- 与Windows电脑性能**无关**

### Q5: 如何查看PYNQ上有哪些文件？

**A:** 使用SSH连接或Jupyter Web界面。

**方法1：SSH**
```bash
ssh xilinx@192.168.2.99
ls -la /home/xilinx/jupyter_notebooks/
```

**方法2：Jupyter**
- 浏览器访问 `http://pynq:9090`
- 直接在Web界面查看文件列表

**方法3：VSCode任务**
- 使用 "SSH连接到PYNQ" 任务
- 在终端执行 `ls` 命令

### Q6: Git仓库应该在哪里创建？

**A:** 在本地Windows项目目录创建。

**推荐位置：**
```
C:\Users\eziochen\Desktop\fpga_project\python_project\
```

**初始化命令：**
```bash
cd C:\Users\eziochen\Desktop\fpga_project\python_project
git init
git add .
git commit -m "Initial commit"
```

**为什么不在PYNQ上创建Git仓库？**
- PYNQ上的文件是运行时的副本
- 可能会被覆盖或删除
- 不方便进行版本控制

### Q7: 如何在PYNQ上安装Python包？

**A:** 通过SSH连接后使用pip安装。

**步骤：**
```bash
# 连接到PYNQ
ssh xilinx@192.168.2.99

# 安装包
pip3 install package_name

# 或者使用sudo（如果需要）
sudo pip3 install package_name
```

**示例：**
```bash
pip3 install numpy pandas matplotlib
```

### Q8: 为什么文件上传到PYNQ后，Jupyter中看不到？

**A:** 检查文件是否上传到正确的目录。

**正确的上传目录：**
```
/home/xilinx/jupyter_notebooks/
```

**Jupyter只显示这个目录的内容**

**如果上传到了 `/home/xilinx/`：**
- Jupyter看不到
- 需要通过SSH移动文件：
```bash
ssh xilinx@192.168.2.99
mv /home/xilinx/myfile.py /home/xilinx/jupyter_notebooks/
```

### Q9: 如何备份PYNQ上的所有文件？

**A:** 使用下载任务或scp命令。

**方法1：批处理脚本**
```batch
# 双击运行
download_from_pynq.bat
```

**方法2：手动scp**
```bash
scp -r xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/ ./backup/
```

**方法3：VSCode任务**
- `Ctrl+Shift+P` → "从PYNQ下载所有文件"

### Q10: SSH连接突然断开怎么办？

**A:** 检查网络连接和SSH服务状态。

**诊断步骤：**
```bash
# 1. 测试网络
ping 192.168.2.99

# 2. 测试SSH端口
ssh -v xilinx@192.168.2.99

# 3. 通过串口检查SSH服务（如果网络无法连接）
systemctl status ssh
sudo systemctl restart ssh
```

### Q11: 如何修改PYNQ的IP地址？

**A:** 通过串口或SSH修改网络配置。

**Ubuntu 22.04 (Netplan)配置：**
```bash
# 编辑网络配置
sudo nano /etc/netplan/01-netcfg.yaml

# 修改后应用
sudo netplan apply
```

**示例配置：**
```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.2.99/24
      gateway4: 192.168.2.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

### Q12: 如何查看PYNQ的系统信息？

**A:** 通过SSH执行系统命令。

```bash
# 连接到PYNQ
ssh xilinx@192.168.2.99

# 查看系统版本
cat /etc/os-release

# 查看内核版本
uname -a

# 查看CPU信息
cat /proc/cpuinfo

# 查看内存使用
free -h

# 查看磁盘使用
df -h

# 查看Python版本
python3 --version

# 查看已安装的Python包
pip3 list
```

---

## 设备信息汇总

### PYNQ设备

- **型号**: PYNQ (Xilinx Zynq)
- **IP地址**: 192.168.2.99
- **用户名**: xilinx
- **架构**: armv7l (32位ARM)
- **操作系统**: Ubuntu 22.04 (PYNQ Linux)
- **内核版本**: 6.6.10-xilinx-v2024.1-g3c0eca68c652
- **Python版本**: 3.10.4
- **OpenSSH版本**: 8.9p1
- **内存**: 491 MB
- **存储**: 15 GB (SD卡)

### Windows客户端

- **操作系统**: Windows 11
- **OpenSSH版本**: 10.2p1
- **OpenSSL版本**: 3.5.5
- **项目目录**: C:\Users\eziochen\Desktop\fpga_project\python_project\

### 网络配置

- **PYNQ IP**: 192.168.2.99
- **Windows IP**: 192.168.2.1
- **网络延迟**: 0-1ms
- **SSH端口**: 22
- **Jupyter端口**: 9090

---

## 附录：问题排查检查清单

如果遇到连接问题，按照此清单逐项检查：

### 网络层检查

- [ ] 能ping通PYNQ设备
- [ ] 网络延迟正常（< 100ms）
- [ ] 防火墙允许SSH连接

### SSH服务检查（在PYNQ上）

```bash
# 通过串口执行
- [ ] SSH服务运行中: systemctl status ssh
- [ ] SSH端口监听: netstat -tlnp | grep :22
- [ ] /run/sshd目录存在: ls -d /run/sshd
- [ ] SSH配置正确: sudo sshd -t
```

### SSH客户端检查（在Windows上）

```bash
- [ ] SSH客户端已安装: ssh -V
- [ ] SSH配置文件存在: ls ~/.ssh/config
- [ ] 密钥文件存在: ls ~/.ssh/id_rsa
```

### 密钥认证检查（在PYNQ上）

```bash
# 通过串口执行
- [ ] .ssh目录存在: ls -la ~/.ssh/
- [ ] .ssh目录权限正确: ls -ld ~/.ssh/ (应该是700)
- [ ] authorized_keys存在: ls -la ~/.ssh/authorized_keys
- [ ] authorized_keys权限正确: ls -l ~/.ssh/authorized_keys (应该是600)
- [ ] authorized_keys内容正确: cat ~/.ssh/authorized_keys
```

### VSCode配置检查

```bash
- [ ] tasks.json存在: ls .vscode/tasks.json
- [ ] 项目目录正确
- [ ] Git已初始化（可选）
```

---

## 总结

通过本文档的配置，你已经成功搭建了一个完整的PYNQ开发环境：

✅ **SSH连接问题已解决**
- 诊断出加密算法不匹配的根本原因
- 在服务器端启用旧算法支持
- 连接稳定可靠

✅ **免密登录已配置**
- 生成SSH密钥对
- 配置公钥认证
- 无需每次输入密码

✅ **VSCode开发环境已搭建**
- 一键上传运行
- 完整的IDE功能
- Git版本控制

✅ **文件同步机制已建立**
- 上传：VSCode → PYNQ
- 下载：PYNQ → VSCode
- Jupyter Web访问

✅ **完整的工作流程**
- 本地编辑代码
- 远程运行代码
- 版本控制管理
- 双向文件同步

### 开发体验

现在你可以：
- 像本地开发一样编写Python代码
- 代码在PYNQ板子上运行
- 享受完整的VSCode功能
- 使用Git管理代码
- 在Jupyter中交互式开发
- 轻松在两种方式间切换

### 后续建议

1. **定期备份**：运行下载任务备份PYNQ上的文件
2. **版本控制**：养成频繁提交Git的习惯
3. **文档记录**：记录项目的特殊配置和依赖
4. **测试驱动**：编写测试用例验证代码
5. **持续学习**：探索PYNQ的更多功能

---

## 更新记录

- **2025-05-03**: 初始版本，完整记录SSH问题排查和开发环境搭建过程

---

## 许可证

本文档可自由使用、修改和分发。

---

**文档作者**: Claude (AI助手) & eziochen  
**创建日期**: 2025年5月3日  
**最后更新**: 2025年5月3日  
**文档版本**: 1.0
