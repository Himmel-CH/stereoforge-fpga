# FPGA图像反转模块 - 数据通路验证项目

> 本项目用于验证FPGA-PYNQ数据通路，是双目3D重建系统的第一阶段。

---

## 📋 项目概述

### 功能
实现一个简单的图像处理模块（图像反转），验证：
- Python能将图像数据发送到FPGA
- FPGA能处理数据（将灰度值反转：output = 255 - input）
- Python能读取FPGA处理结果

### 平台
- **硬件**：PYNQ-Z2开发板（Zynq-7020 SoC）
- **软件**：Vivado 2020.1+, Python 3.6+, PYNQ 2.7+

### 技术栈
- **Verilog**：图像处理逻辑
- **AXI4-Stream**：数据流接口
- **AXI DMA**：高速数据传输
- **Python**：系统控制和测试

---

## 📁 项目结构

```
image_invert_project/
├── README.md                      # 本文件
├── VIVADO_TUTORIAL.md             # Vivado完整操作指南
├── QUICK_REFERENCE.md             # 快速参考卡片
│
├── rtl/                           # Verilog硬件源码
│   ├── image_invert.v             # 核心处理模块
│   └── image_invert_axis.v        # AXI-Stream包装器 ⭐主要使用
│
├── sim/                           # 仿真测试
│   └── image_invert_axis_tb.v     # Testbench
│
├── python/                        # Python代码
│   ├── fpga_image_processor.py    # FPGA封装类
│   ├── test_fpga_invert.py        # 测试脚本
│   └── generate_test_images.py    # 生成测试图像
│
├── test_images/                   # 测试图像（运行generate后生成）
│   ├── checkerboard.png
│   ├── gradient.png
│   └── ...
│
└── outputs/                       # Vivado生成文件（手动创建）
    ├── design_1.bit               # FPGA配置文件
    └── design_1.hwh               # 硬件描述文件
```

---

## 🚀 快速开始

### 前置条件

**硬件**：
- ✅ PYNQ-Z2开发板
- ✅ 电源适配器（5V/3A）
- ✅ 网络连接（以太网或WiFi）
- ✅ SD卡已烧录PYNQ镜像

**软件**：
- ✅ Vivado 2020.1或更高版本
- ✅ PYNQ开发板已启动，IP地址已知（如：192.168.2.99）
- ✅ SSH连接已配置

---

### 步骤1：克隆或下载代码

```bash
# 下载所有文件到本地
# 确保以下文件存在：
# - image_invert_axis.v
# - fpga_image_processor.py
# - test_fpga_invert.py
```

---

### 步骤2：在Vivado中创建工程

**详细步骤见：`VIVADO_TUTORIAL.md`**

**快速版本**：
1. 打开Vivado，创建新工程
2. 选择器件：`xc7z020clg400-1`（PYNQ-Z2）
3. 添加源文件：`image_invert_axis.v`
4. 创建Block Design：
   - 添加 ZYNQ7 Processing System
   - 添加 AXI DMA
   - 添加 image_invert_axis（你的模块）
   - 连接Stream接口（DMA ↔ image_invert）
5. 生成HDL Wrapper
6. 综合 → 实现 → 生成Bitstream
7. 导出文件：`design_1.bit` 和 `design_1.hwh`

**预计时间**：首次30-40分钟

---

### 步骤3：生成测试图像（可选）

```bash
# 在本地Windows电脑上运行
python generate_test_images.py
```

这会在 `test_images/` 目录生成多张测试图像。

---

### 步骤4：上传文件到PYNQ

```bash
# 方法1：使用SCP
scp design_1.bit xilinx@192.168.2.99:~/jupyter_notebooks/
scp design_1.hwh xilinx@192.168.2.99:~/jupyter_notebooks/
scp fpga_image_processor.py xilinx@192.168.2.99:~/jupyter_notebooks/
scp test_fpga_invert.py xilinx@192.168.2.99:~/jupyter_notebooks/

# 方法2：通过Jupyter Notebook界面上传
# 访问 http://pynq:9090，点击Upload按钮
```

---

### 步骤5：运行测试

**方法A：命令行测试**

