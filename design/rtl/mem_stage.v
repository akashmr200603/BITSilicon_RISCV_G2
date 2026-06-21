module mem_stage_new(
    input clk,
    input [31:0] ALU_result,
    input [31:0] rs2_data,
    input [2:0] func3,
    input MemRead,
    input MemWrite,
    input RegWrite,
    input MemtoReg,
    input [4:0] rd,
    output reg [31:0] mem_read_data,
    output [31:0] ALU_result_out,
    output RegWrite_out,
    output MemtoReg_out,
    output [4:0] rd_out
);

assign ALU_result_out=ALU_result;
assign RegWrite_out=RegWrite;
assign MemtoReg_out=MemtoReg;
assign rd_out=rd;

wire [31:0] d_out;
reg [3:0] b_en;

data_memory_new r1(clk,MemRead,MemWrite,b_en,ALU_result,rs2_data,d_out);
always@(*)begin
    b_en = 4'b0000;
    if(MemWrite)begin
        case(func3)
        3'b010:b_en=4'b1111;
        3'b000:begin
            case(ALU_result[1:0])
            2'b00:b_en=4'b0001;
            2'b01:b_en=4'b0010;
            2'b10:b_en=4'b0100;
            2'b11:b_en=4'b1000;
            endcase
        end
        3'b001:begin
            case(ALU_result[1])
            1'b0:b_en=4'b0011;
            1'b1:b_en=4'b1100;
            endcase
        end
        endcase
    end
end

always@(*)begin
    mem_read_data = 32'b0;
    if(MemRead)begin
        case(func3)
        3'b010:mem_read_data=d_out;
        3'b000:begin
            case(ALU_result[1:0])
            2'b00:mem_read_data={{24{d_out[7]}},d_out[7:0]};
            2'b01:mem_read_data={{24{d_out[15]}},d_out[15:8]};
            2'b10:mem_read_data={{24{d_out[23]}},d_out[23:16]};
            2'b11:mem_read_data={{24{d_out[31]}},d_out[31:24]};
            endcase
        end
        3'b001:begin
            case(ALU_result[1])
            1'b0:mem_read_data={{16{d_out[15]}},d_out[15:0]};
            1'b1:mem_read_data={{16{d_out[31]}},d_out[31:16]};
            endcase
        end
        3'b100:begin
            case(ALU_result[1:0])
            2'b00:mem_read_data={{24{1'b0}},d_out[7:0]};
            2'b01:mem_read_data={{24{1'b0}},d_out[15:8]};
            2'b10:mem_read_data={{24{1'b0}},d_out[23:16]};
            2'b11:mem_read_data={{24{1'b0}},d_out[31:24]};
            endcase
        end
        3'b101:begin
            case(ALU_result[1])
            1'b0:mem_read_data={{16{1'b0}},d_out[15:0]};
            1'b1:mem_read_data={{16{1'b0}},d_out[31:16]};
            endcase
        end
        endcase
    end
end

endmodule