# 第一阶段工作交接文档

> 版本：v0.1.0-stage1  
> 日期：2026-10-03 
---

## 一、我完成的工作

### 1.1 核心成果

**验证了FPGA-PYNQ数据通路**
- 证明Python可以通过DMA将数据发送到FPGA
- 证明FPGA可以处理数据并返回结果
- 证明性能满足实时处理要求

**实现了硬件加速接口**
- 创建了标准的AXI-Stream接口模块
- 封装了Python调用接口
- 提供了完整的测试流程

**建立了开发工作流**
- Vivado工程配置
- 代码组织结构
- 自动化测试脚本

### 1.2 技术指标

- ✅ 数据通路验证：通过
- ✅ 功能正确性：100%
- ✅ 处理延迟：1.02ms（3×3图像）
- ✅ 可扩展性：支持任意尺寸图像

---

## 二、项目文件结构

```
fpga_project/
├── README.md                    # 项目总览
├── VIVADO_TUTORIAL.md           # Vivado详细教程
├── STAGE1_README.md             # 第一阶段详细文档
├── PROJECT_STRUCTURE.md         # 文件结构说明
├── .gitignore                   # Git配置
│
├── hardware/                    # 硬件相关（我负责）
│   ├── rtl/                     # Verilog源码
│   │   ├── image_invert.v              # 核心逻辑（学习参考）
│   │   └── image_invert_axis.v         # AXI-Stream接口（实际使用）
│   │
│   ├── sim/                     # 仿真测试
│   │   └── image_invert_axis_tb.v      # Testbench
│   │
│   ├── constraints/             # 约束文件目录（未来用）
│   └── ip/                      # 自定义IP核目录（未来用）
│
├── software/                    # 软件相关（队友负责）
│   ├── python/                  # Python代码
│   │   ├── fpga_image_processor.py     # FPGA封装类（核心接口）
│   │   ├── test_fpga_invert.py         # 测试脚本
│   │   ├── generate_test_images.py     # 生成测试图像
│   │   └── stage1_test.ipynb           # Jupyter测试笔记
│   │
│   └── scripts/                 # 自动化脚本
│       └── upload_to_pynq.bat          # 上传文件到PYNQ
│
├── fpga/                        # Vivado工程
│   └── project_1/               # Vivado工程文件（不要动）
│
├── build/                       # 编译输出
│   # 生成的.bit和.hwh文件放这里
│
└── test_data/                   # 测试数据
    # 测试图像放这里
```

---

## 三、文件详细说明

### 3.1 文档文件

| 文件名 | 用途 | 阅读优先级 |
|--------|------|-----------|
| `README.md` | 项目总览，快速了解项目 | ⭐⭐⭐⭐⭐ |
| `VIVADO_TUTORIAL.md` | Vivado操作详细教程 | ⭐⭐⭐ |
| `STAGE1_README.md` | 第一阶段详细说明 | ⭐⭐⭐⭐ |
| `PROJECT_STRUCTURE.md` | 文件结构说明 | ⭐⭐⭐ |

### 3.2 硬件文件（hardware/）

#### `hardware/rtl/image_invert_axis.v` ⭐核心文件
**作用**：FPGA图像处理模块，AXI-Stream接口

**接口定义**：
```verilog
module image_invert_axis (
    // 时钟和复位
    input  wire        aclk,
    input  wire        aresetn,
    
    // 输入流（从DMA接收）
    input  wire [31:0] s_axis_tdata,   // 32位数据（4个像素）
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    
    // 输出流（发送到DMA）
    output reg  [31:0] m_axis_tdata,
    output reg         m_axis_tvalid,
    input  wire        m_axis_tready,
    output reg         m_axis_tlast
);
```

**数据格式**：
- 32位 = 4个字节 = 4个灰度像素
- `tdata[7:0]` = 像素0
- `tdata[15:8]` = 像素1
- `tdata[23:16]` = 像素2
- `tdata[31:24]` = 像素3

