`timescale 10 ns / 1 ns

`define DATA_WIDTH 32

module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUcontrol,
	input [6:0]sll,
	output Overflow,
	output CarryOut,
	output Zero,
	output [`DATA_WIDTH - 1:0] Result,
	output [31:0]d
);

	reg [`DATA_WIDTH - 1:0] result;
	wire [`DATA_WIDTH:0] S;
	wire [`DATA_WIDTH - 1:0] result1;
	wire [`DATA_WIDTH - 1:0] result2;
	wire [`DATA_WIDTH - 1:0] result3;
	wire [`DATA_WIDTH - 1:0] result4;
	wire [`DATA_WIDTH - 1:0] y;

	assign Zero = result ? 0:1;
	assign d = S[31:0];
	assign Overflow = ((ALUcontrol == 3'b010 & ((A[`DATA_WIDTH - 1]==0 & B[`DATA_WIDTH - 1]==0 & result[`DATA_WIDTH - 1]==1)
		|(A[`DATA_WIDTH - 1]==1 & B[`DATA_WIDTH - 1]==1 & result[`DATA_WIDTH - 1]==0)))
		|(ALUcontrol == 3'b110 & A[`DATA_WIDTH - 1]==~B[`DATA_WIDTH - 1] & B[`DATA_WIDTH - 1]==result[`DATA_WIDTH - 1]))?1:0;
	assign y = (ALUcontrol[2] == 1)?(~B):(B);
	assign S = A+y+ALUcontrol[2];
	assign CarryOut = S[`DATA_WIDTH] ^ ALUcontrol[2];
	
	//shift
	assign result1 = sll[0] ? result  : sll[6] ? {result[30:0] ,1'b0} : sll[5] ? {1'b0,result[31:1]} : result[31] ? {1'b1,result[31:1]} : {1'b0,result[31:1]} ;
	assign result2 = sll[1] ? result1 : sll[6] ? {result1[29:0],2'b0} : sll[5] ? {2'b0,result1[31:2]} : result1[31] ? {2'b11,result1[31:2]} : {2'b0,result1[31:2]} ;
	assign result3 = sll[2] ? result2 : sll[6] ? {result2[27:0],4'b0} : sll[5] ? {4'b0,result2[31:4]} : result2[31] ? {4'b1111,result2[31:4]} : {4'b0,result2[31:4]} ;
	assign result4 = sll[3] ? result3 : sll[6] ? {result3[23:0],8'b0} : sll[5] ? {8'b0,result3[31:8]} : result3[31] ? {8'b11111111,result3[31:8]} : {8'b0,result3[31:8]} ;
	assign Result  = sll[4] ? result4 : sll[6] ? {result4[15:0],16'b0} : sll[5] ? {16'b0,result4[31:16]} : result4[31] ? {16'b1111111111111111,result4[31:16]} : {16'b0,result4[31:16]} ;
	always@(*)begin
		case(ALUcontrol) 
			3'b000://and
			begin
				result = A & B;
			end
			3'b001://or
			begin
				result = A | B;
			end
			3'b010://add
			begin
				result = S[`DATA_WIDTH - 1:0];
			end
			3'b110://sub
			begin
				result = S[`DATA_WIDTH - 1:0];
			end
			3'b011://xor
			begin
				result = A ^ B;
			end
			3'b100://slt unsign
			begin
				if(S[`DATA_WIDTH]==0)
					begin
						result = {31'b0, 1'b1};
					end
				else
					begin
						result = 32'b0;
					end
			end
			3'b101:
			begin
				result = B;
			end
			3'b111:
			begin //slt
			if(A[`DATA_WIDTH - 1]^B[`DATA_WIDTH - 1]==0) //same A and B
				begin
					result = (S[`DATA_WIDTH - 1]==1)?1:0;
				end
			else //different A and B
				begin
					result = (A[`DATA_WIDTH - 1]^B[`DATA_WIDTH - 1]==1 & A[`DATA_WIDTH - 1]==1)?1:0;
				end
			end
			default 
				begin
					result = 32'b0;
				end
		endcase
	end
endmodule
