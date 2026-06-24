
// ============================================================
// Decode ? Execute Pipeline Register
// Captures all Decode-stage outputs on posedge CLK
// Signal naming matches the datapath diagram exactly
// ============================================================
module decode_reg (
    input  wire        CLK,
    input  wire        Reset,   // synchronous reset
    input  wire        Flush,   // synchronous flush (for branch/jump hazards)

    // --- Control signals (Decode stage) ---
    input  wire        RegWriteD,
    input  wire [1:0]  ResultSrcD,
    input  wire        MemWriteD,
    input  wire        JumpD,
    input  wire        BranchD,
    input  wire [2:0]  ALUControlD,
    input  wire        ALUSrcD,

    // --- Datapath signals (Decode stage) ---
    input  wire [31:0] RD1,       // Register file read data 1
    input  wire [31:0] RD2,       // Register file read data 2
    input  wire [31:0] PCD,       // PC at Decode stage
    input  wire [4:0]  RdD,       // Destination register (InstrD[11:7])
    input  wire [31:0] ImmExtD,   // Sign-extended immediate
    input  wire [31:0] PCPlus4D,  // PC+4 at Decode stage

    // --- Control signals (Execute stage) ---
    output reg         RegWriteE,
    output reg  [1:0]  ResultSrcE,
    output reg         MemWriteE,
    output reg         JumpE,
    output reg         BranchE,
    output reg  [2:0]  ALUControlE,
    output reg         ALUSrcE,

    // --- Datapath signals (Execute stage) ---
    output reg  [31:0] RD1E,
    output reg  [31:0] RD2E,
    output reg  [31:0] PCE,
    output reg  [4:0]  RdE,
    output reg  [31:0] ImmExtE,
    output reg  [31:0] PCPlus4E
);

    always @(posedge CLK) begin
        if (Reset || Flush) begin
            // Clear all control signals to NOP state
            RegWriteE   <= 1'b0;
            ResultSrcE  <= 2'b00;
            MemWriteE   <= 1'b0;
            JumpE       <= 1'b0;
            BranchE     <= 1'b0;
            ALUControlE <= 3'b000;
            ALUSrcE     <= 1'b0;
            // Clear data path
            RD1E        <= 32'b0;
            RD2E        <= 32'b0;
            PCE         <= 32'b0;
            RdE         <= 5'b0;
            ImmExtE     <= 32'b0;
            PCPlus4E    <= 32'b0;
        end else begin
            // Control path
            RegWriteE   <= RegWriteD;
            ResultSrcE  <= ResultSrcD;
            MemWriteE   <= MemWriteD;
            JumpE       <= JumpD;
            BranchE     <= BranchD;
            ALUControlE <= ALUControlD;
            ALUSrcE     <= ALUSrcD;
            // Data path
            RD1E        <= RD1;
            RD2E        <= RD2;
            PCE         <= PCD;
            RdE         <= RdD;
            ImmExtE     <= ImmExtD;
            PCPlus4E    <= PCPlus4D;
        end
    end

endmodule