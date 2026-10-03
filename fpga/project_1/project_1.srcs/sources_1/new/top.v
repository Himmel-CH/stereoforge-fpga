module top(
    input wire a,
    input wire b,
    output wire c,
    output wire d
);

assign c = a & b;
assign d = a | b;

endmodule
