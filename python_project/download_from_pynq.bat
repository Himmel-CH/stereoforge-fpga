@echo off
REM 从PYNQ下载jupyter_notebooks目录中的所有文件到本地
scp -r xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/* "%~dp0"
echo 文件已下载到本地
pause
