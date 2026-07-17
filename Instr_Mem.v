module Instr_Mem #(
    // PROGRAM = 0: teste A (copia SW[7:0] para a saida paralela)
    // PROGRAM = 1: teste PAR/IMPAR pedido na Sprint 9
    parameter integer PROGRAM = 1
) (
    input  wire [9:0]  A,
    output reg  [31:0] RD
);

    always @(*) begin
        RD = 32'h00000013; // NOP: addi x0, x0, 0

        if (PROGRAM == 0) begin
            // Programa de testes A:
            // init:
            //   lw  x1, 0xFC(x0)
            //   sw  x1, 0xFC(x0)
            //   beq x0, x0, init
            case (A)
                10'h000: RD = 32'h0FC02083; // lw  x1, 252(x0)
                10'h004: RD = 32'h0E102E23; // sw  x1, 252(x0)
                10'h008: RD = 32'hFE000CE3; // beq x0, x0, -8
                default: RD = 32'h00000013;
            endcase
        end
        else begin
            // Programa PAR/IMPAR:
            // loop:
            //   lw   x1, 0xFC(x0)  // x1 = entrada
            //   addi x2, x0, 1     // mascara e valor "par"
            //   and  x3, x1, x2    // x3 = bit menos significativo
            //   sub  x4, x2, x3    // par: 1-0=1; impar: 1-1=0
            //   sw   x4, 0xFC(x0)  // envia resultado para DataOut
            //   beq  x0, x0, loop
            case (A)
                10'h000: RD = 32'h0FC02083; // lw   x1, 252(x0)
                10'h004: RD = 32'h00100113; // addi x2, x0, 1
                10'h008: RD = 32'h0020F1B3; // and  x3, x1, x2
                10'h00C: RD = 32'h40310233; // sub  x4, x2, x3
                10'h010: RD = 32'h0E402E23; // sw   x4, 252(x0)
                10'h014: RD = 32'hFE0006E3; // beq  x0, x0, -20
                default: RD = 32'h00000013;
            endcase
        end
    end
endmodule
