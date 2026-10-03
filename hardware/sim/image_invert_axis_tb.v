// ============================================================================
// Testbench for image_invert_axis module
// 测试AXI4-Stream图像反转模块
// ============================================================================

`timescale 1ns / 1ps

module image_invert_axis_tb;

// ============================================================================
// 参数定义
// ============================================================================
parameter C_AXIS_TDATA_WIDTH = 32;
parameter CLK_PERIOD = 10;  // 10ns = 100MHz

// ============================================================================
// 信号声明
// ============================================================================
reg                                 aclk;
reg                                 aresetn;
reg  [C_AXIS_TDATA_WIDTH-1:0]      s_axis_tdata;
reg                                 s_axis_tvalid;
wire                                s_axis_tready;
reg                                 s_axis_tlast;
wire [C_AXIS_TDATA_WIDTH-1:0]      m_axis_tdata;
wire                                m_axis_tvalid;
reg                                 m_axis_tready;
wire                                m_axis_tlast;

// 测试数据
integer i;
reg [7:0] test_pixels [0:15];  // 16个测试像素

// ============================================================================
// 实例化被测试模块
// ============================================================================
image_invert_axis #(
    .C_AXIS_TDATA_WIDTH(C_AXIS_TDATA_WIDTH)
) uut (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast)
);

// ============================================================================
// 时钟生成：100MHz
// ============================================================================
initial begin
    aclk = 0;
    forever #(CLK_PERIOD/2) aclk = ~aclk;
end

// ============================================================================
// 测试流程
// ============================================================================
initial begin
    // 初始化测试数据：一些典型的灰度值
    test_pixels[0]  = 8'd0;     // 黑色 -> 应该变成255
    test_pixels[1]  = 8'd255;   // 白色 -> 应该变成0
    test_pixels[2]  = 8'd128;   // 中灰 -> 应该变成127
    test_pixels[3]  = 8'd64;    // -> 应该变成191
    test_pixels[4]  = 8'd100;
    test_pixels[5]  = 8'd150;
    test_pixels[6]  = 8'd200;
    test_pixels[7]  = 8'd50;
    test_pixels[8]  = 8'd75;
    test_pixels[9]  = 8'd125;
    test_pixels[10] = 8'd175;
    test_pixels[11] = 8'd225;
    test_pixels[12] = 8'd10;
    test_pixels[13] = 8'd20;
    test_pixels[14] = 8'd30;
    test_pixels[15] = 8'd40;
    
    // 初始化信号
    aresetn = 0;
    s_axis_tdata = 0;
    s_axis_tvalid = 0;
    s_axis_tlast = 0;
    m_axis_tready = 1;  // 接收端准备好
    
    // 等待几个时钟周期
    #(CLK_PERIOD*5);
    
    // 释放复位
    aresetn = 1;
    #(CLK_PERIOD*2);
    
    $display("========================================");
    $display("开始测试 Image Invert Module");
    $display("========================================");
    
    // 发送4组数据（每组4个字节 = 4个像素）
    for (i = 0; i < 4; i = i + 1) begin
        @(posedge aclk);
        s_axis_tvalid = 1;
        
        // 打包4个像素到32位数据
        s_axis_tdata = {test_pixels[i*4+3], test_pixels[i*4+2], 
                        test_pixels[i*4+1], test_pixels[i*4]};
        
        // 最后一组数据设置tlast
        if (i == 3)
            s_axis_tlast = 1;
        else
            s_axis_tlast = 0;
            
        $display("时间 %0t: 发送数据[%0d] = 0x%08h (像素: %3d %3d %3d %3d)", 
                 $time, i, s_axis_tdata,
                 test_pixels[i*4], test_pixels[i*4+1], 
                 test_pixels[i*4+2], test_pixels[i*4+3]);
        
        // 等待握手完成
        wait(s_axis_tready);
        @(posedge aclk);
    end
    
    // 停止发送
    s_axis_tvalid = 0;
    s_axis_tlast = 0;
    
    // 等待所有输出完成
    #(CLK_PERIOD*10);
    
    $display("========================================");
    $display("测试完成");
    $display("========================================");
    
    $finish;
end

// ============================================================================
// 输出监控
// ============================================================================
always @(posedge aclk) begin
    if (m_axis_tvalid && m_axis_tready) begin
        $display("时间 %0t: 接收数据 = 0x%08h (像素: %3d %3d %3d %3d) %s", 
                 $time, m_axis_tdata,
                 m_axis_tdata[7:0], m_axis_tdata[15:8],
                 m_axis_tdata[23:16], m_axis_tdata[31:24],
                 m_axis_tlast ? "[LAST]" : "");
        
        // 验证结果
        if (m_axis_tdata[7:0] != (8'd255 - test_pixels[(i-1)*4])) begin
            $display("错误：Byte 0 不匹配！");
        end
    end
end

// ============================================================================
// 超时保护
// ============================================================================
initial begin
    #(CLK_PERIOD*1000);
    $display("错误：测试超时！");
    $finish;
end

// ============================================================================
// 波形文件生成（用于GTKWave或Vivado查看）
// ============================================================================
initial begin
    $dumpfile("image_invert_axis_tb.vcd");
    $dumpvars(0, image_invert_axis_tb);
end

endmodule
