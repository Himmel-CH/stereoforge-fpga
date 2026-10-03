// ============================================================================
// 图像反转模块 - 核心处理逻辑
// 功能：将输入的灰度值反转（output = 255 - input）
// ============================================================================

module image_invert (
    input  wire        clk,           // 时钟信号
    input  wire        rst_n,         // 复位信号（低有效）
    input  wire [7:0]  pixel_in,      // 输入像素值（0-255）
    input  wire        valid_in,      // 输入数据有效信号
    output reg  [7:0]  pixel_out,     // 输出像素值
    output reg         valid_out      // 输出数据有效信号
);

// ============================================================================
// 主处理逻辑：反转像素值
// ============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pixel_out <= 8'd0;
        valid_out <= 1'b0;
    end else begin
        // 简单的组合逻辑：反转像素
        pixel_out <= 8'd255 - pixel_in;
        valid_out <= valid_in;
    end
end

endmodule
