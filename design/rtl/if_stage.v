module fetch_cycle(clk, rst, PCSrcE, PCTargetE, InstrD, PCD, PCPlus4D )
    
    //Declare input and output
    input clk, rst;
    input PSCrcE;
    input [31:0] PCTargetE;
    output [31:0] InstrD;
    output [31:0] PCD, PCPlus4D;


    //Declaring Interim Wires
    wire [31:0] PC_F, PCF, PCPlus4F;
    wire [31:0] InstrF;

    //Declaration of Register
    reg [31:0] InstrF_reg;
    reg [31:0] PCF_reg, PCPlus4F_reg;


    //Instantiation of Modules
    //Declare PC Mux
    Mux PC_MUX (.a(PCPlus4F), .b(PCTargetE), .s(PSCrcE), .c(PC_F)); 


    //Declare PC Counter
    PC Module Program_Counter (
        .clk(clk),
        .rst(rst),
        .PC(PC_F),
        .PC_Next(PCF),
        );
    
    //Declare Instruction Memory
    Instruction_Memory IMEM (
        .rst(rst), 
        .A(PCF), 
        .RD()
        );
    
    //Declare PC adder
    PC_Adder PC_adder (.a(PCF),
        b(32 h00000004),
        c(PCPlus4F),
        );

    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
        InstrF_reg <= 32'h00000000;
        PCF_reg <= 32'h00000000;
        PCPlus4F_reg <= 32'h00000000;
        end
        else begin
            InstrF_reg <= InstrF;
            PCF_reg <= PCF;
            PCPlus4F <= PCPlus4F;
        end
    end

    // Assigning registers value to the output port
    assign InstrD = (rst == 1'b0) ? 32'h00000000 : InstrF_reg;
    assign PCD = (rst == 1'b0) ? 32'h00000000 : PCF_reg;
    assign PCPlus4D = (rst == 1'b0) ? 32'h00000000 : PCPlus4F_reg;
    
    



endmodule