**处理逻辑**：
```verilog
// 反转每个像素
m_axis_tdata[7:0]   <= 8'd255 - s_axis_tdata[7:0];
m_axis_tdata[15:8]  <= 8'd255 - s_axis_tdata[15:8];
m_axis_tdata[23:16] <= 8'd255 - s_axis_tdata[23:16];
m_axis_tdata[31:24] <= 8'd255 - s_axis_tdata[31:24];
```

**如何修改**（第二阶段）：
- 将反转逻辑替换为SAD计算
- 输入改为双通道（左图+右图）
- 输出改为视差值

#### `hardware/rtl/image_invert.v`
**作用**：简化的核心逻辑，仅供学习参考

**特点**：
- 没有AXI接口
- 只包含处理算法
- 不能直接在Vivado中使用

#### `hardware/sim/image_invert_axis_tb.v`
**作用**：Verilog仿真测试文件

**用途**：
- 在Vivado Simulator中验证模块功能
- 不需要实际硬件
- 可以查看波形

**如何使用**：
```tcl
# 在Vivado中
# 1. 添加testbench到仿真源
# 2. Run Simulation
# 3. Run All
# 4. 查看波形验证结果
```

### 3.3 软件文件（software/）

#### `software/python/fpga_image_processor.py` ⭐核心接口
**作用**：FPGA Python封装类

**主要类**：
```python
class FPGAImageProcessor:
    """FPGA图像处理器基类"""
    
    def __init__(self, bitstream_path):
        """加载FPGA配置"""
        
    def process_image(self, input_image):
        """
        处理图像
        
        参数：
            input_image: numpy数组, shape=(H,W), dtype=uint8
        
        返回：
            output_image: numpy数组, shape=(H,W), dtype=uint8
        """

class ImageInverter(FPGAImageProcessor):
    """图像反转器"""
    
    def invert(self, image):
        """反转图像"""
```

**队友如何使用**：
```python
from fpga_image_processor import ImageInverter

# 初始化
processor = ImageInverter('design_1.bit')

# 处理图像
result = processor.invert(input_image)

# 性能统计
stats = processor.get_performance_stats()
```

**第二阶段修改**：
```python
# 添加立体匹配类
class StereoMatcher(FPGAImageProcessor):
    def match(self, left_img, right_img):
        """
        立体匹配
        
        参数：
            left_img: 左图, shape=(H,W), dtype=uint8
            right_img: 右图, shape=(H,W), dtype=uint8
        
        返回：
            disparity: 视差图, shape=(H,W), dtype=uint8
        """
```

#### `software/python/test_fpga_invert.py`
**作用**：完整的测试脚本

**测试内容**：
- 基本功能（黑白灰图像）
- 真实图像测试
- 性能测试
- 边界情况测试

**运行方法**：
```bash
# SSH到PYNQ（可能失败）
python3 test_fpga_invert.py

# 推荐用Jupyter
# 上传文件后在notebook中运行
```

#### `software/python/stage1_test.ipynb` ⭐推荐
**作用**：Jupyter测试笔记本

**优点**：
- 交互式执行
- 可视化结果
- 逐步调试
- 环境兼容好

**使用方法**：
1. 上传到PYNQ的 `~/jupyter_notebooks/`
2. 访问 `http://192.168.2.99:9090`
3. 打开notebook
4. 逐个cell执行

#### `software/python/generate_test_images.py`
**作用**：生成测试图像

**生成内容**：
- 棋盘格、渐变、圆形、文字
- 不同尺寸（QQVGA, QVGA, VGA）
- 边界测试（全黑、全白）

**运行方法**：
```bash
python generate_test_images.py
# 生成 test_data/ 目录
```

#### `software/scripts/upload_to_pynq.bat`
**作用**：自动上传文件到PYNQ

**使用方法**：
```bash
# 双击运行或命令行执行
upload_to_pynq.bat
```

**上传内容**：
- Python脚本
- bitstream文件（.bit和.hwh）

---

## 四、给队友B的工作安排

### 4.1 你需要做的事情

#### 任务1：相机驱动（优先级：高）

**目标**：能够采集双目图像

**文件位置**：`software/python/camera_capture.py`（新建）

