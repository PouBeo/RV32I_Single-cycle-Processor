`timescale 1ns/1ps

module tb_PC;

  logic clk_i;
  logic br_sel_i;
  logic [31:0] alu_data_i;
  logic [31:0] pc_o;

  PC_block uut (
    .clk_i     ( clk_i      ),
    .br_sel_i  ( br_sel_i   ),
    .alu_data_i( alu_data_i ),
    .pc_o      ( pc_o       )
  );

  initial begin
    clk_i = 0;
    forever #10 clk_i = ~clk_i; 
  end

  initial begin
    $monitor("Time: %0t         | clk_i: %0b  | alu_data_i: %h  | br_sel_i: %0b  | pc_o: %h", 
             $time,               clk_i,        alu_data_i,       br_sel_i,        pc_o);
    
	 alu_data_i = 32'hFFFF_FFFF;
    br_sel_i   = 1;           //PC+4
	 
	 #200;   
    alu_data_i = 32'h12345600;
	 br_sel_i   = 0;           //ALU_data
    #50 check_PC_ALUdata();
	 #50;
	 br_sel_i   = 1;
    
	 #200;
	 alu_data_i = 32'h87654300;
	 br_sel_i   = 0;
	 #50 check_PC_ALUdata(); 
    #50;
	 br_sel_i   = 1;
	 
	 #200;
	 alu_data_i = 32'hA5A5A500;
	 br_sel_i   = 0;
    #50 check_PC_ALUdata();
	 #50;
	 br_sel_i   = 1;
	 
    #200;
	 alu_data_i = 32'hF0F0F000;
	 br_sel_i   = 0;
    #50 check_PC_ALUdata(); 
	 #50;
	 br_sel_i   = 1;
	 
    #200 $finish;
  end

  task check_PC_ALUdata();
    if (alu_data_i === pc_o) begin
      $display("Time: %0t | Success: alu_data_i (%h) matches pc_o (%h)", $time, alu_data_i, pc_o);
    end else begin
      $display("Time: %0t | Error: alu_data_i (%h) does not match pc_o (%h)", $time, alu_data_i, pc_o);
    end
  endtask

endmodule
