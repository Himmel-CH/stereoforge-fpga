"""
FPGA图像处理器 - Python封装类
功能：通过AXI DMA将图像数据发送到FPGA处理，并读回结果
"""

import numpy as np
from pynq import Overlay, allocate
import time

class FPGAImageProcessor:
    """FPGA图像处理器基类
    
    使用AXI DMA进行数据传输
    """
    
    def __init__(self, bitstream_path):
        """初始化FPGA
        
        Args:
            bitstream_path: .bit文件的路径
        """
        print(f"加载FPGA配置文件: {bitstream_path}")
        self.overlay = Overlay(bitstream_path)
        
        # 获取DMA控制器
        self.dma = self.overlay.axi_dma_0
        
        # 性能统计
        self.process_count = 0
        self.total_time = 0.0
        
        print("FPGA初始化完成")
        print(f"DMA发送通道: {self.dma.sendchannel}")
        print(f"DMA接收通道: {self.dma.recvchannel}")
    
    def process_image(self, input_image):
        """处理单张图像
        
        Args:
            input_image: numpy数组，shape=(H, W)，dtype=uint8
            
        Returns:
            output_image: numpy数组，shape=(H, W)，dtype=uint8
        """
        # 验证输入
        if input_image.dtype != np.uint8:
            raise ValueError(f"输入图像必须是uint8类型，当前是{input_image.dtype}")
        
        if len(input_image.shape) != 2:
            raise ValueError(f"输入图像必须是2D灰度图，当前shape={input_image.shape}")
        
        height, width = input_image.shape
        total_pixels = height * width
        
        # 确保数据大小是4字节对齐（DMA要求）
        if total_pixels % 4 != 0:
            # 填充到4的倍数
            padding = 4 - (total_pixels % 4)
            input_flat = np.pad(input_image.flatten(), (0, padding), mode='constant')
        else:
            input_flat = input_image.flatten()
        
        # 分配FPGA可访问的内存缓冲区
        input_buffer = allocate(shape=(len(input_flat),), dtype=np.uint8)
        output_buffer = allocate(shape=(len(input_flat),), dtype=np.uint8)
        
        # 复制数据到输入缓冲区
        input_buffer[:] = input_flat
        
        # 开始计时
        start_time = time.time()
        
        # 启动DMA传输
        self.dma.sendchannel.transfer(input_buffer)
        self.dma.recvchannel.transfer(output_buffer)
        
        # 等待传输完成
        self.dma.sendchannel.wait()
        self.dma.recvchannel.wait()
        
        # 结束计时
        end_time = time.time()
        process_time = (end_time - start_time) * 1000  # 转换为毫秒
        
        # 统计
        self.process_count += 1
        self.total_time += process_time
        
        # 提取结果并恢复原始形状
        output_flat = np.array(output_buffer[:total_pixels])
        output_image = output_flat.reshape(height, width)
        
        # 释放缓冲区
        input_buffer.freebuffer()
        output_buffer.freebuffer()
        
        print(f"处理完成: {process_time:.2f}ms ({width}x{height})")
        
        return output_image
    
    def get_performance_stats(self):
        """获取性能统计信息
        
        Returns:
            dict: 包含处理次数、平均时间、FPS等信息
        """
        if self.process_count == 0:
            return {
                'count': 0,
                'total_time_ms': 0,
                'avg_time_ms': 0,
                'fps': 0
            }
        
        avg_time = self.total_time / self.process_count
        fps = 1000.0 / avg_time if avg_time > 0 else 0
        
        return {
            'count': self.process_count,
            'total_time_ms': self.total_time,
            'avg_time_ms': avg_time,
            'fps': fps
        }
    
    def reset_stats(self):
        """重置性能统计"""
        self.process_count = 0
        self.total_time = 0.0
    
    def __del__(self):
        """析构函数：清理资源"""
        if hasattr(self, 'overlay'):
            print("释放FPGA资源")


class ImageInverter(FPGAImageProcessor):
    """图像反转处理器
    
    将灰度图像反转（output = 255 - input）
    """
    
    def __init__(self, bitstream_path):
        super().__init__(bitstream_path)
        print("图像反转模块已就绪")
    
    def invert(self, image):
        """反转图像
        
        Args:
            image: 输入灰度图像
            
        Returns:
            反转后的图像
        """
        return self.process_image(image)


if __name__ == "__main__":
    print("FPGA图像处理器模块")
    print("使用方法:")
    print("  from fpga_image_processor import ImageInverter")
    print("  processor = ImageInverter('design_1.bit')")
    print("  output = processor.invert(input_image)")