**接口定义**：
```python
class DualCamera:
    def __init__(self):
        """初始化双目摄像头"""
        
    def capture(self):
        """
        采集一对图像
        
        返回：
            left_img: 左图, shape=(H,W,3), dtype=uint8
            right_img: 右图, shape=(H,W,3), dtype=uint8
        """
        
    def release(self):
        """释放摄像头资源"""
```

**测试方法**：
```python
camera = DualCamera()
left, right = camera.capture()

# 保存图像验证
cv2.imwrite('left.jpg', left)
cv2.imwrite('right.jpg', right)
```

**参考资料**：
- Arducam官方文档
- OpenCV VideoCapture

#### 任务2：相机标定（优先级：高）

**目标**：获取相机内外参数

**文件位置**：`software/python/camera_calibration.py`（新建）

**需要输出**：
```yaml
# camera_params.yaml
left_camera:
  K: [[fx, 0, cx], [0, fy, cy], [0, 0, 1]]
  dist: [k1, k2, p1, p2, k3]

right_camera:
  K: [[fx, 0, cx], [0, fy, cy], [0, 0, 1]]
  dist: [k1, k2, p1, p2, k3]

stereo:
  R: [[...], [...], [...]]
  T: [tx, ty, tz]
  Q: [[...], [...], [...], [...]]  # 重投影矩阵
```

**标定步骤**：
1. 打印棋盘格标定板
2. 采集20-30组图像（不同角度）
3. 使用OpenCV标定函数
4. 保存参数到YAML文件

**参考代码**：
```python
import cv2

# 单目标定
ret, K, dist, rvecs, tvecs = cv2.calibrateCamera(
    object_points, image_points, image_size, None, None
)

# 双目标定
ret, K1, D1, K2, D2, R, T, E, F = cv2.stereoCalibrate(
    object_points, left_points, right_points, 
    K1, D1, K2, D2, image_size
)

# 立体校正
R1, R2, P1, P2, Q, roi1, roi2 = cv2.stereoRectify(
    K1, D1, K2, D2, image_size, R, T
)
```

#### 任务3：图像预处理（优先级：中）

**目标**：将采集的图像转换为FPGA可用格式

**文件位置**：`software/python/image_preprocessing.py`（新建）

**接口定义**：
```python
class ImagePreprocessor:
    def __init__(self, params_file):
        """加载标定参数"""
        
    def rectify(self, left_img, right_img):
        """
        校正图像（去畸变、对极对齐）
        
        返回：
            left_rect: 校正后左图
            right_rect: 校正后右图
        """
        
    def to_grayscale(self, img):
        """
        转换为灰度图
        
        返回：
            gray: 灰度图, shape=(H,W), dtype=uint8
        """
```

**处理流程**：
```python
preprocessor = ImagePreprocessor('camera_params.yaml')
camera = DualCamera()

# 采集
left_color, right_color = camera.capture()

# 校正
left_rect, right_rect = preprocessor.rectify(left_color, right_color)

# 转灰度
left_gray = preprocessor.to_grayscale(left_rect)
right_gray = preprocessor.to_grayscale(right_rect)

# 传给我的FPGA接口（第二阶段）
disparity = stereo_matcher.match(left_gray, right_gray)
```

#### 任务4：CPU版立体匹配（优先级：中）

**目标**：实现CPU版本的Block Matching，用于对比FPGA性能

**文件位置**：`software/python/cpu_stereo.py`（新建）

**接口定义**：
```python
def cpu_stereo_match(left_img, right_img, window_size=11, max_disparity=64):
    """
    CPU立体匹配（Block Matching）
    
    参数：
        left_img: 左图, shape=(H,W), dtype=uint8
        right_img: 右图, shape=(H,W), dtype=uint8
        window_size: SAD窗口大小（奇数）
        max_disparity: 最大视差搜索范围
    
    返回：
        disparity: 视差图, shape=(H,W), dtype=uint8
    """
```

**算法伪代码**：
```python
for each pixel (x, y) in left image:
    best_disparity = 0
    min_sad = infinity
    
    for d in range(0, max_disparity):
        if x - d < 0:
            break
            
        # 计算SAD
        sad = 0
        for i in range(-w, w+1):
            for j in range(-w, w+1):
                sad += abs(left[y+i][x+j] - right[y+i][x-d+j])
        
        if sad < min_sad:
            min_sad = sad
            best_disparity = d
    
    disparity[y][x] = best_disparity
```

