`timescale 10ns / 1ns

module switch(
	input [4:0] in,
	input [1:0] control,
	output [6:0] out
);
	assign out = {~control[1:0],~in[4:0]};
endmodule
