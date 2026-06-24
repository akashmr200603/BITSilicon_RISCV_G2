// ============================================================
// Decode Cycle Top-Level - RISC-V 32I Pipelined Processor
//
// Integrates:
//   1. Control Unit
//   2. Register File
//   3. Extender
//   4. Decode Stage Register (D/E pipeline register)
//
// External connections from Fetch stage:
//   InstrD, PCD, PCPlus4D
//
// External connections from Writeback stage (forwarded back):
//   RegWriteW, RDW (A3), ResultW (WD3)
//
// Outputs to Execute stage:
//   All *E signals
// ============================================================

`include "control_unit.v"
`include "register_file.v"
`include "extend.v"
`include "decode_reg.v"

module decode_cycle (
    input  wire        CLK,
    input  wire        Reset,    // synchronous reset
    input  wire        Flush,    // flush D/E register on branch/jump

    // ---------- Inputs from Fetch stage ----------
    input  wire [31:0] InstrD,
    input  wire [31:0] PCD,
    input  wire [31:0] PCPlus4D,

    // ---------- Inputs from Writeback stage ----------
    input  wire        RegWriteW,   // WE3 for register file
    input  wire [4:0]  RDW,         // Write address (A3)
    input  wire [31:0] ResultW,     // Write data (WD3)

    // ---------- Outputs to Execute stage (control) ----------
    output wire        RegWriteE,
    output wire [1:0]  ResultSrcE,
    output wire        MemWriteE,
    output wire        JumpE,
    output wire        BranchE,
    output wire [2:0]  ALUControlE,
    output wire        ALUSrcE,

    // ---------- Outputs to Execute stage (data) ----------
    output wire [31:0] RD1E,
    output wire [31:0] RD2E,
    output wire [31:0] PCE,
    output wire [4:0]  RdE,
    output wire [31:0] ImmExtE,
    output wire [31:0] PCPlus4E
);

    // --------------------------------------------------------
    // Internal wires - Decode stage signals
    // --------------------------------------------------------

    // Control Unit outputs
    wire        RegWriteD;
    wire [1:0]  ResultSrcD;
    wire        MemWriteD;
    wire        JumpD;
    wire        BranchD;
    wire [2:0]  ALUControlD;
    wire        ALUSrcD;
    wire [1:0]  ImmSrcD;

    // Register File outputs
    wire [31:0] RD1D;
    wire [31:0] RD2D;

    // Extender output
    wire [31:0] ImmExtD;

    // Instruction field slicing
    wire [6:0] op      = InstrD[6:0];
    wire [2:0] funct3  = InstrD[14:12];
    wire       funct7_5 = InstrD[30];
    wire [4:0] RdD     = InstrD[11:7];

    // --------------------------------------------------------
    // 1. Control Unit
    // --------------------------------------------------------
    control_unit u_ctrl (
        .op           (op),
        .funct3       (funct3),
        .funct7_5     (funct7_5),
        .RegWriteD    (RegWriteD),
        .ResultSrcD   (ResultSrcD),
        .MemWriteD    (MemWriteD),
        .JumpD        (JumpD),
        .BranchD      (BranchD),
        .ALUControlD  (ALUControlD),
        .ALUSrcD      (ALUSrcD),
        .ImmSrcD      (ImmSrcD)
    );

    // --------------------------------------------------------
    // 2. Register File
    // --------------------------------------------------------
    register_file u_rf (
        .CLK   (CLK),
        .Reset (Reset),
        .A1    (InstrD[19:15]),   // rs1
        .A2   (InstrD[24:20]),   // rs2
        .RD1  (RD1D),
        .RD2  (RD2D),
        .A3   (RDW),             // writeback destination
        .WD3  (ResultW),         // writeback data
        .WE3  (RegWriteW)        // writeback enable
    );

    // --------------------------------------------------------
    // 3. Extender
    // --------------------------------------------------------
    extend u_ext (
        .instr   (InstrD[31:7]),
        .ImmSrc  (ImmSrcD),
        .ImmExt  (ImmExtD)
    );

    // --------------------------------------------------------
    // 4. Decode Stage Register (D/E pipeline register)
    // --------------------------------------------------------
    decode_reg u_dreg (
        .CLK          (CLK),
        .Reset        (Reset),
        .Flush        (Flush),
        // Control in
        .RegWriteD    (RegWriteD),
        .ResultSrcD   (ResultSrcD),
        .MemWriteD    (MemWriteD),
        .JumpD        (JumpD),
        .BranchD      (BranchD),
        .ALUControlD  (ALUControlD),
        .ALUSrcD      (ALUSrcD),
        // Data in
        .RD1          (RD1D),
        .RD2          (RD2D),
        .PCD          (PCD),
        .RdD          (RdD),
        .ImmExtD      (ImmExtD),
        .PCPlus4D     (PCPlus4D),
        // Control out
        .RegWriteE    (RegWriteE),
        .ResultSrcE   (ResultSrcE),
        .MemWriteE    (MemWriteE),
        .JumpE        (JumpE),
        .BranchE      (BranchE),
        .ALUControlE  (ALUControlE),
        .ALUSrcE      (ALUSrcE),
        // Data out
        .RD1E         (RD1E),
        .RD2E         (RD2E),
        .PCE          (PCE),
        .RdE          (RdE),
        .ImmExtE      (ImmExtE),
        .PCPlus4E     (PCPlus4E)
    );

endmodule
