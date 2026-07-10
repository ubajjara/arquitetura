module Div_Freq (
    input  wire clk_in,   // CLOCK_50 = 50 MHz
    output reg  clk_out   // saída = 2 Hz
);

    // 50.000.000 / (2 * 12.500.000) = 2 Hz
    parameter DIVISOR = 12_500_000;

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
