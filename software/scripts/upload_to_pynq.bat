@echo off
REM 上传文件到PYNQ

set PYNQ_IP=192.168.2.99
set PYNQ_USER=xilinx
set PYNQ_DIR=/home/xilinx/jupyter_notebooks

echo 上传Python文件到PYNQ...

scp fpga_image_processor.py %PYNQ_USER%@%PYNQ_IP%:%PYNQ_DIR%/
scp test_fpga_invert.py %PYNQ_USER%@%PYNQ_IP%:%PYNQ_DIR%/

echo 上传bitstream文件...
scp ../../build/design_1.bit %PYNQ_USER%@%PYNQ_IP%:%PYNQ_DIR%/
scp ../../build/design_1.hwh %PYNQ_USER%@%PYNQ_IP%:%PYNQ_DIR%/

echo 完成！
pause