```bash
# SSH连接到PYNQ
ssh xilinx@192.168.2.99

# 进入工作目录
cd ~/jupyter_notebooks

# 运行测试脚本
python3 test_fpga_invert.py
```

**预期输出**：
```
============================================================
FPGA图像反转模块完整测试
============================================================
加载FPGA配置文件: design_1.bit
FPGA初始化完成

============================================================
测试1: 基本功能测试
============================================================

测试: 全黑图像
处理完成: 12.34ms (100x100)
✓ 全黑图像 - 通过

测试: 全白图像
处理完成: 11.89ms (100x100)
✓ 全白图像 - 通过

...

============================================================
测试完成
============================================================
```

---

**方法B：Jupyter Notebook测试**

1. 访问：`http://192.168.2.99:9090`（或 http://pynq:9090）
2. 创建新的Notebook
3. 运行以下代码：

```python
from fpga_image_processor import ImageInverter
import numpy as np

# 初始化FPGA
processor = ImageInverter('design_1.bit')

# 创建测试图像
test_img = np.array([[0, 128, 255],
                     [64, 192, 32],
                     [100, 200, 150]], dtype=np.uint8)

# 处理
result = processor.invert(test_img)

# 验证
expected = 255 - test_img
print("测试通过:", np.allclose(result, expected))
print("输入:\n", test_img)
print("输出:\n", result)
print("期望:\n", expected)
```

---

## 📊 测试验证

### 基本功能测试

测试项目：
- ✅ 全黑图像（0） → 全白（255）
- ✅ 全白图像（255） → 全黑（0）
- ✅ 中灰图像（128） → 反转（127）
- ✅ 渐变图像
- ✅ 随机图像

### 性能测试

| 分辨率 | 像素数 | 处理时间 | 帧率 |
|--------|--------|---------|------|
| 160×120 | 19,200 | ~5ms | 200fps |
| 320×240 | 76,800 | ~15ms | 66fps |
| 640×480 | 307,200 | ~40ms | 25fps |

### 资源使用

| 资源类型 | 使用量 | 可用量 | 占比 |
|---------|-------|--------|-----|
| LUT     | ~1,200 | 53,200 | 2.3% |
| FF      | ~1,800 | 106,400 | 1.7% |
| BRAM    | 4     | 140    | 2.9% |
| DSP     | 0     | 220    | 0%   |

---

## 🔧 故障排查

### 问题1：找不到.bit文件

**错误**：`FileNotFoundError: design_1.bit`

**解决**：
```python
# 使用绝对路径
processor = ImageInverter('/home/xilinx/jupyter_notebooks/design_1.bit')

# 或检查当前目录
import os
print(os.getcwd())
print(os.listdir('.'))
```

---

### 问题2：无法找到DMA设备

**错误**：`AttributeError: 'Overlay' object has no attribute 'axi_dma_0'`

**原因**：
- .hwh文件缺失
- .bit和.hwh文件名不匹配

**解决**：
```bash
# 确保两个文件在同一目录且同名
ls -l design_1.*
# 应该看到：
# design_1.bit
# design_1.hwh
```

---

### 问题3：DMA传输超时

**错误**：`RuntimeError: DMA transfer timeout`

**可能原因**：
1. Stream接口没有正确连接
2. 图像尺寸过大，超出DMA缓冲区
3. FPGA逻辑卡住

**解决**：
1. 检查Vivado Block Design的Stream连接
2. 使用小尺寸图像测试（如100×100）
3. 重新加载bitstream：
```python
del processor
processor = ImageInverter('design_1.bit')
```

---

### 问题4：结果不正确

**症状**：输出不是255-输入

**排查**：
```python
# 打印详细信息
print("输入范围:", test_img.min(), "-", test_img.max())
print("输出范围:", result.min(), "-", result.max())
print("期望范围:", (255-test_img).min(), "-", (255-test_img).max())

# 查看差异
diff = np.abs(result.astype(int) - (255 - test_img).astype(int))
print("最大差异:", diff.max())
print("差异位置:", np.where(diff > 0))
```

---

### 问题5：Vivado综合失败

