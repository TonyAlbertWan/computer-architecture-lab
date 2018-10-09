`timescale 10ns / 1ns
module ControlUnit(
	input [5:0] instruction,
	input [5:0] special,
	input [4:0] special2,
	output reg Branch,
	output reg MemtoReg,
	output reg RegDst,
	output reg [1:0]ALUOp,
	output reg ALUSrc
);
	
always@(*) 
	begin 
		case( instruction ) 
		6'b001001://addiu
			begin   
				RegDst = 0;
				Branch = 0;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b00;
				ALUSrc = 1;
			end
		6'b001100://andi
			begin   
				RegDst = 0;
				Branch = 0;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b11;
				ALUSrc = 1;
			end
    		6'b100011://lw
			begin   
				RegDst = 0;
				Branch = 0;
				MemtoReg = 1;
				ALUOp[1:0] = 2'b00;
				ALUSrc = 1;
			end			
       		6'b101011://sw
			begin   
				RegDst = 0;
				Branch = 0;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b00;
				ALUSrc = 1;
			end
    		6'b000101://bne
			begin   
				RegDst = 0;
				Branch = 1;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b01; 
				ALUSrc = 0;
			end
		6'b000100://beq
			begin
				RegDst = 0;
				Branch = 1;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b01;
				ALUSrc = 0;
			end
		6'b000110://blez
			begin   
				RegDst = 0;
				Branch = 1;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b11;
				ALUSrc = 0;
			end
		6'b000111://bgtz
			begin
				RegDst = 1;
				Branch = 1;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b11;					  
				ALUSrc = 0;
			end				
		6'b000010://j
			begin
				RegDst = 0;
				Branch = 0;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b00;
				ALUSrc = 0;
			end
		6'b000011://jal
			begin
				RegDst = 0;
				Branch = 0;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b00;
				ALUSrc = 0;
			end
		6'b001111://lui
			begin
				RegDst = 0;
				Branch = 0;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b00;
				ALUSrc = 1;
			end
		6'b001010://slti
			begin
				RegDst = 0;
				Branch = 0;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b11;
				ALUSrc = 1;
			end
		6'b001011://sltiu
			begin
				RegDst = 0;
				Branch = 0;
				MemtoReg = 0;
				ALUOp[1:0] = 2'b11;
				ALUSrc = 1;
			end
		6'b101010://swl
			begin   
				RegDst = 0;
				Branch = 0;
				MemtoReg = 1;
				ALUOp[1:0] = 2'b00;
				ALUSrc = 1;
			end	
		6'b101110://swr
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 0;
				//MemWrite = 1;
				MemtoReg = 0;
				//RegWrite = 0;
				ALUOp[1:0] = 2'b00;
				ALUSrc = 1;
			end		
		6'b101000://sb
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 0;
				//MemWrite = 1;
				MemtoReg = 0;
				//RegWrite = 0;
				ALUOp[1:0] = 2'b00;
				ALUSrc = 1;
			end
		6'b101001://sh
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 0;
				//MemWrite = 1;
				MemtoReg = 0;
				//RegWrite = 0;
				ALUOp[1:0] = 2'b00;		  
				ALUSrc = 1;
			end	
		6'b100010://lwl
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 1;
				//MemWrite = 0;
				MemtoReg = 1;
				//RegWrite = 1;
				ALUOp[1:0] = 2'b00;				  
				ALUSrc = 1;
			end	
		6'b100110://lwr
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 1;
				//MemWrite = 0;
				MemtoReg = 1;
				//RegWrite = 1;
				ALUOp[1:0] = 2'b00;				  
				ALUSrc = 1;
			end	
		6'b100000://lb
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 1;
				//MemWrite = 0;
				MemtoReg = 1;
				//RegWrite = 1;
				ALUOp[1:0] = 2'b00;				  
				ALUSrc = 1;
			end	
		6'b100100://lbu
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 1;
				//MemWrite = 0;
				MemtoReg = 1;
				//RegWrite = 1;
				ALUOp[1:0] = 2'b00;				  
				ALUSrc = 1;
			end	
		6'b100101://lhu
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 1;
				//MemWrite = 0;
				MemtoReg = 1;
				//RegWrite = 1;
				ALUOp[1:0] = 2'b00;				  
				ALUSrc = 1;
			end	
		6'b100001://lh
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 1;
				//MemWrite = 0;
				MemtoReg = 1;
				//RegWrite = 1;
				ALUOp[1:0] = 2'b00;				  
				ALUSrc = 1;
			end	
		6'b001110://xori
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 0;
				//MemWrite = 0;
				MemtoReg = 0;
				//RegWrite = 1;
				ALUOp[1:0] = 2'b11;				  
				ALUSrc = 1;
			end	
		6'b001101://ori
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 0;
				//MemWrite = 0;
				MemtoReg = 0;
				//RegWrite = 1;
				ALUOp[1:0] = 2'b11;				  
				ALUSrc = 1;
			end	
				
		//////////a group of specail///////////
		6'b000000://special
			begin
				case(special)
				6'b100001://addu
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b00;					  
					ALUSrc = 0;
				end
				6'b100100://and
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b001000://jr
				begin
					RegDst = 0;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 0;
					ALUOp[1:0] = 2'b00;					  
					ALUSrc = 0;
				end
				6'b001001://jalr
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b00;					  
					ALUSrc = 0;
				end
				6'b100101://or
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b001011://movn
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b001010://movz
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b100111://nor
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b000000://sll
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b000100://sllv
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b000011://sra
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b000111://srav
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b000010://srl
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b000110://srlv
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b101010://slt
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b101011://sltu
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b100011://subu
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				6'b100110://xor
				begin
					RegDst = 1;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 1;
					ALUOp[1:0] = 2'b10;					  
					ALUSrc = 0;
				end
				default:
				begin   
					RegDst = 0;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 0;
					ALUOp[1:0] = 2'b00;					  
					ALUSrc = 0;
				end
			endcase
		end
		6'b000001://special2
			begin
				case(special2)
				5'b10001://bgez
				begin   
					RegDst = 1;
					Branch = 1;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 0;
					ALUOp[1:0] = 2'b11;					  
					ALUSrc = 0;
				end	
				5'b00000://bltz
				begin   
					RegDst = 1;
					Branch = 1;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 0;
					ALUOp[1:0] = 2'b11;					  
					ALUSrc = 0;
				end
				default:
				begin   
					RegDst = 0;
					Branch = 0;
					//MemRead = 0;
					//MemWrite = 0;
					MemtoReg = 0;
					//RegWrite = 0;
					ALUOp[1:0] = 2'b00;					  
					ALUSrc = 0;
				end				
				endcase
			end
       	default:
			begin   
				RegDst = 0;
				Branch = 0;
				//MemRead = 0;
				//MemWrite = 0;
				MemtoReg = 0;
				//RegWrite = 0;
				ALUOp[1:0] = 2'b00;				  
				ALUSrc = 0;
			end
       		 endcase
  end
endmodule 
