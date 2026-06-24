// ============================================================
// Testbench - Decode Cycle
// Tests: lw, sw, add, sub, beq, addi, jal
// ============================================================
`timescale 1ns/1ps

`include "decode_cycle.v"

module tb_decode_cycle;

    // Clock
    reg CLK;
    initial CLK = 0;
    always #5 CLK = ~CLK;

    // DUT ports
    reg  [31:0] InstrD, PCD, PCPlus4D;
    reg         RegWriteW;
    reg  [4:0]  RDW;
    reg  [31:0] ResultW;
    reg         Reset, Flush;

    wire        RegWriteE;
    wire [1:0]  ResultSrcE;
    wire        MemWriteE, JumpE, BranchE;
    wire [2:0]  ALUControlE;
    wire        ALUSrcE;
    wire [31:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E;
    wire [4:0]  RdE;

    decode_cycle dut (
        .CLK        (CLK),
        .Reset      (Reset),
        .Flush      (Flush),
        .InstrD     (InstrD),
        .PCD        (PCD),
        .PCPlus4D   (PCPlus4D),
        .RegWriteW  (RegWriteW),
        .RDW        (RDW),
        .ResultW    (ResultW),
        .RegWriteE  (RegWriteE),
        .ResultSrcE (ResultSrcE),
        .MemWriteE  (MemWriteE),
        .JumpE      (JumpE),
        .BranchE    (BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE    (ALUSrcE),
        .RD1E       (RD1E),
        .RD2E       (RD2E),
        .PCE        (PCE),
        .RdE        (RdE),
        .ImmExtE    (ImmExtE),
        .PCPlus4E   (PCPlus4E)
    );

    // Helper task
    task apply_instr;
        input [31:0] instr;
        input [31:0] pc;
        begin
            InstrD   = instr;
            PCD      = pc;
            PCPlus4D = pc + 4;
            @(posedge CLK); #1;
        end
    endtask

    initial begin
        // Init
        InstrD = 0; PCD = 0; PCPlus4D = 4;
        RegWriteW = 0; RDW = 0; ResultW = 0;
        Reset = 1; Flush = 0;
        @(posedge CLK); #1;
        Reset = 0;

        // --- Write x1=100, x2=200 via writeback ---
        RegWriteW = 1; RDW = 5'd1; ResultW = 32'd100;
        @(posedge CLK); #1;
        RDW = 5'd2; ResultW = 32'd200;
        @(posedge CLK); #1;
        RegWriteW = 0;

        // --- lw x3, 8(x1)  =>  0000000_00001_00001_010_00011_0000011
        //     imm=8, rs1=x1, funct3=010, rd=x3, op=0000011
        $display("\n--- lw x3, 8(x1) ---");
        apply_instr(32'h0080_a183, 32'h00);
        $display("RegWriteE=%b ResultSrcE=%b MemWriteE=%b ALUSrcE=%b ALUControlE=%b ImmExtE=%0d",
                  RegWriteE, ResultSrcE, MemWriteE, ALUSrcE, ALUControlE, $signed(ImmExtE));

        // --- sw x2, 12(x1) => 0000000_00010_00001_010_01100_0100011
        $display("\n--- sw x2, 12(x1) ---");
        apply_instr(32'h0020_a623, 32'h04);
        $display("RegWriteE=%b MemWriteE=%b ALUSrcE=%b ImmExtE=%0d",
                  RegWriteE, MemWriteE, ALUSrcE, $signed(ImmExtE));

        // --- add x3, x1, x2 => 0000000_00010_00001_000_00011_0110011
        $display("\n--- add x3, x1, x2 ---");
        apply_instr(32'h0020_81b3, 32'h08);
        $display("RegWriteE=%b ALUSrcE=%b ALUControlE=%b RdE=%0d",
                  RegWriteE, ALUSrcE, ALUControlE, RdE);

        // --- sub x3, x1, x2 => 0100000_00010_00001_000_00011_0110011
        $display("\n--- sub x3, x1, x2 ---");
        apply_instr(32'h4020_81b3, 32'h0c);
        $display("RegWriteE=%b ALUControlE=%b",
                  RegWriteE, ALUControlE);

        // --- beq x1, x2, 16 => offset=16 B-type
        //     imm[12|10:5]=000000_1 imm[4:1|11]=0000_0
        //     0000000_00010_00001_000_10000_1100011  (simplified, offset=16)
        $display("\n--- beq x1, x2, 16 ---");
        apply_instr(32'h0020_8863, 32'h10);
        $display("BranchE=%b ALUControlE=%b ImmExtE=%0d",
                  BranchE, ALUControlE, $signed(ImmExtE));

        // --- addi x3, x1, 5 => 000000000101_00001_000_00011_0010011
        $display("\n--- addi x3, x1, 5 ---");
        apply_instr(32'h0050_8193, 32'h14);
        $display("RegWriteE=%b ALUSrcE=%b ImmExtE=%0d",
                  RegWriteE, ALUSrcE, $signed(ImmExtE));

        // --- jal x1, 8 => J-type, offset=8
        $display("\n--- jal x1, 8 ---");
        apply_instr(32'h0080_00ef, 32'h18);
        $display("JumpE=%b RegWriteE=%b ResultSrcE=%b",
                  JumpE, RegWriteE, ResultSrcE);

        // --- Flush test: apply addi then flush, expect NOP at Execute ---
        $display("\n--- Flush test (addi then Flush=1) ---");
        Flush = 1;
        apply_instr(32'h0050_8193, 32'h1c);  // addi x3, x1, 5
        Flush = 0;
        #1;
        $display("RegWriteE=%b MemWriteE=%b BranchE=%b JumpE=%b (expect all 0)",
                  RegWriteE, MemWriteE, BranchE, JumpE);

        $display("\nDecode Cycle simulation complete.");
        $finish;
    end

    // Dump waves
    initial begin
        $dumpfile("tb_decode_cycle.vcd");
        $dumpvars(0, tb_decode_cycle);
    end

endmodule
