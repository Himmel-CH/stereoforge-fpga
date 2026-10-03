# Vivado完整操作指南 - 图像反转模块

本文档详细说明如何在Vivado中创建FPGA工程，从零到生成bitstream。

---

## 📋 前置准备

### 所需文件
- `image_invert_axis.v` - AXI Stream图像反转模块
- PYNQ-Z2开发板

### 软件版本
- Vivado 2020.1 或更高版本（推荐2020.2, 2022.1, 2023.2）

---

## 🎯 第一步：创建新工程

### 1.1 启动Vivado

1. 打开Vivado Design Suite
2. 点击 **Create Project**

### 1.2 工程配置

**Project Name（工程名称）**
- Project name: `image_invert_project`
- Project location: 选择你的工作目录
- ✅ 勾选 **Create project subdirectory**

点击 **Next**

---

**Project Type（工程类型）**
- 选择 **RTL Project**
- ✅ 勾选 **Do not specify sources at this time**（我们稍后添加源文件）

点击 **Next**

---

**Default Part（选择器件）**

⚠️ **重要：这是PYNQ-Z2的芯片型号**

选择方式1（推荐）：
1. 点击 **Boards** 标签
2. 在搜索框输入 `pynq`
3. 如果看到 **PYNQ-Z2**，直接选择它
4. 如果没有，使用方式2

选择方式2（手动选择芯片）：
1. 点击 **Parts** 标签
2. 设置以下筛选条件：
   - **Family**: Zynq-7000
   - **Package**: clg400
   - **Speed Grade**: -1
3. 在列表中找到并选择：**xc7z020clg400-1**

点击 **Next**，然后 **Finish**

---

## 🎯 第二步：添加源文件

### 2.1 添加Verilog源代码

1. 在 **Flow Navigator** 左侧面板，找到 **PROJECT MANAGER** → **Add Sources**
2. 或者点击菜单栏：**Project** → **Add Sources**

---

**选择源类型**
- 选择 **Add or create design sources**
- 点击 **Next**

---

**添加文件**
- 点击 **+ Add Files**
- 浏览并选择 `image_invert_axis.v` 文件
- ✅ 勾选 **Copy sources into project**（将文件复制到工程目录）
- 点击 **Finish**

---

### 2.2 验证文件添加成功

在 **Sources** 窗口中，你应该看到：
```
Design Sources
└── image_invert_axis (image_invert_axis.v)
```

双击文件名可以查看代码。

---

## 🎯 第三步：创建Block Design

Block Design是Vivado的图形化设计界面，用于连接IP核。

### 3.1 创建Block Design

1. 点击 **Flow Navigator** → **IP INTEGRATOR** → **Create Block Design**
2. Design name: `design_1`（保持默认）
3. 点击 **OK**

现在会打开一个空白的设计画布。

---

### 3.2 添加Zynq处理器

**添加ZYNQ7 PS（Processing System）**

1. 在画布空白处右键，选择 **Add IP**
2. 或者点击画布顶部的 **+** 按钮
3. 搜索框输入 `zynq`
4. 双击 **ZYNQ7 Processing System**

此时画布上会出现一个大的Zynq处理器模块。

---

**运行Block Automation（自动配置）**

1. 画布顶部会出现绿色提示条：**Run Block Automation**
2. 点击它
3. 在弹出窗口中：
   - ✅ 勾选 `/processing_system7_0`
   - Apply Board Preset: ✅（如果你选择了PYNQ-Z2板子）
4. 点击 **OK**

Vivado会自动配置Zynq处理器的默认设置。

---

### 3.3 配置Zynq（启用HP接口）

我们需要启用High Performance接口来连接DMA。

1. 双击 **processing_system7_0** 模块打开配置窗口
2. 在左侧导航，找到 **PS-PL Configuration**
3. 展开 **HP Slave AXI Interface**
4. ✅ 勾选 **S AXI HP0 interface**（这是高速数据通道）
5. 点击 **OK**

---

### 3.4 添加AXI DMA

DMA用于在PS和PL之间高速传输数据。

1. 画布空白处右键 → **Add IP**
2. 搜索 `dma`
3. 双击 **AXI Direct Memory Access**

---

**配置DMA**

1. 双击 **axi_dma_0** 打开配置窗口
2. 配置以下参数：

**Basic标签页**：
- ✅ Enable Scatter Gather Engine: **取消勾选**（简化设计）
- Width of Buffer Length Register: **26**（最大64MB传输）

**Stream Options标签页**：
- Memory Map Data Width: **32**（32位数据总线）
- Stream Data Width: **32**（32位流数据）
- ✅ Enable Control/Status Stream: **取消勾选**

3. 点击 **OK**

---

### 3.5 添加你的图像处理模块

