# FPGA双目3D重建系统

基于PYNQ-Z2的实时立体视觉系统

## 项目结构

```
fpga_project/
├── hardware/              # FPGA硬件相关
│   ├── rtl/              # Verilog源码
│   ├── sim/              # 仿真测试
│   ├── constraints/      # 约束文件
│   └── ip/               # 自定义IP核
│
├── software/             # 软件相关
│   ├── python/          # Python代码（PYNQ）
│   └── scripts/         # 自动化脚本
│
├── fpga/                # Vivado工程目录
│   └── project_1/       # Vivado工程文件
│
├── build/               # 编译输出（.bit/.hwh）
├── test_data/           # 测试数据
└── docs/                # 文档

```

## 快速开始

### 第一阶段：数据通路验证

1. **硬件开发**（Vivado）
   - 源码：`hardware/rtl/image_invert_axis.v`
   - 参考：`VIVADO_TUTORIAL.md`
   - 输出：`build/design_1.bit`, `build/design_1.hwh`

2. **软件测试**（PYNQ）
   - 上传脚本：`software/python/upload_to_pynq.bat`
   - 测试：`software/python/test_fpga_invert.py`

3. **生成测试图像**
   ```bash
   python software/python/generate_test_images.py
   ```

## 团队分工

- **队长**：FPGA硬件 → `hardware/`
- **成员B**：算法开发 → `software/python/`
- **成员C**：可视化 → `software/python/`

## 当前阶段

✅ 阶段1：FPGA数据通路验证（图像反转）
⏳ 阶段2：SAD立体匹配模块
⏳ 阶段3：系统集成与优化
