// led_blink.v
module led_blink(
    input wire clk,           // 125MHz时钟
    input wire rst_n,         // 复位信号（低有效）
    output reg [3:0] led      // 4个LED
);

reg [26:0] counter;  // 27位计数器（约1秒）

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 0;
        led <= 4'b0001;
    end else begin
        counter <= counter + 1;
        if (counter == 27'd125_000_000) begin  // 1秒到
            counter <= 0;
            led <= {led[2:0], led[3]};  // 循环移位
        end
    end
end

endmodule