**将RTL模块添加到Block Design**

1. 在 **Sources** 窗口中，找到 `image_invert_axis`
2. 将它 **拖拽** 到Block Design画布上
3. 或者右键 **Add Module**，选择 `image_invert_axis`

---

### 3.6 连接模块

现在需要手动连接各个模块。

**自动连接大部分接口**

1. 画布顶部点击 **Run Connection Automation**
2. 勾选所有可用的连接选项
3. 点击 **OK**

Vivado会自动连接AXI总线和时钟/复位信号。

---

**手动连接Stream接口（关键！）**

需要连接DMA和你的图像处理模块之间的Stream接口：

1. **DMA输出 → 图像模块输入**：
   - 找到 `axi_dma_0` 的 **M_AXIS_MM2S** 端口（绿色箭头向右）
   - 点击它，鼠标会变成铅笔
   - 拖动到 `image_invert_axis_0` 的 **S_AXIS** 端口
   - 松开鼠标完成连接

2. **图像模块输出 → DMA输入**：
   - 找到 `image_invert_axis_0` 的 **M_AXIS** 端口
   - 连接到 `axi_dma_0` 的 **S_AXIS_S2MM** 端口

---

**连接HP接口**

如果自动连接没有连接HP接口：

1. 找到 `axi_dma_0` 的 **M_AXI_MM2S** 和 **M_AXI_S2MM** 端口
2. 这些应该通过AXI Interconnect连接到 `processing_system7_0` 的 **S_AXI_HP0**

如果没有AXI Interconnect，需要手动添加：
- Add IP → **AXI Interconnect**
- 配置 Number of Master/Slave Interfaces

---

### 3.7 验证连接

完成后的连接应该是：

```
                  ┌─────────────────────┐
                  │  processing_system7 │
                  │                     │
                  │  [M_AXI_GP0]───────┐│
                  │                    ││
                  │  [S_AXI_HP0]◄──────┘│
                  └─────────────────────┘
                            ▲
                            │ (AXI Interconnect)
                            │
                  ┌─────────┴─────────┐
                  │                   │
             ┌────┴────┐         ┌───┴────┐
             │         │         │        │
        ┌────┤ AXI DMA ├─Stream──► Image  │
        │    │         │         │ Invert │
        │    │         │◄─Stream──        │
        │    └─────────┘         └────────┘
        │
        └─(HP0)
```

---

### 3.8 验证地址分配

1. 点击画布顶部的 **Address Editor** 标签
2. 验证 `axi_dma_0` 有一个地址范围（例如：`0x40400000`）
3. 如果没有，右键 → **Assign**

---

### 3.9 验证Block Design

1. 点击菜单栏：**Tools** → **Validate Design**（或按 F6）
2. 应该看到 **"Validation successful"**
3. 如果有错误或Critical Warning，需要修复

---

## 🎯 第四步：生成HDL包装器

Block Design需要转换为HDL代码才能综合。

1. 在 **Sources** 窗口，找到 **Design Sources** → **design_1**
2. 右键点击 `design_1.bd`
3. 选择 **Create HDL Wrapper**
4. 选择 **Let Vivado manage wrapper and auto-update**
5. 点击 **OK**

现在会生成 `design_1_wrapper.v`，它是顶层模块。

---

## 🎯 第五步：添加约束文件（可选）

对于本项目，我们不需要外部引脚约束（因为所有IO都通过PS）。

但如果你想添加时钟约束：

1. **Add Sources** → **Add or create constraints**
2. 创建新文件 `constraints.xdc`
3. 添加内容（可选）：
```tcl
# 创建时钟约束（如果需要）
create_clock -period 10.000 -name clk [get_ports clk]
```

对于本项目，**可以跳过这一步**。

---

## 🎯 第六步：综合（Synthesis）

### 6.1 运行综合

1. 点击 **Flow Navigator** → **SYNTHESIS** → **Run Synthesis**
2. 或者点击工具栏绿色播放按钮
3. 在弹出窗口选择运行参数（默认即可）
4. 点击 **OK**

**等待时间**：3-10分钟（取决于电脑性能）

---

### 6.2 查看综合结果

综合完成后会弹出窗口：
- 选择 **Open Synthesized Design**（可选，查看原理图）
- 或者直接点击 **Cancel**，继续下一步

---

### 6.3 检查资源使用情况

1. 点击 **Open Synthesized Design**
2. 菜单栏：**Reports** → **Report Utilization**
3. 查看资源占用：
   - LUT（查找表）
   - FF（触发器）
   - BRAM（块RAM）
   - DSP

记录这些数据，报告中需要用到。

---

## 🎯 第七步：实现（Implementation）

### 7.1 运行实现

