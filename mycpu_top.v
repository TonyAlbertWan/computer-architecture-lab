`define IF    3'b000
`define IW    3'b001
`define ID    3'b010
`define EX    3'b011
`define WB    3'b100
`define ST    3'b101
`define LD    3'b110
`define RDW   3'b111
//Instruction[31:26]
`define SPEC 6'b000000
`define BEQ  6'b000100
`define BNE  6'b000101
`define J    6'b000010
`define JAL  6'b000011
`define BGEZ 6'b000001
`define BGTZ 6'b000111
`define BLEZ 6'b000110
`define BLTZ 6'b000001
`define ADDIU 6'b001001
`define ANDI  6'b001100
`define LB    6'b100000
`define LBU   6'b100100
`define LH    6'b100001
`define LHU   6'b100101
`define LWL   6'b100010
`define LWR   6'b100110
`define LW    6'b100011
`define LUI   6'b001111
`define SW    6'b101011
`define SLTI  6'b001010
`define SLTIU 6'b001011
`define ORI   6'b001101
`define SB    6'b101000
`define SH    6'b101001
`define SWL   6'b101010
`define SWR   6'b101110
`define XORI  6'b001110
//func=Ins[5:0]
`define JR    6'b001000
`define JALR  6'b001001
`define ADDU  6'b100001
`define AND   6'b100100
`define SLL   6'b000000
`define SUBU  6'b100011
`define MOVN  6'b001011
`define MOVZ  6'b001010
`define NOR   6'b100111
`define SLLV  6'b000100
`define SLTU  6'b101011
`define SRA   6'b000011
`define SRAV  6'b000111
`define SRL   6'b000010
`define SRLV  6'b000110
`define XOR   6'b100110
`define OR    6'b100101
`define SLT   6'b101010



module mycpu_top(
    input            clk,
    input            resetn,            //low active

    output  reg      inst_sram_en,
    output  [ 3:0]   inst_sram_wen,
    output  [31:0]   inst_sram_addr,
    output  [31:0]   inst_sram_wdata,
    input   [31:0]   inst_sram_rdata,
    
    output  reg         data_sram_en,
    output  [ 3:0]   data_sram_wen,
    output  [31:0]   data_sram_addr,
    output  [31:0]   data_sram_wdata,
    input   [31:0]   data_sram_rdata,

    //debug interface
    output  [31:0]   debug_wb_pc,
    output  [3 :0]   debug_wb_rf_wen,
    output  [4 :0]   debug_wb_rf_wnum,
    output  [31:0]   debug_wb_rf_wdata
);
	
	reg [31:0] PC;
    assign inst_sram_addr = PC;

	wire [31:0] Instruction;
    assign Instruction = inst_sram_rdata;
	
	wire [31:0] Address;
    assign  data_sram_addr = Address;
	
	wire [31:0] Write_data;
    assign data_sram_wdata = Write_data;
	
	wire [3:0] Write_strb;
    assign data_sram_wen = Write_strb;
	
	wire [31:0] Read_data;
    assign data_sram_rdata = Read_data;
	
	reg MemRead;	
	reg MemWrite;
	wire [31:0] Read_data_1;
	wire [31:0] Read_data_2;
	wire [31:0] ALUResult;
	wire Zero;
	wire RegDst;
	wire Branch;
	wire MemtoReg;
	wire [1:0]ALUOp;
	wire ALUSrc;
	reg RegWrite;
	wire [31:0] Sign_extend;
	reg [2:0] ALUcontrol;
	wire Overflow;
	wire CarryOut;
	wire [31:0] write;
	wire [5:0] s;
	wire [6:0]sll;
	wire [31:0] d;
	reg [31:0]Read_data_reg;
	reg [31:0]Instruction_reg;
	reg wen_reg;

