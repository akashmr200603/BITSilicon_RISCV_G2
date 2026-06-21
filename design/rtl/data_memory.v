module data_memory_new(input clk, 
input MemRead, 
input MemWrite, 
input [3:0] byte_en,
input [31:0] address, 
input [31:0] write_data, 
output [31:0] read_data);

reg [7:0] mem0 [0:255];
reg [7:0] mem1 [0:255];
reg [7:0] mem2 [0:255];
reg [7:0] mem3 [0:255];

reg [31:0] data_out;
assign read_data=data_out;
always@(posedge clk) begin
    if(MemWrite)begin
        if(byte_en[0])begin
            mem0[address[9:2]]<=write_data[7:0];
        end
        if(byte_en[1])begin
            mem1[address[9:2]]<=write_data[15:8];
        end
        if(byte_en[2])begin
            mem2[address[9:2]]<=write_data[23:16];
        end
        if(byte_en[3])begin
            mem3[address[9:2]]<=write_data[31:24];
        end
    end
end

always@(*)begin
    if(MemRead)begin
    data_out={{mem3[address[9:2]]},mem2[address[9:2]],mem1[address[9:2]],mem0[address[9:2]]};
    end
    else begin
        data_out = 32'b0;
    end
end
endmodule