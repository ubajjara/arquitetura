module SignExtend (
    input      [31:0] instr,
    input      [1:0]  ImmSrc,
    output reg [31:0] imm_out
);

    reg [11:0] imm_I;
    reg [11:0] imm_S;
    reg [12:0] imm_B;

    always @(*) begin
        // Tipo I: imm[11:0] = instr[31:20]
        imm_I = instr[31:20];

        // Tipo S: imm[11:0] = {instr[31:25], instr[11:7]}
        imm_S = {instr[31:25], instr[11:7]};

        // Tipo B: imm[12:0] =
        // {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}
        imm_B = {instr[31], instr[7], instr[30:25],
                 instr[11:8], 1'b0};

        case (ImmSrc)
            2'b00: imm_out = {{20{imm_I[11]}}, imm_I}; // I
            2'b01: imm_out = {{20{imm_S[11]}}, imm_S}; // S
            2'b10: imm_out = {{19{imm_B[12]}}, imm_B}; // B
            default: imm_out = 32'b0;
        endcase
    end

endmodule
