`timescale 10ns / 1ns

module write_data(
	input [31:0] in,//readdata2
	input [5:0] control,//I[31:26]
	input [1:0] ea,//ALUResult[1:0]
	output reg [31:0] out,//writedata
	output reg [3:0] strb//writestrb
);

	always@(*)
	begin
		case(control)
		6'b101010:	//swl
			begin
			case(ea)
			2'b00:
				begin
				out = {24'b0,in[31:24]};
				strb = 4'b0001;
				end
			2'b01:
				begin
				out = {16'b0,in[31:16]};
				strb = 4'b0011;
				end
			2'b10:
				begin
				out = {8'b0,in[31:8]};
				strb = 4'b0111;
				end
			2'b11:
				begin
				out = in;
				strb = 4'b1111;
				end
			endcase
			end
		6'b101110:	//swr
			begin
			case(ea)
			2'b00:
				begin
				out = in;
				strb = 4'b1111;
				end
			2'b01:
				begin
				out = {in[23:0],8'b0};
				strb = 4'b1110;
				end
			2'b10:
				begin
				out = {in[15:0],16'b0};
				strb = 4'b1100;
				end
			2'b11:
				begin
				out = {in[8:0],24'b0};
				strb = 4'b1000;
				end
			endcase
			end
		6'b101000:	//sb
			begin
			out = {in[7:0],in[7:0],in[7:0],in[7:0]};
			case(ea)
			2'b00:
				begin
				strb = 4'b0001;
				end
			2'b01:
				begin
				strb = 4'b0010;
				end
			2'b10:
				begin
				strb = 4'b0100;
				end
			2'b11:
				begin
				strb = 4'b1000;
				end
			endcase
			end
		6'b101001:	//sh
			begin
			out = {in[15:0],in[15:0]};
			case(ea)
			2'b00:
				begin
				strb = 4'b0011;
				end
			2'b01:
				begin
				strb = 4'b0011;
				end
			2'b10:
				begin
				strb = 4'b1100;
				end
			2'b11:
				begin
				strb = 4'b1100;
				end
			endcase
			end
		default:
			begin
			out = in;
			strb = 4'b1111;
			end
		endcase
	end
endmodule
