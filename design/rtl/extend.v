
// ============================================================
// Extender - RISC-V 32I Immediate Sign Extension
// Input:  ImmSrcD[1:0], InstrD[31:7]
// Output: ImmExtD (32-bit sign-extended immediate)
//
// ImmSrcD encoding:
//   00 -> I-type
//   01 -> S-type
//   10 -> B-type
//   11 -> J-type
// ============================================================
module extend (
    input  wire [31:7] instr,    // InstrD[31:7]
    input  wire [1:0]  ImmSrc,   // ImmSrcD

    output reg  [31:0] ImmExt    // ImmExtD
);

    always @(*) begin
        case (ImmSrc)
            // I-type: instr[31:20]
            2'b00: ImmExt = {{20{instr[31]}}, instr[31:20]};

            // S-type: instr[31:25], instr[11:7]
            2'b01: ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type: instr[31], instr[7], instr[30:25], instr[11:8], 1'b0
            2'b10: ImmExt = {{20{instr[31]}}, instr[7], instr[30:25],
                              instr[11:8], 1'b0};

            // J-type: instr[31], instr[19:12], instr[20], instr[30:21], 1'b0
            2'b11: ImmExt = {{12{instr[31]}}, instr[19:12], instr[20],
                              instr[30:21], 1'b0};

            default: ImmExt = 32'b0;
        endcase
    end

endmodule