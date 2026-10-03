# HP接口连接验证步骤

## 当前状态检查

1. **点击 Address Editor 标签**（在 Diagram 旁边）
   - 查看是否有 `S_AXI_HP0` 的地址映射
   - 确认 `axi_dma_0` 的 `M_AXI_MM2S` 和 `M_AXI_S2MM` 有地址

2. **检查连接**
   你需要确认以下连接存在：
   ```
   axi_dma_0.M_AXI_MM2S  →  axi_interconnect_1  →  processing_system7_0.S_AXI_HP0
   axi_dma_0.M_AXI_S2MM  →  axi_interconnect_1  →  processing_system7_0.S_AXI_HP0
   ```

## 如果HP接口未连接，手动连接步骤

### 方法1：使用Connection Automation（推荐）

1. 查看画布顶部是否有绿色提示：
   - "Designer Assistance available"
   - 点击 **Run Connection Automation**
   - 勾选所有未连接的接口
   - 点击 OK

### 方法2：手动配置AXI Interconnect

如果添加了新的 AXI Interconnect，需要配置：

1. **双击 axi_interconnect** 打开配置窗口

2. **配置参数**：
   - Number of Master Interfaces: 1（连接到PS的HP0）
   - Number of Slave Interfaces: 2（DMA的两个Master端口）
   - 点击 OK

3. **手动连线**：
   
   **连接Slave端（输入）**：
   - `axi_dma_0.M_AXI_MM2S` → `axi_interconnect_1.S00_AXI`
   - `axi_dma_0.M_AXI_S2MM` → `axi_interconnect_1.S01_AXI`
   
   **连接Master端（输出）**：
   - `axi_interconnect_1.M00_AXI` → `processing_system7_0.S_AXI_HP0`
   
   **连接时钟和复位**：
   - `axi_interconnect_1.ACLK` → 时钟源
   - `axi_interconnect_1.ARESETN` → 复位源

## 验证连接是否正确

1. **Validate Design**（按F6）
   - 应该显示 "Validation successful"
   - 如果有错误，查看错误信息

2. **查看 Address Editor**
   - 应该看到类似这样的地址分配：
   ```
   processing_system7_0/S_AXI_HP0
   ├── axi_dma_0/Data_MM2S  [0x00000000 - 0xFFFFFFFF]
   └── axi_dma_0/Data_S2MM  [0x00000000 - 0xFFFFFFFF]
   ```

## 你的截图分析

从你的截图来看：
- ✅ AXI Interconnect已经存在（右侧）
- ✅ 画布顶部有 "Designer Assistance available"

**下一步操作**：
1. 点击 **"Run Connection Automation"**
2. 勾选所有可用选项
3. 点击 OK
4. Vivado会自动完成剩余连接

如果还有问题，截图给我看 Address Editor 界面。
