module Instr_Mem (
    input  wire [9:0]  A,
    output reg  [31:0] RD
);

    always @(*) begin
        case (A)
            10'h000: RD = 32'h00700093; // addi x1, x0, 7
            10'h004: RD = 32'h00300193; // addi x3, x0, 3

            // init:
            10'h008: RD = 32'hFFF00113; // addi x2, x0, -1

            // incremento:
            10'h00C: RD = 32'h00110113; // addi x2, x2, 1
            10'h010: RD = 32'h003123B3; // slt  x7, x2, x3
            10'h014: RD = 32'hFE208AE3; // beq  x1, x2, init (-12)
            10'h018: RD = 32'hFE000AE3; // beq  x0, x0, incremento (-12)

            // NOP: addi x0, x0, 0
            default: RD = 32'h00000013;
        endcase
    end

endmodule
