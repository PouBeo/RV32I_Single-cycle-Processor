`timescale 1ns / 1ps
module tb_ALU;

  logic [31:0] a_i  ;
  logic [31:0] b_i  ;
  logic [ 3:0] sel_i;
  logic [31:0] alu_x;
  logic [31:0] alu_o;

  ALU uut (   
	.operand1_i	( a_i	),
	.operand2_i	( b_i	),
	.alu_op_i   ( sel_i	),
	.alu_data_o ( alu_o	));

  task tk_expect(input logic [31:0] alu_x );

    $display("[%3d] a_i = %10h, b_i = %10h,  sel_i = %7d, alu_x = %10h, alu_o = %10h", $time, a_i, b_i, sel_i, alu_x, alu_o ); 
    assert( (alu_x == alu_o)) else begin
      $display("TEST FAILED");
    end
  endtask

  initial begin

    repeat(100) begin  // ADD TEST
    a_i = $random;
    b_i = $random;
    sel_i = 4'd0;
    alu_x = a_i + b_i; 
     #1 tk_expect(alu_x);
     #49;
    end

    repeat(100) begin  // SUB TEST
    a_i = $random;
    b_i = $random;
    sel_i = 4'd1;
    alu_x = a_i - b_i; 
     #1 tk_expect(alu_x);
     #49;
    end

    repeat(100) begin  // SLL TEST
    a_i = $random;
    b_i = $random;
    sel_i = 4'd2;
    alu_x = a_i << b_i[4:0]; 
     #1 tk_expect(alu_x);
     #49;
    end

    repeat(100) begin  // SLT TEST
    a_i = $random;
    b_i = $random;
    sel_i = 4'd3;
    alu_x = $signed(a_i) < $signed(b_i) ? 32'd1 : 32'd0; 
     #1 tk_expect(alu_x);
     #49;
    end
 


    repeat(100) begin  // SLTU TEST
    a_i = $random;
    b_i = $random;
    sel_i = 4'd4;
    alu_x = $unsigned(a_i) < $unsigned(b_i) ? 32'd1 : 32'd0;
     #1 tk_expect(alu_x);
     #49;
    end

    repeat(100) begin  // XOR TEST
    a_i = $random;
    b_i = $random;
    sel_i = 4'd5;
    alu_x = a_i ^ b_i;
     #1 tk_expect(alu_x);
     #49;
    end

    repeat(100) begin  // SRL TEST
    a_i = $random;
    b_i = $random;
    sel_i = 4'd6;
    alu_x = a_i >> b_i[4:0]; 
      #1 tk_expect(alu_x);
      #49;
    end

    repeat(100) begin  // SRA TEST
    a_i = $random;
    b_i = $random;
    sel_i = 4'd7;
    alu_x = $signed(a_i) >>> b_i[4:0]; 
     #1 tk_expect(alu_x);
     #49;
    end

    repeat(100) begin  // OR TEST
    a_i = $random;
    b_i = $random;
    sel_i = 4'd8;
    alu_x = a_i | b_i;
     #1 tk_expect(alu_x);
     #49;
    end

    repeat(100) begin  // AND TEST
    a_i = $random;
    b_i = $random;
    sel_i = 4'd9;
    alu_x = a_i & b_i; 
      #1 tk_expect(alu_x);
      #49;
    end

    repeat(100) begin  // LUI TEST
    a_i = $random;
    b_i = $random;
    sel_i = 4'd10;
    alu_x = {b_i[31:12], 12'd0};
     #1 tk_expect(alu_x);
     #49;
    end

    $display("TEST PASSED");
    $stop;
    $finish;
  end
endmodule