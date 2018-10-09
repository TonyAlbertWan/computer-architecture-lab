`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file(
	input clk,
	input resetn,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output [`DATA_WIDTH - 1:0] rdata1,
	output [`DATA_WIDTH - 1:0] rdata2
);

	reg [`DATA_WIDTH - 1:0] r [`DATA_WIDTH - 1:0];

	assign rdata1 = r[raddr1];
	assign rdata2 = r[raddr2];
	
	always @ (posedge clk)
	begin 
		if(!resetn)
			begin  
				if(wen && (waddr != 5'b0))
				begin
				r[waddr] <= wdata;
				end
				else 
				begin
				r[0] <= 32'b0;
				end
			end
		else
			begin
				r[0] <= 32'b0;
			end
	end

endmodule