assign debug_wb_pc = PC;
assign debug_wb_rf_wnum = ((Instruction_reg[31:26]==6'b000011) ? 5'b11111 : (RegDst ? Instruction_reg[15:11] : Instruction_reg[20:16]));
assign debug_wb_rf_wdata = (((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:0]==6'b100111)) //nor
	? ~ALUResult :(((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:0]==6'b001001)) | (Instruction_reg[31:26]==6'b000011)) ? //jal&jalr
	(PC+8) : (Instruction_reg[31:26]==6'b001111) ?//lui
	 {ALUResult[15:0],16'b0} :((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:1]==5'b00101)) //movz&movn
	 ? Read_data_1 : (MemtoReg ? write : ALUResult));
assign debug_wb_rf_wen = ((((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:0]==`MOVN)&Zero)|((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:0]==`MOVZ)&~Zero)) ? 1'b0 : (wen_reg & RegWrite));
	
	always@(Instruction_reg or Read_data_2 or Zero)
	begin
	  case (Instruction_reg[31:26])
	    `JAL,`ADDIU,`ANDI,`LB,`LBU,`LH,`LHU,`LWL,`LWR,`LW,`LUI,`ORI,`SLTI,`SLTIU,`XORI:
		  RegWrite <= 1'b1;
		`SPEC:
		begin
		  case (Instruction_reg[5:0])
			`MOVN:
			  if (!Zero) RegWrite <= 1'b1;
			  else RegWrite <= 1'b0;
			`MOVZ:
			  if (Zero) RegWrite <= 1'b1;
			  else RegWrite <= 1'b0;
		    default:
		      RegWrite <= 1'b1;
		  endcase
		end
		default:
		  RegWrite <= 1'b0;
	  endcase
	end


	reg [6:0] current_state;
	reg [6:0] next_state;
	wire store;
	wire load;
	wire branch;
	assign load = (Instruction_reg[31:26] == `LB) |
			(Instruction_reg[31:26] == `LBU) | 
			(Instruction_reg[31:26] == `LH) | 
			(Instruction_reg[31:26] == `LHU) | 
			(Instruction_reg[31:26] == `LW) | 
			(Instruction_reg[31:26] == `LWL) | 
			(Instruction_reg[31:26] == `LWR);
			
	assign store  = (Instruction_reg[31:26] == `SW) | 
			(Instruction_reg[31:26] == `SH)  | 
			(Instruction_reg[31:26] == `SB) | 
			(Instruction_reg[31:26] == `SWL) | 
			(Instruction_reg[31:26] == `SWR);
	reg branchTry;
	always@(Instruction_reg)
	begin
	  case(Instruction_reg[31:26])
	    `BEQ,`BNE,`BGEZ,`BLEZ,`J,`JAL:
		  branchTry <= 1;            
		`SPEC:
		  if ((Instruction_reg[5:0] == `JR) | (Instruction_reg[5:0] == `JALR)) branchTry <= 1;
		  else branchTry <= 0;
		default:
		  branchTry <= 0;
	  endcase
	end		
	assign branch = (!branchTry)  		        	      ? 1'b0                              :
	                (Instruction_reg[31:26] == `BEQ)      ? Zero                              :
			        (Instruction_reg[31:26] == `BNE)      ? !Zero                             :
			        (Instruction_reg[31:26] == `BLEZ)     ? (Read_data_1[31] | Zero)          :
			        (Instruction_reg[31:26] == `BGEZ)     ? ((Instruction_reg[20:16] == 5'b00001) ? 
					(!Read_data_1[31]):Read_data_1[31])
					:1'b1; 

	
	always @ (posedge clk or negedge resetn)
	begin
		if (resetn)
			current_state <= `IF;
		else
			current_state <= next_state;
	end
	
	always @ (current_state  or branch or store or load or resetn)
	begin
		if (resetn) next_state = `IF;
		else 
		begin
			case (current_state)
				`IF:
					next_state <= `IW ;
				`IW:
					next_state <= `ID ;
				`WB:
					next_state <= `IF ;
				`ID:
					next_state <= `EX ;
				`EX:
					next_state <= branch ? `IF:
					              store  ? `ST:
					              load   ? `LD:
					                       `WB;
				`ST:
					next_state <= `IF ;
				`LD:
					next_state <= `RDW ;
				`RDW:
					next_state <= `WB  ;	
				default:
					next_state <= `IF;
			endcase
		end
	end
	
	assign inst_sram_wen = 0;
	always @ (clk or current_state or resetn or Instruction_reg)
	begin
		if (~resetn)
			begin
			    inst_sram_en = 0;
				data_sram_en = 0;
				MemRead <= 0;
				MemWrite <= 0;
				wen_reg <= 0;
			end 
		else
			begin
				case (current_state)
					`IF:
						begin
						    inst_sram_en = 1;
							data_sram_en = 0;
							MemRead <= 0;
							MemWrite <= 0;
							wen_reg <= 0;
						end
					`IW:
						begin
						    inst_sram_en = 0;
                			data_sram_en = 0;
							MemRead <= 0;
							MemWrite <= 0;
							wen_reg <= 0;
						end
					`WB:
						begin
						    inst_sram_en = 0;
							data_sram_en = 0;
							MemRead <= 0;
							MemWrite <= 0;
							wen_reg <= 1;
						end
					`ID:
						begin
						    inst_sram_en = 0;
							data_sram_en = 0;
							MemRead <= 0;
							MemWrite <= 0;
							wen_reg <= 0;
						end
					`EX:
						begin
						    inst_sram_en = 0;
							data_sram_en = 0;
							MemRead <= 0;
							MemWrite <= 0;
							wen_reg <= (Instruction_reg[31:26] == `JAL) | 
							((Instruction_reg[31:26] == `SPEC) & (Instruction_reg[5:0] == `JALR));
						end
					`ST:
						begin
						    inst_sram_en =0 ;
							data_sram_en =1 ;
							MemRead <= 0;
							MemWrite <= 1;
							wen_reg <= 0;
						end
					`LD:
						begin
						    inst_sram_en = 0;
							data_sram_en = 1;
							MemRead <= 1;
							MemWrite <= 0;
							wen_reg <= 0;
						end
					`RDW:
						begin
						    inst_sram_en = 0;
							data_sram_en = 1;
							MemRead <= 0;
							MemWrite <= 0;
							wen_reg <= 0;
						end
					default:
						begin
						    inst_sram_en = 0;
							data_sram_en = 0;
							MemRead <= 0;
							MemWrite <= 0;
							wen_reg <= 0;
						end
				endcase 
			end
	end
	always @(posedge clk) 
	begin
		Instruction_reg <= (current_state == `IW) ? Instruction : Instruction_reg;
	end
	always @(posedge clk) 
	begin
		Read_data_reg <= (current_state == `RDW) ? Read_data : Read_data_reg;
	end
	
//PC
	always@ (posedge clk or posedge resetn)
	begin
		if(resetn) PC <= 32'hbfc00000;
		else if(current_state == `EX)
			begin
				if((Branch & ((Instruction_reg[26]|Instruction_reg[27])^Zero)&(Instruction_reg[31:26]!=6'b000001))|
				((Instruction_reg[31:26]==6'b000110)&(d==0))|//BLEZ
				(Branch & ~(Instruction_reg[16] ^ Zero ) & (Instruction_reg[31:26] == 6'b000001))|
				((ALUResult > 0) & (Instruction_reg[31:26] == 6'b000111)))//BGTZ
				begin
					PC <= PC + 4 +{Sign_extend[29:0],2'b00};
				end
				else if(Instruction_reg[31:27]==5'b00001)//j&jal
				begin
					PC <= {PC[31:28],Instruction_reg[25:0],2'b00};
				end
				else if(((Instruction_reg[31:26]==6'b000000)&(Instruction_reg[5:0]==6'b001000))|((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:0]==6'b001001)))//jr|jalr
				begin	
					PC <= Read_data_1;
				end
				else 
				begin
					PC <= PC + 4;
				end
			end
		else begin
			PC <= PC;
		end
	end
		
	assign s = Instruction_reg[10:6];
	assign Sign_extend = ((Instruction_reg[31:26]==`LUI)  |(Instruction_reg[31:26]==`LBU)|(Instruction_reg[31:26]==`LHU)|
			              (Instruction_reg[31:26]==`SLTIU)|(Instruction_reg[31:26]==`ORI)|(Instruction_reg[31:26]==`ANDI)) ? 
			              {16'b0,Instruction_reg[15:0]} : Instruction_reg[15] ? {16'b1111111111111111,Instruction_reg[15:0]} : {16'b0,Instruction_reg[15:0]};
	assign Address = {ALUResult[31:2],2'b00};

//module			
	reg_file reg_file (
	.clk(clk),
	.resetn(resetn),
	.waddr((Instruction_reg[31:26]==6'b000011) ? 5'b11111 : (RegDst ? Instruction_reg[15:11] : Instruction_reg[20:16])),
	.raddr1(Instruction_reg[25:21]),
	.raddr2(Instruction_reg[20:16]),
	.wen((((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:0]==`MOVN)&Zero)|((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:0]==`MOVZ)&~Zero)) ? 1'b0 : (wen_reg & RegWrite)),
	.wdata(((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:0]==`NOR)) //nor
	? ~ALUResult :(((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:0]==`JALR)) | (Instruction_reg[31:26]==`JAL)) ? 
	(PC+8) : (Instruction_reg[31:26]==`LUI) ?
	 {ALUResult[15:0],16'b0} :((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:1]==5'b00101)) //movz&movn
	 ? Read_data_1 : (MemtoReg ? write : ALUResult)),
	.rdata1(Read_data_1),
	.rdata2(Read_data_2)
	);
	
	
	alu alu(
	.A(((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:0]==`SLLV))?0:Read_data_1),
	.B(ALUSrc ? Sign_extend : Read_data_2),
	.ALUcontrol(ALUcontrol),
	.sll(sll),
	.Overflow(Overflow),
	.CarryOut(CarryOut),
	.Zero(Zero),
	.d(d),
	.Result(ALUResult)
	);
	
	ControlUnit ControlUnit(
	.instruction(Instruction_reg[31:26]),
	.special(Instruction_reg[5:0]),
	.special2(Instruction_reg[25:21]),	
	.RegDst(RegDst),
	.Branch(Branch),
	.MemtoReg(MemtoReg),
	.ALUOp(ALUOp),
	.ALUSrc(ALUSrc)
	);
	
	switch switch(	
	.in(~((Instruction_reg[31:26]==6'b0)&(Instruction_reg[5:3]==3'b0))?5'b0:Instruction_reg[2]?Read_data_1[4:0]:Instruction_reg[10:6]),
	.control(Instruction_reg[1:0]),
	.out(sll)
	);
	
	write_data write_data(
	.in(Read_data_2),
	.control(Instruction_reg[31:26]),
	.ea(ALUResult[1:0]),
	.out(Write_data),
	.strb(Write_strb)
	);
	
	read_data read_data(
	.read(Read_data_reg),
	.r(Read_data_2),
	.control(Instruction_reg[31:26]),
	.ea(ALUResult[1:0]),
	.out(write)
	);
		
	always@(*)
	begin
		case(ALUOp)
		2'b00://add
			begin
				ALUcontrol = 3'b010;
			end
		2'b01://sub
			begin
				ALUcontrol = 3'b110;
			end
		2'b10://more
			begin
				case(Instruction_reg[5:0])
				6'b100000://add
					begin
						ALUcontrol = 3'b010;
					end
				6'b100001://addu
					begin
						ALUcontrol = 3'b010;
					end
				6'b100010://sub
					begin
						ALUcontrol = 3'b110;
					end
				6'b100011://subu
					begin
						ALUcontrol = 3'b110;
					end
				6'b100100://and
					begin
						ALUcontrol = 3'b000;
					end
				6'b100101://or
					begin
						ALUcontrol = 3'b001;
					end
				6'b101010://slt
					begin
						ALUcontrol = 3'b111;
					end
				6'b100111://nor
					begin
						ALUcontrol = 3'b001;
					end
				6'b101011://sltu
					begin
						ALUcontrol = 3'b100;
					end
				6'b001011://movn
					begin
						ALUcontrol = 3'b101;
					end
				6'b001010://movz
					begin
						ALUcontrol = 3'b101;
					end
				6'b100110://xor
					begin
						ALUcontrol = 3'b011;
					end
				6'b000000://sll
					begin
						ALUcontrol = 3'b101;
					end
				6'b000100://sllv
					begin
						ALUcontrol = 3'b101;
					end
				6'b000011://sra
					begin
						ALUcontrol = 3'b101;
					end
				6'b000010://srl
					begin
						ALUcontrol = 3'b101;
					end
				6'b000111://srav
					begin
						ALUcontrol = 3'b101;
					end
				6'b000110://srlv
					begin
						ALUcontrol = 3'b101;
					end				
				default:
					begin
						ALUcontrol = 3'b000;
					end
				endcase
			end
		2'b11:
		begin
			case(Instruction_reg[31:26])
			6'b001011://sltiu
				begin
					ALUcontrol = 3'b100;
				end
			6'b001010://slti
				begin
					ALUcontrol = 3'b111;
				end
			6'b000110://blez
				begin
					ALUcontrol = 3'b111;
				end
			6'b000111://bgtz
				begin
					ALUcontrol = 3'b110;
				end
			6'b001100://andi
				begin
					ALUcontrol = 3'b000;
				end
			6'b001101://ori
				begin
					ALUcontrol = 3'b001;
				end
			6'b001110://xori
				begin
					ALUcontrol = 3'b011;
				end
			default:
				begin
					ALUcontrol = 3'b000;
				end
			endcase
		end
		default:
			begin
				ALUcontrol = 3'b000;
			end
		endcase
	end	

endmodule		