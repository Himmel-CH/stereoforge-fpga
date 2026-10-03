`timescale 1ns / 1ps

module tb_top;

    // 1. 声明信号：输入为 reg，输出为 wire
    reg a;
    reg b;
    wire c;
    wire d;

    // 2. 实例化被测模块 top
    top u_top (
        .a (a),
        .b (b),
        .c (c),
        .d (d)
    );

    // 3. 生成激励：遍历 a 和 b 的所有四种组合
    initial begin
        // 打印表头
        $display("Time\t a b | c d");
        $monitor("%0t\t %b %b | %b %b", $time, a, b, c, d);

        // 情况 1: a=0, b=0
        a = 0; b = 0;
        #10;

        // 情况 2: a=0, b=1
        a = 0; b = 1;
        #10;

        // 情况 3: a=1, b=0
        a = 1; b = 0;
        #10;

        // 情况 4: a=1, b=1
        a = 1; b = 1;
        #10;

        // 结束仿真
        $finish;
    end

endmodule