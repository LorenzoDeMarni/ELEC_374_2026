module NRDivider(
    input signed [31:0] dividend,
    input signed [31:0] divisor,
    output reg signed [31:0] quotient,
    output reg signed [31:0] remainder
);
    integer i;
    reg signed [31:0] A_abs, B_abs;
    reg [31:0] q;
    reg signed [32:0] rem;
    reg sign_q;

    always @(*) begin
        if(divisor == 0) begin
            quotient  = 32'sd0;
            remainder = 32'sd0;
        end
        else begin
            A_abs = (dividend < 0) ? -dividend : dividend;
            B_abs = (divisor < 0) ? -divisor : divisor;
            sign_q = dividend[31] ^ divisor[31]; // if they have different signs then this is set to true to then change the sign of quotient

            rem = 32'sd0;
            q = 32'd0;
            for (i = 31; i >= 0; i = i - 1) begin
                // Shl remainder, add next bit of A_abs
                rem = {rem[31:0], A_abs[i]};
                if (rem >= 0)
                    rem = rem - B_abs;
                else
                    rem = rem + B_abs;
                if (rem >= 0)
                    q[i] = 1'b1;
                else
                    q[i] = 1'b0;
            end

            if (rem < 0)
                rem = rem + B_abs;

            quotient  = sign_q ? -q : q;
            remainder = (dividend < 0) ? -rem[31:0] : rem[31:0];
        end
    end
endmodule
