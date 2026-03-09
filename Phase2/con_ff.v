module con_ff(
    input wire clk,
    input wire clr,
    input wire CONin,
    input wire [31:0] Bus,
    input wire [1:0] IR_20_19,
    output reg CON
);



reg conditional_result;
always @(*) begin
    case (IR_20_19)
        2'b00: conditional_result = (Bus == 32'b0);
        2'b01: conditional_result = (Bus != 32'b0);
        2'b10: conditional_result = (Bus[31] == 1'b0);
        2'b11: conditional_result = (Bus[31] == 1'b1);
        default: conditional_result = 1'b0;
    endcase
end

always @(posedge clk) begin
    if (clr)
        CON <= 1'b0;
    else if (CONin)
        CON <= conditional_result;
end


endmodule