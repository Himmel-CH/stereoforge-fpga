# 项目结构说明

## 已完成的规范化整理

```
fpga_project/
├── README.md                    # 项目总览
├── VIVADO_TUTORIAL.md           # Vivado操作教程
├── STAGE1_README.md             # 第一阶段详细说明
├── .gitignore                   # Git忽略配置
│
├── hardware/                    # 硬件相关（你负责）
│   ├── rtl/                     # Verilog源码
│   │   ├── image_invert.v
│   │   └── image_invert_axis.v
│   ├── sim/                     # 仿真测试
│   │   └── image_invert_axis_tb.v
│   ├── constraints/             # 约束文件（XDC）
│   └── ip/                      # 自定义IP核
│
├── software/                    # 软件相关
│   ├── python/                  # Python代码（队友B/C）
│   │   ├── fpga_image_processor.py
│   │   ├── test_fpga_invert.py
│   │   └── generate_test_images.py
│   └── scripts/                 # 自动化脚本
│       └── upload_to_pynq.bat
│
├── fpga/                        # Vivado工程
│   └── project_1/               # 你的Vivado工程（保持不动）
│
├── build/                       # 编译输出
│   # 生成的.bit和.hwh文件放这里
│
└── test_data/                   # 测试数据
    # 测试图像放这里
```

## 下一步操作

### 1. 在Vivado中添加源文件
打开 `fpga/project_1/project_1.xpr`，添加源文件：
- `hardware/rtl/image_invert_axis.v`

### 2. 生成bitstream后
复制到 `build/` 目录：
```bash
copy <vivado_runs>/design_1_wrapper.bit build/design_1.bit
copy <vivado_gen>/design_1.hwh build/design_1.hwh
```

### 3. 上传到PYNQ
运行：`software/scripts/upload_to_pynq.bat`

### 4. 生成测试图像
```bash
cd software/python
python generate_test_images.py
```

### 5. 测试
SSH到PYNQ：
```bash
cd ~/jupyter_notebooks
python3 test_fpga_invert.py
```

## Git提交建议

```bash
git add hardware/ software/ build/ .gitignore README.md
git commit -m "feat: 添加第一阶段图像反转模块"
```

---

**参考文档**：
- 快速开始：`README.md`
- Vivado教程：`VIVADO_TUTORIAL.md`
- 详细说明：`STAGE1_README.md`
