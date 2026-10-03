// ============================================================================
// AXI4-Stream 图像反转包装器
// 功能：将核心处理模块封装为AXI4-Stream接口，用于与DMA连接
// ============================================================================

module image_invert_axis #(
    parameter integer C_AXIS_TDATA_WIDTH = 32  // AXI Stream数据宽度（32位 = 4字节）
)(
    // 全局信号
    input  wire                                 aclk,          // AXI时钟
    input  wire                                 aresetn,       // AXI复位（高有效）
    
    // AXI4-Stream 从接口（接收数据）
    input  wire [C_AXIS_TDATA_WIDTH-1:0]       s_axis_tdata,  // 输入数据
    input  wire                                 s_axis_tvalid, // 输入数据有效
    output wire                                 s_axis_tready, // 准备接收数据
    input  wire                                 s_axis_tlast,  // 最后一个数据
    
    // AXI4-Stream 主接口（发送数据）
    output reg  [C_AXIS_TDATA_WIDTH-1:0]       m_axis_tdata,  // 输出数据
    output reg                                  m_axis_tvalid, // 输出数据有效
    input  wire                                 m_axis_tready, // 对方准备接收
    output reg                                  m_axis_tlast   // 最后一个数据
);

// ============================================================================
// 内部信号
// ============================================================================
reg tlast_reg;  // 缓存tlast信号

// ============================================================================
// AXI4-Stream 握手逻辑
// 当我们准备好接收且对方准备好发送时，数据有效
// ============================================================================
assign s_axis_tready = m_axis_tready;  // 直通模式：我们总是准备好接收

// ============================================================================
// 数据处理逻辑
// 处理32位数据中的每个字节（4个像素）
// ============================================================================
always @(posedge aclk) begin
    if (!aresetn) begin
        m_axis_tdata  <= 32'd0;
        m_axis_tvalid <= 1'b0;
        m_axis_tlast  <= 1'b0;
        tlast_reg     <= 1'b0;
    end else begin
        if (s_axis_tvalid && s_axis_tready) begin
            // 处理每个字节（每个字节是一个像素）
            m_axis_tdata[7:0]   <= 8'd255 - s_axis_tdata[7:0];    // Byte 0
            m_axis_tdata[15:8]  <= 8'd255 - s_axis_tdata[15:8];   // Byte 1
            m_axis_tdata[23:16] <= 8'd255 - s_axis_tdata[23:16];  // Byte 2
            m_axis_tdata[31:24] <= 8'd255 - s_axis_tdata[31:24];  // Byte 3
            
            m_axis_tvalid <= 1'b1;
            m_axis_tlast  <= s_axis_tlast;
        end else if (m_axis_tready) begin
            m_axis_tvalid <= 1'b0;
        end
    end
end

endmodule
