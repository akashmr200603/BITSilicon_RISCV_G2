module alu(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALU_control,
    output reg [31:0] result,
    output zero,
    output less_than_signed,
    output less_than_unsigned
);

always@(*)begin
    case(ALU_control)
    4'b0000:begin
        result=A+B;
    end
    4'b0001:begin
        result=A-B;
    end
    4'b0010:begin
        result=A & B;
    end
    4'b0011:begin
        result=A|B;
    end
    4'b0100:begin
        result=A^B;
    end
    4'b0101:begin
        result=A<<B[4:0];
    end
    4'b0110:begin
        result=A>>B[4:0];
    end
    4'b0111:begin
        result=$signed(A) >>> B[4:0];
    end
    4'b1000:begin
        if($signed(A) < $signed(B)) begin result=1; end
        else begin result=0; end
    end
    4'b1010:begin
        result = B;
    end
    4'b1001:begin
        if(A< B) begin result=1; end
        else begin result=0; end
    end
    default: result = 32'b0;
    endcase
end
assign zero = (result == 32'b0);
assign less_than_signed   = ($signed(A) < $signed(B));
assign less_than_unsigned = (A < B);
endmodule