module Control_Unit (
    input  [6:0] OP,
    input  [2:0] Funct3,
    input  [6:0] Funct7,

    output reg       RegWrite,
    output reg [1:0] ImmSrc,
    output reg       ULASrc,
    output reg [2:0] ULAControl,
    output reg       MemWrite,
    output reg       ResultSrc,
    output reg       Branch
);

    always @(*) begin
        // Valores seguros para instruções não reconhecidas.
        RegWrite   = 1'b0;
        ImmSrc     = 2'b00;
        ULASrc     = 1'b0;
        ULAControl = 3'b000;
        MemWrite   = 1'b0;
        ResultSrc  = 1'b0;
        Branch     = 1'b0;

        case (OP)
            // Instruções do tipo R: ADD, SUB, AND, OR e SLT.
            7'b0110011: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'bxx; // Não utilizado por instruções R.
                ULASrc    = 1'b0;
                MemWrite  = 1'b0;
                ResultSrc = 1'b0;
                Branch    = 1'b0;

                case (Funct3)
                    3'b000: begin
                        if (Funct7 == 7'b0100000)
                            ULAControl = 3'b001; // SUB
                        else
                            ULAControl = 3'b000; // ADD
                    end
                    3'b111: ULAControl = 3'b010; // AND
                    3'b110: ULAControl = 3'b011; // OR
                    3'b010: ULAControl = 3'b101; // SLT
                    default: ULAControl = 3'b000;
                endcase
            end

            // ADDI: imediato do tipo I.
            7'b0010011: begin
                RegWrite   = 1'b1;
                ImmSrc     = 2'b00;
                ULASrc     = 1'b1;
                ULAControl = 3'b000;
                MemWrite   = 1'b0;
                ResultSrc  = 1'b0;
                Branch     = 1'b0;
            end

            // LW: endereço = rs1 + imediato do tipo I.
            7'b0000011: begin
                RegWrite   = 1'b1;
                ImmSrc     = 2'b00;
                ULASrc     = 1'b1;
                ULAControl = 3'b000;
                MemWrite   = 1'b0;
                ResultSrc  = 1'b1;
                Branch     = 1'b0;
            end

            // SW: endereço = rs1 + imediato do tipo S.
            7'b0100011: begin
                RegWrite   = 1'b0;
                ImmSrc     = 2'b01;
                ULASrc     = 1'b1;
                ULAControl = 3'b000;
                MemWrite   = 1'b1;
                ResultSrc  = 1'bx; // Não há escrita no banco de registradores.
                Branch     = 1'b0;
            end

            // BEQ: compara rs1 e rs2 por subtração.
            7'b1100011: begin
                if (Funct3 == 3'b000) begin
                    RegWrite   = 1'b0;
                    ImmSrc     = 2'b10;
                    ULASrc     = 1'b0;
                    ULAControl = 3'b001; // SUB para gerar a flag Zero.
                    MemWrite   = 1'b0;
                    ResultSrc  = 1'bx;   // Não há escrita no banco.
                    Branch     = 1'b1;
                end
            end

            default: begin
                // Mantém os valores seguros definidos no início do bloco.
            end
        endcase
    end

endmodule