**测试方法**：
```python
# 用Middlebury数据集测试
left = cv2.imread('Middlebury/Teddy/im2.png', 0)
right = cv2.imread('Middlebury/Teddy/im6.png', 0)

disparity = cpu_stereo_match(left, right)

cv2.imshow('Disparity', disparity)
cv2.waitKey(0)
```

#### 任务5：点云生成（优先级：低）

**目标**：将视差图转换为3D点云

**文件位置**：`software/python/point_cloud.py`（新建）

**接口定义**：
```python
def generate_point_cloud(disparity, Q_matrix, color_image=None):
    """
    生成点云
    
    参数：
        disparity: 视差图, shape=(H,W)
        Q_matrix: 重投影矩阵, shape=(4,4)
        color_image: 彩色图, shape=(H,W,3)（可选）
    
    返回：
        point_cloud: Open3D PointCloud对象
    """
    
    # 重投影到3D
    points_3d = cv2.reprojectImageTo3D(disparity, Q_matrix)
    
    # 转换为Open3D格式
    import open3d as o3d
    pcd = o3d.geometry.PointCloud()
    pcd.points = o3d.utility.Vector3dVector(points_3d.reshape(-1, 3))
    
    if color_image is not None:
        pcd.colors = o3d.utility.Vector3dVector(
            color_image.reshape(-1, 3) / 255.0
        )
    
    return pcd
```

**这个给队友C用**：
```python
# 队友B生成点云
pcd = generate_point_cloud(disparity, Q_matrix, left_color)

# 队友C显示
visualizer.update(pcd)
```

### 4.2 你需要提供给我的

#### 测试数据
- **双目图像对**：至少10组（不同场景）
- **格式**：PNG或JPG，放在 `test_data/stereo_pairs/`
- **命名**：
  ```
  test_data/stereo_pairs/
  ├── scene1_left.png
  ├── scene1_right.png
  ├── scene2_left.png
  ├── scene2_right.png
  ...
  ```

#### 标定参数
- **文件**：`camera_params.yaml`
- **位置**：`software/python/camera_params.yaml`

#### CPU性能基准
- **文件**：`cpu_benchmark.txt`
- **内容**：
  ```
  图像尺寸: 640x480
  算法: Block Matching (SAD 11x11, disparity 64)
  
  处理时间: 250ms
  帧率: 4fps
  
  期望FPGA加速: 5倍以上（目标50ms）
  ```

### 4.3 接口对接测试

**在你完成相机采集后**，我们一起测试：

```python
# 测试脚本（integration_test.py）

# 你的代码
from camera_capture import DualCamera
from image_preprocessing import ImagePreprocessor

# 我的代码
from fpga_image_processor import ImageInverter  # 第一阶段
# from fpga_image_processor import StereoMatcher  # 第二阶段（我会提供）

# 测试流程
camera = DualCamera()
preprocessor = ImagePreprocessor('camera_params.yaml')
processor = ImageInverter('design_1.bit')

# 采集
left, right = camera.capture()
print("✓ 相机采集成功")

# 预处理
left_rect, right_rect = preprocessor.rectify(left, right)
left_gray = preprocessor.to_grayscale(left_rect)
print("✓ 图像预处理成功")

# FPGA处理（当前只能测试单张图）
result = processor.invert(left_gray)
print("✓ FPGA处理成功")

# 第二阶段会是：
# disparity = stereo_matcher.match(left_gray, right_gray)
```

---

## 五、给队友C的工作安排

### 5.1 你需要做的事情

#### 任务1：点云可视化原型（优先级：高）

**目标**：能够显示3D点云

**文件位置**：`software/python/visualizer.py`（新建）

**接口定义**：
```python
class PointCloudVisualizer:
    def __init__(self):
        """初始化可视化窗口"""
        
    def update(self, point_cloud):
        """
        更新显示的点云
        
        参数：
            point_cloud: Open3D PointCloud对象
        """
        
    def run(self):
        """运行可视化循环"""
```

