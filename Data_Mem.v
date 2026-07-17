module Data_Mem(
    input         clk,
    input         rst,   // reset assíncrono, ativo em borda de descida
    input         WE,    // write enable
    input  [9:0]  A,     // endereço (10 bits -> 1024 posições)
    input  [31:0] WD,    // dado de escrita
    output [31:0] RD     // dado de leitura
);

    ram1024x32 ram_inst (
		.address (A),
		.clock (clk),
		.data (WD),
		.wren (WE),
		.q (RD)
	 );
endmodule
