module ULA (
    input  [31:0] SrcA,
    input  [31:0] SrcB,
    input  [2:0]  ULAControl,

    output reg [31:0] ULAResult,
    output            Zero
);

    always @(*) begin
        case (ULAControl)
            3'b000: ULAResult = SrcA + SrcB;                   // ADD
            3'b001: ULAResult = SrcA - SrcB;                   // SUB
            3'b010: ULAResult = SrcA & SrcB;                   // AND
            3'b011: ULAResult = SrcA | SrcB;                   // OR
            3'b101: ULAResult = ($signed(SrcA) < $signed(SrcB))
                               ? 32'd1 : 32'd0;                // SLT assinado
            default: ULAResult = 32'd0;
        endcase
    end

    // Em BEQ, a unidade de controle seleciona SUB. Portanto, Zero = 1
    // exatamente quando os dois registradores comparados são iguais.
    assign Zero = (ULAResult == 32'd0);

endmodule