**基本实现**：
```python
import open3d as o3d

class PointCloudVisualizer:
    def __init__(self):
        self.vis = o3d.visualization.Visualizer()
        self.vis.create_window("3D Reconstruction")
        self.pcd = o3d.geometry.PointCloud()
        self.vis.add_geometry(self.pcd)
        
    def update(self, point_cloud):
        self.pcd.points = point_cloud.points
        self.pcd.colors = point_cloud.colors
        self.vis.update_geometry(self.pcd)
        self.vis.poll_events()
        self.vis.update_renderer()
        
    def run(self):
        self.vis.run()
```

**测试方法**：
```python
# 用假数据测试
import numpy as np

# 生成测试点云
points = np.random.rand(1000, 3)
colors = np.random.rand(1000, 3)

pcd = o3d.geometry.PointCloud()
pcd.points = o3d.utility.Vector3dVector(points)
pcd.colors = o3d.utility.Vector3dVector(colors)

# 显示
visualizer = PointCloudVisualizer()
visualizer.update(pcd)
visualizer.run()
```

#### 任务2：实时刷新（优先级：中）

**目标**：支持实时更新点云（30Hz）

**实现方法**：
```python
class RealtimeVisualizer:
    def __init__(self):
        self.vis = o3d.visualization.VisualizerWithKeyCallback()
        # 设置键盘回调
        self.vis.register_key_callback(ord("Q"), self.quit)
        
    def update_loop(self, point_cloud_generator):
        """
        实时更新循环
        
        参数：
            point_cloud_generator: 生成器，不断产生新点云
        """
        for pcd in point_cloud_generator:
            self.update(pcd)
            if not self.vis.poll_events():
                break
```

#### 任务3：交互控制（优先级：中）

**目标**：鼠标和键盘控制

**功能**：
-旋转视角
- 缩放
- 平移
- 重置视角
- 保存点云
- 任意键退出

**实现**：
```python
def register_callbacks(self):
    self.vis.register_key_callback(ord("R"), self.reset_view)
    self.vis.register_key_callback(ord("S"), self.save_pointcloud)
    self.vis.register_key_callback(ord("Q"), self.quit)
```

#### 任务4：性能监控UI（优先级：低）

**目标**：显示帧率、点云数量等信息

**可以用**：
- Open3D的文本渲染
- 或单独开一个tkinter窗口

**显示内容**：
```
FPS: 25.3
Points: 307200
Latency: 42ms
```

#### 任务5：数据录制（优先级：低）

**目标**：保存点云和视频

**接口定义**：
```python
class DataRecorder:
    def __init__(self, output_dir):
        """初始化录制器"""
        
    def start_recording(self):
        """开始录制"""
        
    def save_frame(self, point_cloud):
        """保存一帧"""
        
    def stop_recording(self):
        """停止录制，生成视频"""
```

**输出格式**：
- 点云：PLY文件序列
- 视频：MP4格式

### 5.2 你需要的输入（从队友B获取）

```python
# 队友B提供
from point_cloud import generate_point_cloud

# 你接收
def your_main_loop():
    while True:
        # 队友B生成点云
        pcd = generate_point_cloud(disparity, Q, color)
        
        # 你显示
        visualizer.update(pcd)
```

### 5.3 集成测试

**三人集成测试流程**：
```python
# 完整流程测试

# 队友B
camera = DualCamera()
preprocessor = ImagePreprocessor('camera_params.yaml')

# 我
stereo_matcher = StereoMatcher('stereo_matching.bit')

# 队友C
visualizer = RealtimeVisualizer()

# 主循环
while True:
    # B: 采集和预处理
    left, right = camera.capture()
    left_gray, right_gray = preprocessor.process(left, right)
    
    # 我: FPGA加速
    disparity = stereo_matcher.match(left_gray, right_gray)
    
    # B: 生成点云
    pcd = generate_point_cloud(disparity, Q, left)
    
    # C: 显示
    visualizer.update(pcd)
```

---

## 六、时间规划

