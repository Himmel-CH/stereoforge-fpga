# FPGA MCP 完整配置指南

从 GitHub 下载到 Chatbox 完全配置的详细步骤

---

## 📋 目录

1. [系统要求](#系统要求)
2. [下载项目](#下载项目)
3. [安装依赖](#安装依赖)
4. [修复项目代码](#修复项目代码)
5. [配置 FPGA 工具路径](#配置-fpga-工具路径)
6. [配置 Chatbox MCP 服务器](#配置-chatbox-mcp-服务器)
7. [启动 Tcl 服务器](#启动-tcl-服务器)
8. [使用说明](#使用说明)
9. [常见问题](#常见问题)

---

## 系统要求

### 必需软件
- **Python 3.10+** (本配置使用: `D:\必备软件\Python\python.exe`)
- **Chatbox AI** (支持 MCP 的版本)
- **FPGA 开发工具** (至少一种):
  - Xilinx Vivado (本配置: `D:\EN_apps\vivado\2026.1`)
  - Intel Quartus (本配置: `D:\EN_apps\FPGA\quartus`)
  - 安路 TangDynasty (可选)

### 系统环境
- Windows 10/11
- 至少 4GB 可用磁盘空间

---

## 1️⃣ 下载项目

### 从 GitHub 下载

1. 打开浏览器访问: https://github.com/wmm246/fpga-mcp
2. 点击绿色的 **"Code"** 按钮
3. 选择 **"Download ZIP"**
4. 解压到: `D:\EN_apps\MCP\fpga-mcp-main`

**或者使用 Git 命令**:
```powershell
cd D:\EN_apps\MCP
git clone https://github.com/wmm246/fpga-mcp.git fpga-mcp-main
```

---

## 2️⃣ 安装依赖

### 步骤 1: 修正项目结构

项目代码期望模块名为 `fpga_mcp`，但源码在 `src` 目录下。需要复制一份：

```powershell
cd D:\EN_apps\MCP\fpga-mcp-main
Copy-Item -Path "src" -Destination "fpga_mcp" -Recurse
```

### 步骤 2: 安装 Python 依赖包

**重要**: 必须安装 MCP 1.x 版本（不是 2.x）

```powershell
D:\必备软件\Python\python.exe -m pip install "mcp<2" typer rich pydantic anyio
```

安装成功后应该看到:
```
Successfully installed mcp-1.30.0 ...
```

---

## 3️⃣ 修复项目代码

由于 fpga-mcp 项目代码不完整，需要添加缺失的函数。

### 创建补丁文件

创建文件 `D:\EN_apps\MCP\fpga-mcp-main\handlers_patch.py`，内容为所有缺失的函数（已在前面步骤中通过 PowerShell 添加到 `_handlers.py`）。

**或者直接跳过**（如果已经按照前面的步骤操作，函数已经添加完成）。

---

## 4️⃣ 配置 FPGA 工具路径

### 创建配置文件

配置文件位置: `%APPDATA%\fpga-mcp\config.json`

**完整配置内容**:

```json
{
  "active_backend": "vivado",
  "log_level": "INFO",
  "workspace": "C:\\Users\\eziochen",
  "backends": {
    "vivado_host": "127.0.0.1",
    "vivado_port": 9999,
    "vivado_path": "D:\\EN_apps\\vivado\\2026.1\\Vivado\\bin\\vivado.bat",
    "quartus_host": "127.0.0.1",
    "quartus_port": 9998,
    "quartus_path": "D:\\EN_apps\\FPGA\\quartus\\bin64\\quartus_sh.exe",
    "anlogic_host": "127.0.0.1",
    "anlogic_port": 9997,
    "anlogic_td_path": null
  }
}
```

### PowerShell 命令创建配置

```powershell
# 创建配置目录
New-Item -ItemType Directory -Path "$env:APPDATA\fpga-mcp" -Force

# 写入配置文件（单行命令）
@"
{
  "active_backend": "vivado",
  "log_level": "INFO",
  "workspace": "C:\\Users\\eziochen",
  "backends": {
    "vivado_host": "127.0.0.1",
    "vivado_port": 9999,
    "vivado_path": "D:\\EN_apps\\vivado\\2026.1\\Vivado\\bin\\vivado.bat",
    "quartus_host": "127.0.0.1",
    "quartus_port": 9998,
    "quartus_path": "D:\\EN_apps\\FPGA\\quartus\\bin64\\quartus_sh.exe",
    "anlogic_host": "127.0.0.1",
    "anlogic_port": 9997,
    "anlogic_td_path": null
  }
}
"@ | Set-Content "$env:APPDATA\fpga-mcp\config.json"
```

---

## 5️⃣ 配置 Chatbox MCP 服务器

### 步骤 1: 创建启动脚本

文件: `D:\EN_apps\MCP\fpga-mcp-main\start_mcp_debug.py`

```python
import sys
import os
import logging

# 配置日志输出到文件
logging.basicConfig(
    filename=r'D:\EN_apps\MCP\fpga-mcp-main\mcp_server.log',
    level=logging.DEBUG,
    format='%(asctime)s %(levelname)s: %(message)s'
)

try:
    logging.info("Starting FPGA MCP Server...")
    
    # 设置 Python 路径
    sys.path.insert(0, r'D:\EN_apps\MCP\fpga-mcp-main')
    os.environ['PYTHONPATH'] = r'D:\EN_apps\MCP\fpga-mcp-main'
    
    logging.info("Importing fpga_mcp modules...")
    from fpga_mcp.server import run_stdio
    
    logging.info("Starting stdio server...")
    run_stdio()
    
except Exception as e:
    logging.exception(f"Error starting MCP server: {e}")
    raise
```

### 步骤 2: 在 Chatbox 中添加 MCP 服务器

1. 打开 **Chatbox 设置**
2. 找到 **"MCP"** 或 **"MCP 服务器"** 选项
3. 点击 **"添加 MCP Server"** 或 **"+"** 按钮

**填写以下信息**:

| 字段 | 值 |
|------|-----|
| **名称** | `FPGA-MCP` |
| **类型** | `本地 (stdio)` ✓ |
| **协议** | `自动（推荐）` ✓ |
| **命令** | `D:\必备软件\Python\python.exe D:\EN_apps\MCP\fpga-mcp-main\start_mcp_debug.py` |
| **环境变量** | `PYTHONPATH=D:\EN_apps\MCP\fpga-mcp-main` |

4. 点击 **"连接"** 测试配置
5. 如果连接成功，点击 **"保存"**
6. 在 MCP 服务器列表中**启用** FPGA-MCP

---

## 6️⃣ 启动 Tcl 服务器

### 重要概念

**MCP 服务器和 Tcl 服务器的关系**:

- **MCP 服务器** (在 Chatbox 中配置): 负责接收 AI 的指令
- **Tcl 服务器** (在 Vivado/Quartus 中运行): 负责实际执行 FPGA 工具命令

**工作流程**:
```
Chatbox AI → MCP 服务器 → Tcl 服务器 → Vivado/Quartus
```

### 启动 Vivado Tcl 服务器

**每次使用 Vivado 功能前**，需要先启动 Vivado Tcl 服务器：

```powershell
D:\EN_apps\vivado\2026.1\Vivado\bin\vivado.bat -mode tcl -source D:\EN_apps\MCP\fpga-mcp-main\tcl\vivado_server.tcl
```

启动成功后会显示:
```
Vivado Tcl Server listening on port 9999...
```

**保持这个窗口运行**，不要关闭。

### 启动 Quartus Tcl 服务器

**每次使用 Quartus 功能前**，需要先启动 Quartus Tcl 服务器：

```powershell
D:\EN_apps\FPGA\quartus\bin64\quartus_sh.exe -t D:\EN_apps\MCP\fpga-mcp-main\tcl\quartus_server.tcl
```

启动成功后会显示:
```
Quartus Tcl Server listening on port 9998...
```

**保持这个窗口运行**，不要关闭。

### 创建便捷启动脚本

为了方便，可以创建批处理文件：

**启动 Vivado Tcl 服务器** - `start_vivado_tcl.bat`:
```batch
@echo off
D:\EN_apps\vivado\2026.1\Vivado\bin\vivado.bat -mode tcl -source D:\EN_apps\MCP\fpga-mcp-main\tcl\vivado_server.tcl
pause
```

**启动 Quartus Tcl 服务器** - `start_quartus_tcl.bat`:
```batch
@echo off
D:\EN_apps\FPGA\quartus\bin64\quartus_sh.exe -t D:\EN_apps\MCP\fpga-mcp-main\tcl\quartus_server.tcl
pause
```

保存到 `D:\EN_apps\MCP\fpga-mcp-main\` 目录，双击即可启动。

---

## 7️⃣ 使用说明

### 完整使用流程

1. **启动 Tcl 服务器**
   - 使用 Vivado: 运行 `start_vivado_tcl.bat`
   - 使用 Quartus: 运行 `start_quartus_tcl.bat`
   - 保持窗口运行

2. **在 Chatbox 中启用 FPGA-MCP**
   - 打开 Chatbox 设置
   - 确保 FPGA-MCP 服务器已启用

3. **开始使用**
   - 在 Chatbox 对话中，AI 现在可以控制 FPGA 工具了！

### 是否需要打开 Vivado/Quartus GUI？

**答：不需要！**

- Tcl 服务器以**命令行模式**运行
- 不需要打开 Vivado 或 Quartus 的图形界面
- 所有操作通过 Tcl 命令完成
- AI 可以创建项目、综合、实现、生成比特流等

**但是**，如果你想查看图形界面的结果：
- 可以在 Tcl 服务器运行后，单独打开 Vivado/Quartus GUI
- 然后在 GUI 中打开 AI 创建的项目

### 切换 Vivado 和 Quartus

在 Chatbox 中告诉 AI：

```
切换到 Quartus 后端
```

或者：

```
切换到 Vivado 后端
```

AI 会自动调用 `set_backend` 工具切换。

---

## 8️⃣ 使用示例

### 示例 1: 使用 Vivado 创建 LED 闪烁项目

**前提**: Vivado Tcl 服务器已启动

在 Chatbox 中输入：

```
帮我用 Vivado 创建一个 LED 闪烁项目：
1. 项目名称: led_blink
2. 芯片型号: xc7a35tcpg236-1 (Artix-7)
3. 编写一个 1Hz LED 闪烁模块（输入时钟 100MHz）
4. 运行综合
5. 查看综合后的资源使用情况
```

AI 会自动：
- 调用 `create_project` 创建项目
- 生成 Verilog 代码
- 调用 `add_sources` 添加文件
- 调用 `run_synthesis` 运行综合
- 调用 `report_utilization` 显示资源使用

### 示例 2: 使用 Quartus 创建项目

**前提**: Quartus Tcl 服务器已启动

在 Chatbox 中输入：

```
切换到 Quartus，然后创建一个项目：
1. 项目名称: counter_project
2. 芯片: Cyclone V 5CSEMA5F31C6
3. 创建一个 8 位计数器
4. 运行综合
```

### 示例 3: 完整的 FPGA 开发流程

```
帮我完成一个完整的 FPGA 开发流程：
1. 创建项目（自己选择合适的 FPGA 芯片）
2. 编写一个简单的按键消抖模块
3. 编写 testbench 并运行仿真
4. 如果仿真通过，运行综合和实现
5. 生成比特流文件
6. 报告最终的时序和资源使用情况
```

---

## 9️⃣ 常见问题

### Q1: MCP 服务器连接失败

**症状**: Chatbox 显示 "Version negotiation failed"

**解决方法**:
1. 检查 Python 版本: `D:\必备软件\Python\python.exe --version` (需要 3.10+)
2. 检查 MCP 版本: `D:\必备软件\Python\python.exe -m pip show mcp` (必须是 1.x)
3. 查看日志: `D:\EN_apps\MCP\fpga-mcp-main\mcp_server.log`

### Q2: Tcl 服务器无法启动

**症状**: 运行 Vivado/Quartus 启动命令后报错

**解决方法**:
1. 检查路径是否正确
2. 确认 FPGA 工具已正确安装
3. 检查端口是否被占用:
   ```powershell
   netstat -ano | findstr :9999  # Vivado
   netstat -ano | findstr :9998  # Quartus
   ```

### Q3: AI 说无法连接到后端

**症状**: AI 返回 "Backend not connected" 或类似错误

**原因**: Tcl 服务器没有运行

**解决方法**:
1. 启动对应的 Tcl 服务器（Vivado 或 Quartus）
2. 确认服务器启动成功（显示 "listening on port xxx"）
3. 在 Chatbox 中重试

### Q4: 切换后端不起作用

**症状**: 切换到 Quartus 后，AI 还是使用 Vivado

**解决方法**:
1. 确保两个 Tcl 服务器都在运行
2. 明确告诉 AI: "使用 Quartus 后端"
3. 检查配置文件中两个后端的路径都正确

### Q5: 缺少某些功能

**症状**: AI 说"该功能不可用"

**原因**: 可能是项目代码缺少某些函数实现

**解决方法**:
- 查看错误日志
- 检查 `_handlers.py` 是否包含所有需要的函数
- 如果缺失，参考本文档第 3 节添加补丁

---

## 🎯 完整配置检查清单

配置完成后，检查以下项目：

- [ ] Python 3.10+ 已安装
- [ ] fpga-mcp 项目已下载到 `D:\EN_apps\MCP\fpga-mcp-main`
- [ ] `fpga_mcp` 目录已创建（从 `src` 复制）
- [ ] MCP 1.x 依赖已安装
- [ ] `_handlers.py` 补丁已应用（所有缺失函数已添加）
- [ ] 配置文件 `%APPDATA%\fpga-mcp\config.json` 已创建
- [ ] Vivado 和 Quartus 路径在配置文件中正确
- [ ] Chatbox MCP 服务器已配置
- [ ] Chatbox MCP 服务器连接测试成功
- [ ] 启动脚本已创建（可选）
- [ ] Vivado Tcl 服务器可以启动
- [ ] Quartus Tcl 服务器可以启动
- [ ] AI 可以成功调用 FPGA 工具

---

## 📚 技术架构说明

### 系统组成

```
┌─────────────────┐
│   Chatbox AI    │  用户界面，发送自然语言指令
└────────┬────────┘
         │ stdio
         ▼
┌─────────────────┐
│  FPGA MCP       │  MCP 服务器，解析 AI 指令为工具调用
│  Server         │
└────────┬────────┘
         │ TCP
         ▼
┌─────────────────────────────────┐
│  Vivado Tcl Server (port 9999)  │  在 Vivado 中执行 Tcl 命令
│  Quartus Tcl Server (port 9998) │  在 Quartus 中执行 Tcl 命令
└─────────────────────────────────┘
```

### 工具层次

- **689 个工具**总计
  - **22 个高层工具**: 跨厂商通用（create_project, run_synthesis, 等）
  - **343 个 Vivado 工具**: Vivado 专用（viv_* 前缀）
  - **167 个 Quartus 工具**: Quartus 专用（q_* 前缀）
  - **157 个 Anlogic 工具**: 安路专用（a_* 前缀）

### 数据流

1. **用户** → Chatbox: 自然语言请求
2. **AI** → MCP Server: 工具调用请求（JSON-RPC）
3. **MCP Server** → Tcl Server: Tcl 命令（TCP）
4. **Tcl Server** → FPGA Tool: 执行命令
5. **结果原路返回**

---

## 🔗 相关资源

- **项目仓库**: https://github.com/wmm246/fpga-mcp
- **MCP 协议**: https://modelcontextprotocol.io
- **Vivado 文档**: https://www.xilinx.com/support/documentation.html
- **Quartus 文档**: https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/overview.html

---

## ✅ 配置完成

恭喜！你已经完成了 FPGA MCP 的完整配置。

现在可以：
1. 启动对应的 Tcl 服务器
2. 在 Chatbox 中用自然语言控制 FPGA 开发工具
3. 自动化你的 FPGA 开发流程

享受 AI 辅助的 FPGA 开发体验！🚀

---

**文档版本**: 1.0  
**创建日期**: 2026-10-02  
**适用系统**: Windows 10/11  
**适用 FPGA 工具**: Vivado 2026.1, Quartus 18.1
