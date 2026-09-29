#!/usr/bin/env python3
# 测试脚本 - 在PYNQ板子上运行

print("=" * 50)
print("Hello from PYNQ Board!")
print("=" * 50)

import sys
import platform

print(f"\nPython版本: {sys.version}")
print(f"平台: {platform.platform()}")
print(f"处理器: {platform.processor()}")
print(f"架构: {platform.machine()}")

# 测试简单计算
numbers = [1, 2, 3, 4, 5]
result = sum(numbers)
print(f"\n计算测试: sum({numbers}) = {result}")

print("\n测试完成!")
