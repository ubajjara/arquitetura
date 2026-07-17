module Div_Freq #(
    // CLOCK_50 / (2 * 2_500_000) = 10 Hz
    parameter integer DIVISOR = 2_500_000
) (
    input  wire clk_in,
    output reg  clk_out
);

    reg [24:0] counter;

    initial begin
        counter = 25'd0;
        clk_out = 1'b0;
    end

    always @(posedge clk_in) begin
        if (counter == DIVISOR - 1) begin
            counter <= 25'd0;
            clk_out <= ~clk_out;
        end
        else begin
            counter <= counter + 1'b1;
        end
    end
endmodule
