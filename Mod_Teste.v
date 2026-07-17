`default_nettype none //Comando para desabilitar declaração automática de wires
module Mod_Teste (
//Clocks
input CLOCK_27, CLOCK_50,
//Chaves e Botoes
input [3:0] KEY,
input [17:0] SW,
//Displays de 7 seg e LEDs
output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
output [8:0] LEDG,
output [17:0] LEDR,
//Serial
output UART_TXD,
input UART_RXD,
inout [7:0] LCD_DATA,
output LCD_ON, LCD_BLON, LCD_RW, LCD_EN, LCD_RS,
//GPIO
inout [35:0] GPIO_0, GPIO_1
);
assign GPIO_1 = 36'hzzzzzzzzz;
assign GPIO_0 = 36'hzzzzzzzzz;
assign LCD_ON = 1'b1;
assign LCD_BLON = 1'b1;
wire [7:0] w_d0x0, w_d0x1, w_d0x2, w_d0x3, w_d0x4, w_d0x5,
w_d1x0, w_d1x1, w_d1x2, w_d1x3, w_d1x4, w_d1x5;
LCD_TEST MyLCD (
.iCLK ( CLOCK_50 ),
.iRST_N ( KEY[0] ),
.d0x0(w_d0x0),.d0x1(w_d0x1),.d0x2(w_d0x2),.d0x3(w_d0x3),.d0x4(w_d0x4),.d0x5(w_d0x5),
.d1x0(w_d1x0),.d1x1(w_d1x1),.d1x2(w_d1x2),.d1x3(w_d1x3),.d1x4(w_d1x4),.d1x5(w_d1x5),
.LCD_DATA( LCD_DATA ),
.LCD_RW ( LCD_RW ),
.LCD_EN ( LCD_EN ),
.LCD_RS ( LCD_RS )
);
//---------- modifique a partir daqui --------
// Setando os fios

    wire [31:0] w_PC;
    wire [31:0] w_PCp4;
    wire [31:0] w_ImmPC;
    wire [31:0] w_PCn;
    wire [31:0] w_Inst;

    wire [31:0] w_rd1SrcA;
    wire [31:0] w_rd2;
    wire [31:0] w_MImm;
    wire [31:0] w_SrcB;
    wire [31:0] w_ULAResult;
    wire [31:0] w_MemData;
    wire [31:0] w_RegData;
    wire [31:0] w_Wd3;

    wire        w_RegWrite;
    wire [1:0]  w_ImmSrc;
    wire        w_ULASrc;
    wire [2:0]  w_ULAControl;
    wire        w_MemWrite;
    wire        w_DMemWrite;
    wire        w_ResultSrc;
    wire        w_Branch;
    wire        w_Zero;
    wire        w_PCSrc;
    wire        w_IOSelect;
    wire        w_Clk10Hz;

    wire [7:0]  w_DataIn;
    wire [7:0]  w_DataOut;

    wire [31:0] w_x0, w_x1, w_x2, w_x3;
    wire [31:0] w_x4, w_x5, w_x6, w_x7;

    assign w_PCSrc = w_Branch & w_Zero;
    assign w_ImmPC = w_PC + w_MImm;

    // Endereco 0xFC reservado para entrada/saida mapeada em memoria.
    assign w_IOSelect  = (w_ULAResult == 32'h0000_00FC);
    assign w_DMemWrite = w_MemWrite & ~w_IOSelect;

    // Entrada paralela ligada diretamente as chaves SW[7:0].
    assign w_DataIn = SW[7:0];

    Div_Freq #(.DIVISOR(2_500_000)) FreqDiv (
        .clk_in(CLOCK_50),
        .clk_out(w_Clk10Hz)
    );

    assign LEDG = {8'b0, w_Clk10Hz};

    Mux MuxPCSrc (
        .in0(w_PCp4),
        .in1(w_ImmPC),
        .sel(w_PCSrc),
        .out(w_PCn)
    );

    reg_paralelo_4bits PC_reg (
        .clk(w_Clk10Hz),
        .rst_n(KEY[2]),
        .data_in(w_PCn),
        .q(w_PC)
    );

    Adder PC_adder (
        .lcd(w_PC),
        .w_p(w_PCp4)
    );

    // PROGRAM=1 executa o teste PAR/IMPAR.
    // Troque para PROGRAM=0 para executar o programa de testes A.
    Instr_Mem #(.PROGRAM(1)) IMem (
        .A(w_PC[9:0]),
        .RD(w_Inst)
    );

    Control_Unit CU (
        .OP(w_Inst[6:0]),
        .Funct3(w_Inst[14:12]),
        .Funct7(w_Inst[31:25]),
        .RegWrite(w_RegWrite),
        .ImmSrc(w_ImmSrc),
        .ULASrc(w_ULASrc),
        .ULAControl(w_ULAControl),
        .MemWrite(w_MemWrite),
        .ResultSrc(w_ResultSrc),
        .Branch(w_Branch)
    );

    RegisterFile RF (
        .wd3(w_Wd3),
        .wa3(w_Inst[11:7]),
        .we3(w_RegWrite),
        .clk(w_Clk10Hz),
        .rst(KEY[2]),
        .ra1(w_Inst[19:15]),
        .ra2(w_Inst[24:20]),
        .rd1(w_rd1SrcA),
        .rd2(w_rd2),
        .x0(w_x0), .x1(w_x1), .x2(w_x2), .x3(w_x3),
        .x4(w_x4), .x5(w_x5), .x6(w_x6), .x7(w_x7)
    );

    SignExtend SE (
        .instr(w_Inst),
        .ImmSrc(w_ImmSrc),
        .imm_out(w_MImm)
    );

    Mux MuxULASrc (
        .in0(w_rd2),
        .in1(w_MImm),
        .sel(w_ULASrc),
        .out(w_SrcB)
    );

    ULA ula_inst (
        .SrcA(w_rd1SrcA),
        .SrcB(w_SrcB),
        .ULAControl(w_ULAControl),
        .ULAResult(w_ULAResult),
        .Zero(w_Zero)
    );

    // A memoria de dados nao recebe escrita quando o endereco e 0xFC.
    Data_Mem DMem (
        .clk(w_Clk10Hz),
        .rst(KEY[2]),
        .WE(w_DMemWrite),
        .A(w_ULAResult[9:0]),
        .WD(w_rd2),
        .RD(w_MemData)
    );

    // Bloco de saida: SW em 0xFC atualiza DataOut.
    ParallelOUT POut (
        .clk(w_Clk10Hz),
        .rst(KEY[2]),
        .EN(w_MemWrite),
        .Address(w_ULAResult),
        .RegData(w_rd2),
        .DataOut(w_DataOut)
    );

    // Bloco de entrada: LW em 0xFC seleciona SW[7:0] em vez da RAM.
    ParallelIN PIn (
        .Address(w_ULAResult),
        .MemData(w_MemData),
        .DataIn(w_DataIn),
        .RegData(w_RegData)
    );

    Mux MuxResult (
        .in0(w_ULAResult),
        .in1(w_RegData),
        .sel(w_ResultSrc),
        .out(w_Wd3)
    );

    // LCD: primeira linha = x0, x1, x2, x3 e PC.
    assign w_d0x0 = w_x0[7:0];
    assign w_d0x1 = w_x1[7:0];
    assign w_d0x2 = w_x2[7:0];
    assign w_d0x3 = w_x3[7:0];
    assign w_d0x4 = w_PC[7:0];
    assign w_d0x5 = 8'b0;

    // LCD: segunda linha = x4, x5, x6, x7 e DataOut.
    assign w_d1x0 = w_x4[7:0];
    assign w_d1x1 = w_x5[7:0];
    assign w_d1x2 = w_x6[7:0];
    assign w_d1x3 = w_x7[7:0];
    assign w_d1x4 = w_DataOut;
    assign w_d1x5 = 8'b0;

    decodificador dec0 (.hexa(w_Inst[3:0]),   .seg(HEX0));
    decodificador dec1 (.hexa(w_Inst[7:4]),   .seg(HEX1));
    decodificador dec2 (.hexa(w_Inst[11:8]),  .seg(HEX2));
    decodificador dec3 (.hexa(w_Inst[15:12]), .seg(HEX3));
    decodificador dec4 (.hexa(w_Inst[19:16]), .seg(HEX4));
    decodificador dec5 (.hexa(w_Inst[23:20]), .seg(HEX5));
    decodificador dec6 (.hexa(w_Inst[27:24]), .seg(HEX6));
    decodificador dec7 (.hexa(w_Inst[31:28]), .seg(HEX7));

    assign LEDR = {6'b0, w_PCSrc, w_Zero, w_Branch, w_ResultSrc,
                   w_MemWrite, w_ULAControl, w_ULASrc, w_ImmSrc,
                   w_RegWrite};
endmodule

  
