`timescale 1ns / 1ps
 
module tb;
parameter SIZE = 10, DEPTH = 1024;

reg clk;
integer f;

initial begin
  clk = 1;
  forever
	  #5 clk = ~clk;
end

reg rst;
initial begin
  // $dumpvars;
  rst = 1;
  repeat (10) @(posedge clk);
  rst <= #1 0;
  repeat (10000) @(posedge clk);
  $fwrite(f,"Simulation finished due Time Limit\nTested Count %d\nTotal Errors %d", testCount, errorCount);
  $fclose(f);
  $finish;
end

wire [SIZE-1:0] addr_toRAM;
wire [15:0] data_toRAM, data_fromRAM;
wire [SIZE-1:0] pCounter;

SimpleCPU SimpleCPU(
  .clk(clk),
  .rst(rst),
  .wrEn(wrEn),
  .data_fromRAM(data_fromRAM),
  .addr_toRAM(addr_toRAM),
  .data_toRAM(data_toRAM),
  .pCounter(pCounter)
);

blram #(SIZE, DEPTH) blram(
  .clk(clk),
  .rst(rst),
  .i_we(wrEn),
  .i_addr(addr_toRAM),
  .i_ram_data_in(data_toRAM),
  .o_ram_data_out(data_fromRAM)
);


initial begin
  f = $fopen("output.txt","w");
end

reg [8:0] testCount = 0;
reg [8:0] errorCount = 0;
always@(pCounter) begin
	
	case(testCount - 1)
		6: memCheck(201,2,"CP");
		12: memCheck(203,5,"CPi");
		15: memCheck(204,8,"SRL");
		18: memCheck(206,40,"SRL");
		25: memCheck(208,1,"SRLi");
		32: memCheck(209,144,"SRLi");
		35: memCheck(210,65535,"NAND");
		38: memCheck(210,0,"NAND");
		41: memCheck(212,65533,"NAND");
		44: memCheck(212,2,"NAND");
		51: memCheck(214,65535,"NANDi");
		54: memCheck(214,0,"NAND");
		61: memCheck(215,65533,"NANDi");
		64: memCheck(215,2,"NAND");
		67: memCheck(216,1,"LT");
		70: memCheck(217,0,"LT");
		73: memCheck(218,0,"LT");
		80: memCheck(220,1,"LTi");
		87: memCheck(221,0,"LTi");
		94: memCheck(222,0,"LTi");
		97: memCheck(223,0,"ADD");
		104: memCheck(224,0,"ADDi");
		107: memCheck(225,63,"MUL");
		114: memCheck(227,27,"MULi");
		116: pCounterCheck(123,"BZJ");
		122: memCheck(230,2,"CPi");
		124: pCounterCheck(125,"BZJ");
		130: memCheck(233,3,"CPi");
		139: pCounterCheck(146,"BZJi");
		145: memCheck(235,2,"CPi");
		149: memCheck(236,5," CPI");
		153: memCheck(240,5,"CPIi"); 
		158: memCheck(244,7,"ADDI");
		163: memCheck(246,65535,"NANDI");
		168: memCheck(246,0,"NANDI");
		173: memCheck(249,8,"SRLI");
		178: memCheck(252,40,"SRLI");
		182: pCounterCheck(189,"BZI");
		188: memCheck(264,2,"CPi");
		192: pCounterCheck(193,"BZI");
		198: memCheck(268,3,"CPi");
		304: memCheck(255,0,"LTI");
		309: memCheck(257,0,"LTI");
		314: memCheck(259,1,"LTI");
		319: begin
			memCheck(270,63,"MULI"); 
			//$display("Total Errors %d\n", errorCount);
			$fwrite(f,"Total Errors %d", errorCount);
			$fclose(f); 
			$finish;
		end
	endcase
	
	testCount = pCounter + 1;
	
end

task memCheck;
    input [31:0] memLocation, expectedValue;
	input [47:0] instCode; 
    begin
      if(blram.memory[memLocation] != expectedValue) begin
			//$display("Error Found on test code %d, Instruction code %s, %d ns, RAM Addr %d,  expected %d, received %d", testCount -1, instCode, $time, memLocation, expectedValue, blram.memory[memLocation]);
			$fwrite(f,"Error Found on test code %d, Instruction code %s, %d ns, RAM Addr %d,  expected %d, received %d\n", testCount -1, instCode, $time, memLocation, expectedValue, blram.memory[memLocation]);
			errorCount = errorCount + 1;
		end
    end
endtask

task pCounterCheck;
    input [31:0] pCounterExpected, instCode; 
    begin
      if(pCounter != pCounterExpected) begin
			//$display("Error Found on test code %d, Instruction code %s, %d ns expected %d, received %d", testCount -1, instCode, $time, pCounterExpected, pCounter);
			$fwrite(f,"Error Found on test code %d, Instruction code %s, %d ns expected %d, received %d\n", testCount -1, instCode, $time, pCounterExpected, pCounter);
			errorCount = errorCount + 1;
		end
    end
endtask

endmodule
