`timescale 1ns / 1ps
module projectCPU(clk, rst, data_fromRAM, wrEn, addr_toRAM, data_toRAM, pCounter);
// Burak KARA S009893

parameter SIZE = 10;

input clk, rst;
input wire [15:0] data_fromRAM;
output reg wrEn;
output reg [SIZE-1:0] addr_toRAM;
output reg [15:0] data_toRAM;
output reg [SIZE-1:0] pCounter;

// internal signals
reg [ 2:0] opcode, opcodeNxt;
reg [9:0] operand, operandNxt;
reg [15:0] W, Wnxt;
reg [SIZE-1:0] /*pCounter*/ pCounterNxt;
reg [15:0] num, numNext;
reg [ 2:0] state, stateNext;

always @(posedge clk)begin
	state   <= #1 stateNext;
	pCounter<= #1 pCounterNxt;
	W       <= #1 Wnxt;
	opcode  <= #1 opcodeNxt;
	operand <= #1 operandNxt;
	num     <= #1 numNext;
end

always @*begin
	stateNext  = state;
	pCounterNxt= pCounter;	
	Wnxt 	     = W;
	opcodeNxt  = opcode;
	operandNxt = operand;
	numNext    = num;
	addr_toRAM = 0;
	wrEn       = 0;
	data_toRAM = 0;
	if(rst)
		begin
		stateNext  = 0;
		pCounterNxt= 0;
		opcodeNxt  = 0;
		operandNxt = 0;
		numNext    = 0;
		addr_toRAM = 0;
		wrEn       = 0;
		data_toRAM = 0;
		end
	else
	case(state)
		// take instruction
		0: begin			
			addr_toRAM = pCounter;
			stateNext  = 1;
		end
		1: begin 		
			opcodeNxt  = data_fromRAM[15:13];
			operandNxt = data_fromRAM[12:0];
			addr_toRAM = operandNxt == 0 ? 4 : operandNxt; // demand *4 or *A
			stateNext  = operandNxt == 0 ? 2 : 3;
		end
      2: begin
			operandNxt = data_fromRAM;			
			addr_toRAM = operandNxt;				// demand **4
			stateNext  = 3;			
		end
		3: begin
			pCounterNxt = pCounter + 1;
			numNext     = data_fromRAM;
			case(opcode)
				3'b000: begin	            		// ADD
					Wnxt = numNext + W;
				end
				3'b001: begin							// NAND
					Wnxt = ~(numNext & W);
				end
				3'b010: begin							//  SRL
					Wnxt = numNext <= 16 ? W >> numNext : W << (numNext - 16);
				end
				3'b011: begin							// LT
					Wnxt = W < numNext;
				end
				3'b100: begin 							// BZ
					pCounterNxt = W == 0 ? numNext : pCounter + 1;
				end
				3'b101: begin 							// CP2W
					Wnxt = numNext;
				end
				3'b110: begin 							// CPfW
					wrEn 		  = 1;
					addr_toRAM = operand;
					data_toRAM = W;
				end
				3'b111: begin 							// MUL
					Wnxt = W * numNext;
				end
			endcase	
			stateNext = 0;
		end	
		default: begin
			pCounterNxt= 0;
			stateNext  = 0;
			Wnxt	     = 0;
			opcodeNxt  = 0;
			operandNxt = 0;
			numNext    = 0;
			addr_toRAM = 0;
			wrEn       = 0;
			data_toRAM = 0;
		end
	endcase
end
endmodule
