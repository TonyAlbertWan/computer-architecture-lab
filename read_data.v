`timescale 10ns / 1ns

module read_data(
	input [31:0] read,//Readdata
	input [31:0] r,//Readdata2
	input [5:0] control,//ALUResult[0:1]
	input [1:0] ea,//Writedata
	output reg [31:0] out//write
);
	always@(*)
	begin
		case(control)
		6'b100011://lw
			begin
				out = read;
			end
		6'b100010:	//lwl
			begin
			case(ea)
			2'b00:
				out = {read[7:0],r[23:0]};
			2'b01:
				out = {read[15:0],r[15:0]};
			2'b10:
				out = {read[23:0],r[7:0]};
			2'b11:
				out = read;
			endcase
			end
		6'b100110:	//lwr
			begin
			case(ea)
			2'b00:
				out = read;
			2'b01:
				out = {r[31:24],read[31:8]};
			2'b10:
				out = {r[31:16],read[31:16]};
			2'b11:
				out = {r[31:8],read[31:24]};
			endcase
			end
		6'b100000:	//lb
			begin
			case(ea)
			2'b00:
				out = read[7] ? {24'b111111111111111111111111,read[7:0]} : {24'b0,read[7:0]};
			2'b01:
				out = read[15] ? {24'b111111111111111111111111,read[15:8]} : {24'b0,read[15:8]};
			2'b10:
				out =  read[23] ? {24'b111111111111111111111111,read[23:16]} : {24'b0,read[23:16]};
			2'b11:
				out =  read[31] ? {24'b111111111111111111111111,read[31:24]} : {24'b0,read[31:24]};
			endcase
			end
		6'b100100:	//lbu
			begin
			case(ea)
			2'b00:
				out = {24'b0,read[7:0]};
			2'b01:
				out = {24'b0,read[15:8]};
			2'b10:
				out = {24'b0,read[23:16]};
			2'b11:
				out = {24'b0,read[31:24]};
			endcase
			end
		6'b100001:	//lh
			begin
			case(ea)
			2'b00:
				out = read[15] ? {16'b1111111111111111,read[15:0]} : {16'b0,read[15:0]};
			2'b01:
				out = read[15] ? {16'b1111111111111111,read[15:0]} : {16'b0,read[15:0]};
			2'b10:
				out =  read[31] ? {16'b1111111111111111,read[31:16]} : {16'b0,read[31:16]};
			2'b11:
				out =  read[31] ? {16'b1111111111111111,read[31:16]} : {16'b0,read[31:16]};
			endcase
			end
		6'b100101:	//lhu
			begin
			case(ea)
			2'b00:
				out = {16'b0,read[15:0]};
			2'b01:
				out = {16'b0,read[15:0]};
			2'b10:
				out = {16'b0,read[31:16]};
			2'b11:
				out = {16'b0,read[31:16]};
			endcase
			end
		default:
			out = read;
		endcase
	end
endmodule