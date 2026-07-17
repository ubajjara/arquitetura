module ParallelIN (
    input  wire [31:0] Address,
    input  wire [31:0] MemData,
    input  wire [7:0]  DataIn,
    output wire [31:0] RegData
);

    wire selected;
    assign selected = (Address == 32'h0000_00FC);

    // LW de 0xFC retorna a entrada paralela com extensao por zeros.
    assign RegData = selected ? {24'b0, DataIn} : MemData;
endmodule