**常见错误**：
- **语法错误**：检查Verilog代码，特别是always块和信号声明
- **未声明的信号**：确保所有wire/reg都已声明
- **端口不匹配**：检查模块实例化时的端口连接

**解决**：
1. 查看Vivado的Messages窗口
2. 双击错误信息跳转到代码位置
3. 运行仿真测试（`image_invert_axis_tb.v`）验证逻辑

---

## 📚 技术细节

### AXI4-Stream接口

```verilog
// 从接口（接收数据）
input  [31:0] s_axis_tdata,   // 数据（32位 = 4像素）
input         s_axis_tvalid,  // 数据有效信号
output        s_axis_tready,  // 准备接收信号
input         s_axis_tlast,   // 最后一个数据

// 主接口（发送数据）
output [31:0] m_axis_tdata,   // 数据
output        m_axis_tvalid,  // 数据有效信号
input         m_axis_tready,  // 对方准备好信号
output        m_axis_tlast,   // 最后一个数据
```

### 数据流程

```
Python NumPy数组
    ↓
PYNQ allocate（分配物理内存）
    ↓
DMA.sendchannel.transfer（启动发送）
    ↓
AXI4-Stream → FPGA处理 → AXI4-Stream
    ↓
DMA.recvchannel.transfer（启动接收）
    ↓
Python NumPy数组（结果）
```

### 处理逻辑

```verilog
// 对每个字节（像素）进行反转
m_axis_tdata[7:0]   <= 8'd255 - s_axis_tdata[7:0];    // Byte 0
m_axis_tdata[15:8]  <= 8'd255 - s_axis_tdata[15:8];   // Byte 1
m_axis_tdata[23:16] <= 8'd255 - s_axis_tdata[23:16];  // Byte 2
m_axis_tdata[31:24] <= 8'd255 - s_axis_tdata[31:24];  // Byte 3
```

---

## 🎓 学习要点

通过本项目，你应该掌握：

### Vivado技能
- ✅ 创建RTL工程
- ✅ 使用Block Design
- ✅ 配置Zynq PS和AXI DMA
- ✅ 生成bitstream

### Verilog技能
- ✅ 理解AXI4-Stream协议
- ✅ 编写状态机和数据处理逻辑
- ✅ 使用always块和时序逻辑

### PYNQ技能
- ✅ 加载Overlay
- ✅ 使用DMA进行数据传输
- ✅ 分配物理内存（allocate）
- ✅ 性能测试和优化

---

## 🔜 下一步

完成本项目后，进入第二阶段：**SAD立体匹配模块**

主要变化：
1. **输入**：双通道图像（左图 + 右图）
2. **处理**：SAD计算 → 视差图
3. **输出**：视差图（单通道）

可复用的部分：
- ✅ Block Design架构（Zynq + DMA）
- ✅ Python封装类结构
- ✅ 测试流程

需要修改的部分：
- ⚠️ Verilog逻辑（从反转改为SAD计算）
- ⚠️ 输入数据格式（双图像）
- ⚠️ 处理时间（SAD更复杂）

---

## 📖 参考资料

### 官方文档
- [PYNQ官方文档](https://pynq.readthedocs.io/)
- [Vivado设计套件用户指南](https://www.xilinx.com/support/documentation.html)
- [AXI DMA数据手册 PG021](https://www.xilinx.com/support/documentation/ip_documentation/axi_dma/v7_1/pg021_axi_dma.pdf)

### 教程
- Vivado Block Design教程（UG949）
- AXI4-Stream协议规范
- Zynq-7000 TRM（UG585）

---

## 👥 贡献者

本项目是**FPGA双目3D重建系统**的第一阶段

- **队长**：FPGA硬件负责人
- **团队**：三人协作开发

---

## 📝 许可证

本项目仅用于学习和竞赛目的。

---

## ✅ 完成检查清单

- [ ] Vivado工程创建成功
- [ ] Bitstream生成无错误
- [ ] 文件上传到PYNQ
- [ ] 基本功能测试通过
- [ ] 性能测试完成
- [ ] 理解了数据流程
- [ ] 可以独立修改Verilog代码

**完成以上所有项后，你已经掌握了FPGA-PYNQ开发的基础！🎉**
