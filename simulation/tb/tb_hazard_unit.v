`timescale 1ns/1ps
`include "hazard_unit.v"

module tb_hazard_unit;
    reg        rst, RegWriteM, RegWriteW;
    reg  [4:0] RD_M, RD_W, Rs1_E, Rs2_E;
    reg        ResultSrcE_0, PCSrcE;
    reg  [4:0] RD_E, Rs1_D, Rs2_D;

    wire [1:0] ForwardAE, ForwardBE;
    wire       StallF, StallD, FlushD, FlushE;

    hazard_unit dut (
        .rst(rst), .RegWriteM(RegWriteM), .RegWriteW(RegWriteW),
        .RD_M(RD_M), .RD_W(RD_W), .Rs1_E(Rs1_E), .Rs2_E(Rs2_E),
        .ResultSrcE_0(ResultSrcE_0), .RD_E(RD_E),
        .Rs1_D(Rs1_D), .Rs2_D(Rs2_D), .PCSrcE(PCSrcE),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
        .StallF(StallF), .StallD(StallD),
        .FlushD(FlushD), .FlushE(FlushE)
    );

    task check;
        input [63:0] desc; // not used, just for readability
        begin
            #1;
            $display("ForwardAE=%b ForwardBE=%b StallF=%b StallD=%b FlushD=%b FlushE=%b",
                     ForwardAE, ForwardBE, StallF, StallD, FlushD, FlushE);
        end
    endtask

    initial begin
        // Init
        rst=1; RegWriteM=0; RegWriteW=0;
        RD_M=0; RD_W=0; Rs1_E=0; Rs2_E=0;
        ResultSrcE_0=0; RD_E=0; Rs1_D=0; Rs2_D=0; PCSrcE=0;

        $display("--- Reset active: all outputs should be 0 ---");
        check(0);

        rst = 0;

        $display("\n--- No hazard ---");
        RegWriteM=1; RD_M=5'd3; Rs1_E=5'd5; Rs2_E=5'd6;
        RegWriteW=1; RD_W=5'd7;
        check(0);

        $display("\n--- Forward from Memory (Rs1_E match) ---");
        Rs1_E = 5'd3;
        check(0);

        $display("\n--- Forward from Writeback (Rs2_E match, no MEM match) ---");
        RegWriteM=0; Rs2_E=5'd7;
        check(0);

        $display("\n--- Both forward: MEM->A, WB->B ---");
        RegWriteM=1; RD_M=5'd3; Rs1_E=5'd3;
        RegWriteW=1; RD_W=5'd7; Rs2_E=5'd7;
        check(0);

        $display("\n--- Load-use hazard: stall + FlushE ---");
        RegWriteM=0; RegWriteW=0;
        ResultSrcE_0=1; RD_E=5'd4; Rs1_D=5'd4; Rs2_D=5'd9; PCSrcE=0;
        check(0);

        $display("\n--- Control hazard (branch taken): FlushD + FlushE ---");
        ResultSrcE_0=0; RD_E=0; Rs1_D=0; Rs2_D=0; PCSrcE=1;
        check(0);

        $display("\n--- Load-use + branch taken: all stalls and flushes ---");
        ResultSrcE_0=1; RD_E=5'd4; Rs1_D=5'd4; PCSrcE=1;
        check(0);

        $display("\nHazard unit simulation complete.");
        $finish;
    end
endmodule