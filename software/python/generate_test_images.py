"""
生成测试图像
创建各种测试用的灰度图像
"""

import numpy as np
import cv2
import os

def create_test_images():
    """创建测试图像集"""
    
    # 创建输出目录
    os.makedirs('test_images', exist_ok=True)
    
    print("生成测试图像...")
    
    # 1. 棋盘格图像（经典测试图案）
    checkerboard = np.zeros((480, 640), dtype=np.uint8)
    square_size = 60
    for i in range(0, 480, square_size):
        for j in range(0, 640, square_size):
            if ((i//square_size) + (j//square_size)) % 2 == 0:
                checkerboard[i:i+square_size, j:j+square_size] = 255
    cv2.imwrite('test_images/checkerboard.png', checkerboard)
    print("[OK] 生成棋盘格图像: test_images/checkerboard.png")
    
    # 2. 渐变图像
    gradient = np.linspace(0, 255, 640, dtype=np.uint8)
    gradient = np.tile(gradient, (480, 1))
    cv2.imwrite('test_images/gradient.png', gradient)
    print("[OK] 生成渐变图像: test_images/gradient.png")
    
    # 3. 圆形图案
    circle = np.zeros((480, 640), dtype=np.uint8)
    cv2.circle(circle, (320, 240), 150, 255, -1)
    cv2.circle(circle, (320, 240), 100, 128, -1)
    cv2.circle(circle, (320, 240), 50, 64, -1)
    cv2.imwrite('test_images/circles.png', circle)
    print("[OK] 生成圆形图像: test_images/circles.png")
    
    # 4. 文字图像
    text_img = np.zeros((480, 640), dtype=np.uint8)
    font = cv2.FONT_HERSHEY_SIMPLEX
    cv2.putText(text_img, 'FPGA', (100, 150), font, 4, 255, 8)
    cv2.putText(text_img, 'IMAGE', (80, 300), font, 4, 200, 8)
    cv2.putText(text_img, 'PROCESSING', (20, 450), font, 3, 150, 6)
    cv2.imwrite('test_images/text.png', text_img)
    print("[OK] 生成文字图像: test_images/text.png")
    
    # 5. 随机噪声
    noise = np.random.randint(0, 256, (480, 640), dtype=np.uint8)
    cv2.imwrite('test_images/noise.png', noise)
    print("[OK] 生成噪声图像: test_images/noise.png")
    
    # 6. Lena测试图（如果没有就用简单图案代替）
    try:
        # 尝试生成Lena图
        # 注意：OpenCV 4.x已移除cv2.data.haarcascades，这里用自定义图案
        lena = np.zeros((480, 640), dtype=np.uint8)
        # 创建类似人脸的简化图案
        cv2.ellipse(lena, (320, 240), (120, 150), 0, 0, 360, 200, -1)  # 脸
        cv2.ellipse(lena, (280, 200), (20, 30), 0, 0, 360, 100, -1)    # 左眼
        cv2.ellipse(lena, (360, 200), (20, 30), 0, 0, 360, 100, -1)    # 右眼
        cv2.ellipse(lena, (320, 280), (40, 20), 0, 0, 180, 150, 3)     # 嘴
        cv2.imwrite('test_images/face.png', lena)
        print("[OK] 生成人脸图像: test_images/face.png")
    except:
        print("[WARN] 无法生成人脸图像，跳过")
    
    # 7. 边缘测试（全黑、全白、中灰）
    black = np.zeros((480, 640), dtype=np.uint8)
    cv2.imwrite('test_images/black.png', black)
    
    white = np.full((480, 640), 255, dtype=np.uint8)
    cv2.imwrite('test_images/white.png', white)
    
    gray = np.full((480, 640), 128, dtype=np.uint8)
    cv2.imwrite('test_images/gray128.png', gray)
    
    print("[OK] 生成边界测试图像: black.png, white.png, gray128.png")
    
    # 8. 不同尺寸的测试图像
    sizes = [
        (120, 160, "qqvga"),
        (240, 320, "qvga"),
        (480, 640, "vga"),
    ]
    
    for h, w, name in sizes:
        img = np.random.randint(0, 256, (h, w), dtype=np.uint8)
        cv2.imwrite(f'test_images/test_{name}_{w}x{h}.png', img)
    print("[OK] 生成不同尺寸测试图像")
    
    print(f"\n总共生成 {len(os.listdir('test_images'))} 张测试图像")
    print("测试图像保存在: test_images/")

if __name__ == "__main__":
    create_test_images()