1. 点击 **Flow Navigator** → **IMPLEMENTATION** → **Run Implementation**
2. 在弹出窗口选择运行参数（默认即可）
3. 点击 **OK**

**等待时间**：5-15分钟

---

### 7.2 查看实现结果

实现完成后会弹出窗口：
- 选择 **Open Implemented Design**（可选）
- 或者直接点击 **Cancel**，继续生成bitstream

---

## 🎯 第八步：生成Bitstream

### 8.1 运行生成

1. 点击 **Flow Navigator** → **PROGRAM AND DEBUG** → **Generate Bitstream**
2. 点击 **OK**

**等待时间**：3-8分钟

---

### 8.2 生成成功

看到 **"Bitstream Generation Completed Successfully"**

点击 **Cancel** 或 **Open Hardware Manager**（如果要直接下载）

---

## 🎯 第九步：导出文件到PYNQ

### 9.1 查找生成的文件

生成的文件位于：
```
<工程目录>/image_invert_project.runs/impl_1/
```

需要的文件：
- ✅ `design_1_wrapper.bit` - FPGA配置文件
- ✅ `design_1.hwh` - 硬件描述文件（PYNQ需要）

---

### 9.2 复制.hwh文件

`.hwh`文件默认在：
```
<工程目录>/image_invert_project.gen/sources_1/bd/design_1/hw_handoff/
```

**重要**：`.bit`和`.hwh`文件必须同名！

重命名文件：
- `design_1_wrapper.bit` → `design_1.bit`
- `design_1.hwh` → `design_1.hwh`

---

### 9.3 上传到PYNQ

使用之前配置的VSCode任务或SCP命令：

```bash
scp design_1.bit xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/
scp design_1.hwh xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/
```

或者通过Jupyter Notebook界面上传：
1. 访问 http://pynq:9090
2. 点击 **Upload** 按钮
3. 选择两个文件上传

---

## 🎯 第十步：在PYNQ上测试

### 10.1 上传Python脚本

将以下文件上传到PYNQ：
- `fpga_image_processor.py`
- `test_fpga_invert.py`

### 10.2 运行测试

SSH到PYNQ：
```bash
ssh xilinx@192.168.2.99
cd ~/jupyter_notebooks
python3 test_fpga_invert.py
```

或者在Jupyter Notebook中创建新notebook，运行：
```python
from fpga_image_processor import ImageInverter
import numpy as np

# 初始化
processor = ImageInverter('design_1.bit')

# 创建测试图像
test_img = np.random.randint(0, 256, (480, 640), dtype=np.uint8)

# 处理
result = processor.invert(test_img)

# 验证
expected = 255 - test_img
print(f"测试通过: {np.allclose(result, expected)}")
```

---

## ❓ 常见问题排查

### 问题1：找不到PYNQ-Z2板子

**解决方案**：手动选择芯片 **xc7z020clg400-1**

### 问题2：综合失败 - 未找到模块

**原因**：源文件没有正确添加
**解决**：检查Sources窗口，确保`image_invert_axis.v`存在

### 问题3：Block Automation不可用

**原因**：需要先添加Zynq PS
**解决**：删除重新添加ZYNQ7 Processing System

### 问题4：DMA连接错误

**症状**：Validate Design报错
**解决**：
- 检查Stream接口连接方向
- 确保时钟和复位信号已连接
- 重新运行Connection Automation

### 问题5：生成bitstream失败 - 时序不满足

**解决**：
- 降低时钟频率（修改Zynq配置）
- 添加时序约束
- 简化设计

### 问题6：PYNQ加载bitstream失败

**症状**：`Overlay()`报错
**解决**：
- 确保`.bit`和`.hwh`文件同名
- 检查文件路径是否正确
- 查看错误信息：可能是DMA驱动问题

---

## 📊 预期结果

### 资源使用（参考）
- LUT: ~1000 (<2%)
- FF: ~1500 (<2%)
- BRAM: 2-4
- DSP: 0

### 性能（预期）
- 时钟频率: 100MHz
- 处理延迟: ~10-50ms（取决于图像大小）
- 帧率: 640×480 @ 20-30fps

---

## ✅ 完成检查清单

- [ ] Vivado工程创建成功
- [ ] Block Design验证通过
- [ ] 综合无错误
- [ ] 实现无Critical Warning
- [ ] Bitstream生成成功
- [ ] 文件已上传到PYNQ
- [ ] Python测试脚本运行成功
- [ ] 图像反转功能验证通过

---

## 📚 下一步

完成本教程后，你应该：
1. 理解了Vivado的基本工作流程
2. 掌握了Block Design的使用
3. 了解了AXI DMA的配置
4. 验证了FPGA-PYNQ数据通路

**下一阶段**：将参考项目的SAD模块集成到你的工程中。
