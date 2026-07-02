// ============================================================
// Hazard Unit - RISC-V 32I Pipelined Processor
//
// Handles three classes of hazards:
//   1. Data hazards (RAW) -> forwarding (ForwardAE, ForwardBE)
//   2. Load-use hazard   -> stall (StallF, StallD, FlushE)
//   3. Control hazards   -> flush (FlushD, FlushE)
//
// Forwarding MUX select encoding (Execute stage):
//   2'b00 -> source is RD1E/RD2E (register file output, no hazard)
//   2'b10 -> forward from Memory  stage (ALUResultM)
//   2'b01 -> forward from Writeback stage (ResultW)
// ============================================================
module hazard_unit (
    input  wire        rst,

    // --- Forwarding inputs ---
    input  wire        RegWriteM,   // write enable in Memory stage
    input  wire        RegWriteW,   // write enable in Writeback stage
    input  wire [4:0]  RD_M,        // destination register in Memory stage
    input  wire [4:0]  RD_W,        // destination register in Writeback stage
    input  wire [4:0]  Rs1_E,       // source register 1 in Execute stage
    input  wire [4:0]  Rs2_E,       // source register 2 in Execute stage

    // --- Load-use hazard inputs ---
    input  wire        ResultSrcE_0, // ResultSrcE[0]: high when Execute stage is a load
    input  wire [4:0]  RD_E,         // destination register in Execute stage
    input  wire [4:0]  Rs1_D,        // source register 1 in Decode stage
    input  wire [4:0]  Rs2_D,        // source register 2 in Decode stage

    // --- Control hazard inputs ---
    input  wire        PCSrcE,       // branch/jump taken signal from Execute stage

    // --- Forwarding outputs ---
    output reg  [1:0]  ForwardAE,
    output reg  [1:0]  ForwardBE,

    // --- Stall outputs ---
    output wire        StallF,       // stall Fetch stage
    output wire        StallD,       // stall Decode stage

    // --- Flush outputs ---
    output wire        FlushD,       // flush Decode stage register
    output wire        FlushE        // flush Execute stage register
);

    // --------------------------------------------------------
    // Load-use hazard detection
    // A stall is needed when:
    //   - The Execute stage instruction is a load (ResultSrcE[0] == 1)
    //   - AND it writes to a register read by the Decode stage instruction
    // --------------------------------------------------------
    wire load_use_hazard;
    assign load_use_hazard = ResultSrcE_0 &
                             ((RD_E == Rs1_D) | (RD_E == Rs2_D)) &
                             (RD_E != 5'h00);

    // Stall Fetch and Decode for one cycle on load-use hazard
    assign StallF = load_use_hazard;
    assign StallD = load_use_hazard;

    // --------------------------------------------------------
    // Flush logic
    // FlushE: squash Execute stage on load-use stall OR branch/jump taken
    // FlushD: squash Decode stage on branch/jump taken
    // --------------------------------------------------------
    assign FlushE = load_use_hazard | PCSrcE;
    assign FlushD = PCSrcE;

    // --------------------------------------------------------
    // Forwarding logic
    // Priority: Memory stage forwarding > Writeback stage forwarding
    // Forwarding is suppressed during reset
    // --------------------------------------------------------
    always @(*) begin
        if (rst) begin
            ForwardAE = 2'b00;
            ForwardBE = 2'b00;
        end else begin
            // Forward A (Rs1_E)
            if      (RegWriteM && (RD_M != 5'h00) && (RD_M == Rs1_E))
                ForwardAE = 2'b10; // forward from Memory
            else if (RegWriteW && (RD_W != 5'h00) && (RD_W == Rs1_E))
                ForwardAE = 2'b01; // forward from Writeback
            else
                ForwardAE = 2'b00; // no forwarding

            // Forward B (Rs2_E)
            if      (RegWriteM && (RD_M != 5'h00) && (RD_M == Rs2_E))
                ForwardBE = 2'b10; // forward from Memory
            else if (RegWriteW && (RD_W != 5'h00) && (RD_W == Rs2_E))
                ForwardBE = 2'b01; // forward from Writeback
            else
                ForwardBE = 2'b00; // no forwarding
        end
    end

endmodule
