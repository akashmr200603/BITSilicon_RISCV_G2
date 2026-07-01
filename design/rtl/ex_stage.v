module ex_stage(
    input clk,

    // from ID/EX pipeline register
    input [31:0] PC,
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] immediate,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [3:0] ALU_control,
    input ALUSrcA,
    input ALUSrcB,
    input MemRead,
    input MemWrite,
    input RegWrite,
    input MemtoReg,
    input [2:0] func3,
    input Branch,
    input Jump,         // NEW: for JAL/JALR
    input JumpReg,       // NEW: distinguishes JALR (rs1+imm) from JAL (PC+imm)

    // from forwarding unit
    input [1:0] ForwardA,
    input [1:0] ForwardB,
    input [31:0] MEM_result,
    input [31:0] WB_result,

    // outputs to EX/MEM pipeline register
    output reg branch_taken,
    output [31:0] ALU_result,
    output [31:0] rs2_data_out,
    output [31:0] branch_target,
    output [31:0] PC_plus4,       // NEW: for JAL/JALR rd value
    output zero,
    output MemRead_out,
    output MemWrite_out,
    output RegWrite_out,
    output MemtoReg_out,
    output [4:0] rd_out,
    output [2:0] func3_out,
    output Branch_out,
    output Jump_out               // NEW: passed forward so WB knows to use PC+4
);

reg [31:0] A,B;//intermediate rs1 and rs2
reg [31:0] rs1_next,rs2_next;//intermediate A and B
wire less_than_signed, less_than_unsigned;

//forwarding mux logic
always @(*)begin
    if(ForwardA==2'b00)begin
        A=rs1_data;
    end
    else if(ForwardA==2'b10)begin
        A=MEM_result;
    end
    else if (ForwardA==2'b01)begin
        A=WB_result;
    end
    else begin
        A=rs1_data;
    end

    if(ForwardB==2'b00)begin
        B=rs2_data;
    end
    else if(ForwardB==2'b10)begin
        B=MEM_result;
    end
    else if (ForwardB==2'b01)begin
        B=WB_result;
    end
    else begin
        B=rs2_data;
    end
end

//mux logic for choosing A or PC for rs1_next and B or immediate for rs2_next
always@(*)begin
    if(ALUSrcA)begin
        rs1_next=PC;
    end
    else begin
        rs1_next=A;
    end

    if(ALUSrcB)begin
        rs2_next=immediate;
    end
    else begin
        rs2_next=B;
    end
end

alu a1(rs1_next,rs2_next,ALU_control,ALU_result,zero,less_than_signed,less_than_unsigned);//ALU instantiated

always@(*)begin
    if(!Branch)begin
        branch_taken=0;
    end
    else begin
        case(func3)
        3'b000:begin
            if(zero==1) branch_taken=1;
            else branch_taken=0;
        end
        3'b001:begin
            if(zero==1) branch_taken=0;
            else branch_taken=1;
        end
        3'b100:begin
            if(less_than_signed==1) branch_taken=1;
            else branch_taken=0;
        end
        3'b101:begin
            if(less_than_signed==0 || zero==1) branch_taken=1;
            else branch_taken=0;
        end
        3'b110:begin
            if(less_than_unsigned==1)branch_taken=1;
            else branch_taken=0;
        end
        3'b111:begin
            if(less_than_unsigned==0 || zero==1) branch_taken=1;
            else branch_taken=0;
        end
        default: branch_taken=0;
        endcase
    end
end

assign rs2_data_out=B;//rs2_data is pass through

assign branch_target = (Jump && JumpReg) ? (A + immediate) : (PC + immediate);

assign PC_plus4    = PC + 32'd4;
assign Jump_out     = Jump;
assign MemRead_out  = MemRead;
assign MemWrite_out = MemWrite;
assign RegWrite_out = RegWrite;
assign MemtoReg_out = MemtoReg;
assign rd_out       = rd;
assign func3_out    = func3;
assign Branch_out   = Branch;
endmodule