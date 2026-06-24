// ============================================================
// Register File - RISC-V 32I
// 32 x 32-bit registers, x0 hardwired to 0
// Synchronous write (posedge CLK), asynchronous read
// Ports match diagram: A1->RD1, A2->RD2, A3/WD3/WE3 for write
// ============================================================
module register_file (
    input  wire        CLK,
    input  wire        Reset,  // synchronous reset

    // Read ports
    input  wire [4:0]  A1,   // rs1 address (InstrD[19:15])
    input  wire [4:0]  A2,   // rs2 address (InstrD[24:20])
    output wire [31:0] RD1,  // rs1 data
    output wire [31:0] RD2,  // rs2 data

    // Write port (from writeback stage)
    input  wire [4:0]  A3,   // rd  address  (InstrD[11:7] via writeback)
    input  wire [31:0] WD3,  // write data
    input  wire        WE3   // write enable (RegWriteW)
);

    reg [31:0] rf [31:0];

    integer i;

    // Synchronous write with reset; x0 is never written
    always @(posedge CLK) begin
        if (Reset) begin
            for (i = 0; i < 32; i = i + 1)
                rf[i] <= 32'b0;
        end else if (WE3 && (A3 != 5'b0))
            rf[A3] <= WD3;
    end

    // Asynchronous read; x0 always returns 0
    assign RD1 = (A1 != 5'b0) ? rf[A1] : 32'b0;
    assign RD2 = (A2 != 5'b0) ? rf[A2] : 32'b0;

endmodule
