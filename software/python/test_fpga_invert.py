"""
FPGA图像反转测试脚本
测试图像反转模块的功能和性能
"""

import numpy as np
import cv2
import matplotlib.pyplot as plt
from fpga_image_processor import ImageInverter
import time
import os

def test_basic_functionality(processor):
    """测试基本功能"""
    print("\n" + "="*60)
    print("测试1: 基本功能测试")
    print("="*60)
    
    # 创建简单的测试图像
    test_cases = [
        ("全黑图像", np.zeros((100, 100), dtype=np.uint8)),
        ("全白图像", np.full((100, 100), 255, dtype=np.uint8)),
        ("中灰图像", np.full((100, 100), 128, dtype=np.uint8)),
        ("渐变图像", np.linspace(0, 255, 100*100, dtype=np.uint8).reshape(100, 100))
    ]
    
    for name, test_img in test_cases:
        print(f"\n测试: {name}")
        result = processor.invert(test_img)
        
        # 验证结果
        expected = 255 - test_img
        if np.allclose(result, expected):
            print(f"✓ {name} - 通过")
        else:
            print(f"✗ {name} - 失败")
            print(f"  期望值范围: {expected.min()}-{expected.max()}")
            print(f"  实际值范围: {result.min()}-{result.max()}")


def test_real_image(processor, image_path):
    """测试真实图像"""
    print("\n" + "="*60)
    print("测试2: 真实图像测试")
    print("="*60)
    
    # 读取图像
    if os.path.exists(image_path):
        img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
        print(f"读取图像: {image_path}")
        print(f"图像尺寸: {img.shape}")
    else:
        print(f"图像文件不存在: {image_path}")
        print("创建测试图像...")
        # 创建一个测试图像（棋盘格）
        img = np.zeros((480, 640), dtype=np.uint8)
        for i in range(0, 480, 60):
            for j in range(0, 640, 80):
                if ((i//60) + (j//80)) % 2 == 0:
                    img[i:i+60, j:j+80] = 255
    
    # FPGA处理
    print("\nFPGA处理中...")
    result_fpga = processor.invert(img)
    
    # CPU处理（用于对比）
    print("CPU处理中...")
    start_time = time.time()
    result_cpu = 255 - img
    cpu_time = (time.time() - start_time) * 1000
    print(f"CPU处理时间: {cpu_time:.2f}ms")
    
    # 验证结果一致性
    if np.allclose(result_fpga, result_cpu):
        print("✓ FPGA结果与CPU结果一致")
    else:
        diff = np.abs(result_fpga.astype(int) - result_cpu.astype(int))
        print(f"✗ 结果不一致，最大差异: {diff.max()}")
    
    # 显示结果
    plt.figure(figsize=(15, 5))
    
    plt.subplot(131)
    plt.imshow(img, cmap='gray')
    plt.title('原始图像')
    plt.axis('off')
    
    plt.subplot(132)
    plt.imshow(result_fpga, cmap='gray')
    plt.title('FPGA处理结果')
    plt.axis('off')
    
    plt.subplot(133)
    plt.imshow(result_cpu, cmap='gray')
    plt.title('CPU处理结果')
    plt.axis('off')
    
    plt.tight_layout()
    plt.savefig('invert_result.png', dpi=100, bbox_inches='tight')
    print("结果已保存到: invert_result.png")
    
    return img, result_fpga


def test_performance(processor, sizes):
    """测试不同尺寸的性能"""
    print("\n" + "="*60)
    print("测试3: 性能测试")
    print("="*60)
    
    results = []
    
    for size in sizes:
        height, width = size
        print(f"\n测试尺寸: {width}x{height}")
        
        # 创建测试图像
        test_img = np.random.randint(0, 256, (height, width), dtype=np.uint8)
        
        # 重置统计
        processor.reset_stats()
        
        # 运行多次取平均
        num_runs = 10
        for i in range(num_runs):
            _ = processor.invert(test_img)
        
        # 获取统计信息
        stats = processor.get_performance_stats()
        
        results.append({
            'size': f"{width}x{height}",
            'pixels': width * height,
            'avg_time_ms': stats['avg_time_ms'],
            'fps': stats['fps']
        })
        
        print(f"  平均处理时间: {stats['avg_time_ms']:.2f}ms")
        print(f"  平均帧率: {stats['fps']:.2f}fps")
    
    # 显示性能对比表
    print("\n" + "-"*60)
    print(f"{'尺寸':<15} {'像素数':<12} {'处理时间(ms)':<15} {'帧率(fps)':<12}")
    print("-"*60)
    for r in results:
        print(f"{r['size']:<15} {r['pixels']:<12} {r['avg_time_ms']:<15.2f} {r['fps']:<12.2f}")
    print("-"*60)


def test_edge_cases(processor):
    """测试边界情况"""
    print("\n" + "="*60)
    print("测试4: 边界情况测试")
    print("="*60)
    
    test_cases = [
        ("极小图像", (10, 10)),
        ("窄图像", (100, 10)),
        ("宽图像", (10, 100)),
        ("不对齐", (101, 103))  # 不是4的倍数
    ]
    
    for name, size in test_cases:
        print(f"\n测试: {name} - {size[1]}x{size[0]}")
        test_img = np.random.randint(0, 256, size, dtype=np.uint8)
        
        try:
            result = processor.invert(test_img)
            expected = 255 - test_img
            if np.allclose(result, expected):
                print(f"✓ {name} - 通过")
            else:
                print(f"✗ {name} - 结果不匹配")
        except Exception as e:
            print(f"✗ {name} - 出错: {e}")


def main():
    """主测试流程"""
    print("="*60)
    print("FPGA图像反转模块完整测试")
    print("="*60)
    
    # 配置文件路径（根据实际情况修改）
    bitstream_path = "design_1.bit"
    test_image_path = "test.png"
    
    # 检查bitstream文件
    if not os.path.exists(bitstream_path):
        print(f"\n错误: 找不到bitstream文件: {bitstream_path}")
        print("请先在Vivado中生成bitstream，并将.bit和.hwh文件放在当前目录")
        return
    
    # 检查运行环境
    try:
        import pynq
        print(f"PYNQ版本: {pynq.__version__}")
    except:
        print("错误: 请在PYNQ环境中运行此脚本")
        return
    
    try:
        # 初始化FPGA
        processor = ImageInverter(bitstream_path)
        
        # 运行测试
        test_basic_functionality(processor)
        test_real_image(processor, test_image_path)
        
        # 性能测试 - 不同分辨率
        test_sizes = [
            (120, 160),   # QQVGA
            (240, 320),   # QVGA
            (480, 640),   # VGA
        ]
        test_performance(processor, test_sizes)
        
        test_edge_cases(processor)
        
        # 最终统计
        print("\n" + "="*60)
        print("测试完成")
        print("="*60)
        stats = processor.get_performance_stats()
        print(f"总处理次数: {stats['count']}")
        print(f"总处理时间: {stats['total_time_ms']:.2f}ms")
        
    except Exception as e:
        print(f"\n错误: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
