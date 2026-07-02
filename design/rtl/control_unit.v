// ============================================================
// Control Unit - RISC-V 32I Decode Stage
// Inputs: op[6:0], funct3[2:0], funct7[5]
// Outputs: all decode-stage control signals
// ============================================================
module control_unit (
    input  wire [6:0] op,
    input  wire [2:0] funct3,
    input  wire       funct7_5,

    output reg        RegWriteD,
    output reg [1:0]  ResultSrcD,
    output reg        MemWriteD,
    output reg        JumpD,
    output reg        BranchD,
    output reg [2:0]  ALUControlD,
    output reg        ALUSrcD,
    output reg [1:0]  ImmSrcD
);

    // ALU operation intermediate
    reg [1:0] ALUOpD;

    // --------------------------------------------------------
    // Main Decoder
    // --------------------------------------------------------
    always @(*) begin
        // Defaults
        RegWriteD  = 1'b0;
        ImmSrcD    = 2'b00;
        ALUSrcD    = 1'b0;
        MemWriteD  = 1'b0;
        ResultSrcD = 2'b00;
        BranchD    = 1'b0;
        ALUOpD     = 2'b00;
        JumpD      = 1'b0;

        case (op)
            7'b0000011: begin // lw  (I-type load)
                RegWriteD  = 1'b1;
                ImmSrcD    = 2'b00;
                ALUSrcD    = 1'b1;
                MemWriteD  = 1'b0;
                ResultSrcD = 2'b01;
                BranchD    = 1'b0;
                ALUOpD     = 2'b00;
                JumpD      = 1'b0;
            end
            7'b0100011: begin // sw  (S-type store)
                RegWriteD  = 1'b0;
                ImmSrcD    = 2'b01;
                ALUSrcD    = 1'b1;
                MemWriteD  = 1'b1;
                ResultSrcD = 2'b00;
                BranchD    = 1'b0;
                ALUOpD     = 2'b00;
                JumpD      = 1'b0;
            end
            7'b0110011: begin // R-type
                RegWriteD  = 1'b1;
                ImmSrcD    = 2'b00; // don't care
                ALUSrcD    = 1'b0;
                MemWriteD  = 1'b0;
                ResultSrcD = 2'b00;
                BranchD    = 1'b0;
                ALUOpD     = 2'b10;
                JumpD      = 1'b0;
            end
            7'b1100011: begin // beq (B-type)
                RegWriteD  = 1'b0;
                ImmSrcD    = 2'b10;
                ALUSrcD    = 1'b0;
                MemWriteD  = 1'b0;
                ResultSrcD = 2'b00;
                BranchD    = 1'b1;
                ALUOpD     = 2'b01;
                JumpD      = 1'b0;
            end
            7'b0010011: begin // I-type ALU (addi, etc.)
                RegWriteD  = 1'b1;
                ImmSrcD    = 2'b00;
                ALUSrcD    = 1'b1;
                MemWriteD  = 1'b0;
                ResultSrcD = 2'b00;
                BranchD    = 1'b0;
                ALUOpD     = 2'b10;
                JumpD      = 1'b0;
            end
            7'b1101111: begin // jal (J-type)
                RegWriteD  = 1'b1;
                ImmSrcD    = 2'b11;
                ALUSrcD    = 1'b0; // don't care
                MemWriteD  = 1'b0;
                ResultSrcD = 2'b10;
                BranchD    = 1'b0;
                ALUOpD     = 2'b00; // don't care
                JumpD      = 1'b1;
            end
            default: begin
                RegWriteD  = 1'b0;
                ImmSrcD    = 2'b00;
                ALUSrcD    = 1'b0;
                MemWriteD  = 1'b0;
                ResultSrcD = 2'b00;
                BranchD    = 1'b0;
                ALUOpD     = 2'b00;
                JumpD      = 1'b0;
            end
        endcase
    end

    // --------------------------------------------------------
    // ALU Decoder
    // --------------------------------------------------------
    always @(*) begin
        case (ALUOpD)
            2'b00: ALUControlD = 3'b000; // add (lw/sw)
            2'b01: ALUControlD = 3'b001; // sub (beq)
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        // add / sub distinguished by funct7[5] for R-type
                        if (funct7_5 & (op == 7'b0110011))
                            ALUControlD = 3'b001; // sub
                        else
                            ALUControlD = 3'b000; // add / addi
                    end
                    3'b010: ALUControlD = 3'b101; // slt
                    3'b110: ALUControlD = 3'b011; // or
                    3'b111: ALUControlD = 3'b010; // and
                    default: ALUControlD = 3'b000;
                endcase
            end
            default: ALUControlD = 3'b000;
        endcase
    end

endmodule
