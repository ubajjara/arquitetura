module ParallelOUT (
    input  wire        clk,
    input  wire        rst,
    input  wire        EN,
    input  wire [31:0] Address,
    input  wire [31:0] RegData,
    output reg  [7:0]  DataOut
);

    wire selected;
    assign selected = (Address == 32'h0000_00FC);

    // SW para 0xFC grava somente os 8 bits menos significativos na porta.
    always @(posedge clk or negedge rst) begin
        if (!rst)
            DataOut <= 8'b0;
        else if (EN && selected)
            DataOut <= RegData[7:0];
    end
endmodule
