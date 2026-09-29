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

## PYNQ设备信息

- IP地址: 192.168.2.99
- 用户名: xilinx
- Python版本: 3.10.4
- 架构: armv7l

## Git使用

代码保存在本地，可以正常使用git进行版本控制：

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-repo-url>
git push -u origin main
```