### 当前阶段（第一阶段）：已完成 ✅

| 任务 | 负责人 | 状态 |
|-----|--------|------|
| FPGA数据通路验证 | 我 | ✅ 完成 |
| Vivado工程搭建 | 我 | ✅ 完成 |
| Python接口封装 | 我 | ✅ 完成 |

### 下一阶段（并行开展）：进行中 ⏳

| 任务 | 负责人 | 预计时间 | 优先级 |
|-----|--------|---------|--------|
| 相机驱动 | 队友B | 3天 | 🔥 高 |
| 相机标定 | 队友B | 2天 | 🔥 高 |
| 图像预处理 | 队友B | 2天 | 中 |
| CPU立体匹配 | 队友B | 3天 | 中 |
| 点云可视化 | 队友C | 3天 | 🔥 高 |
| 实时刷新 | 队友C | 2天 | 中 |
| SAD模块开发 | 我 | 7天 | 🔥 高 |

---

## 七、注意事项

### 7.1 代码规范

**文件命名**：
- 小写字母 + 下划线
- 例如：`camera_capture.py`

**函数命名**：
- 小写字母 + 下划线
- 例如：`generate_point_cloud()`

**类命名**：
- 驼峰命名法
- 例如：`DualCamera`

**注释**：
- 每个函数必须有docstring
- 参数和返回值要说明类型
- 例如：
```python
def process_image(input_image):
    """
    处理图像
    
    参数：
        input_image: numpy数组, shape=(H,W), dtype=uint8
    
    返回：
        output_image: numpy数组, shape=(H,W), dtype=uint8
    """
```

### 7.2 Git提交规范

**提交信息格式**：
```
类型: 简短描述

详细说明（可选）
```

**类型标签**：
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `test`: 测试相关
- `refactor`: 代码重构

**示例**：
```bash
git commit -m "feat: 实现双目相机采集功能

- 支持Arducam多相机适配器
- 添加同步采集接口
- 完成基本测试
"
```

### 7.3 测试要求

**每个模块必须有测试**：
- 单元测试：测试单个函数
- 集成测试：测试模块间接口
- 端到端测试：测试完整流程

**测试文件命名**：
- `test_模块名.py`
- 例如：`test_camera_capture.py`

### 7.4 文档要求

**每个模块必须有README**：
- 功能说明
- 使用方法
- 依赖项
- 示例代码

**位置**：
- 与模块同目录
- 例如：`software/python/camera/README.md`

---

## 八、常见问题

### Q: 我的代码放在哪里？
**A**: 
- 队友B: `software/python/` 目录
- 队友C: `software/python/` 目录
- 我: `hardware/` 目录

### Q: 如何测试我的代码？
**A**: 
1. 编写测试脚本 `test_xxx.py`
2. 上传到github给我运行

### Q: 我需要什么硬件？
**A**:
- 队友B: PYNQ开发板（测试用），双目摄像头（开发用）
- 队友C: 自己的电脑即可（不需要PYNQ）
- 我: PYNQ开发板 + Vivado软件

### Q: Git冲突怎么办？
**A**: 
1. 及时pull最新代码
2. 各自在不同文件工作（减少冲突）
3. 遇到冲突找我协调

### Q: 测试数据在哪里？
**A**: 
- 我提供的: `test_data/` 目录
- 队友B采集的: `test_data/stereo_pairs/`
- 公开数据集: Middlebury（自行下载）

---

## 十、总结

### 我做了什么
✅ 打通了FPGA-Python数据通路  
✅ 验证了硬件加速可行性  
✅ 提供了简单易用的Python接口  
✅ 建立了完整的开发工作流  

### 队友需要做什么

**队友B（图像处理）**：
1. 相机采集和标定（优先）
2. 图像预处理
3. CPU版立体匹配（对比用）
4. 点云生成函数

**队友C（可视化）**：
1. 点云显示（优先）
2. 实时刷新
3. 交互控制
4. 性能监控

### 下一步
- 队友B开始相机驱动开发
- 队友C开始可视化原型
- 我开始SAD模块设计
---

**版本**: v0.1.0-stage1  
**日期**: 2026-10-03 
