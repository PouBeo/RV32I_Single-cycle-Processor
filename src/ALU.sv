`timescale 1ns / 1ps
`include "D:/BKU/CTMT/2011919_Pipelined_Processor/Parameter.sv"
module ALU
(
  input  logic [31:0] operand1_i ,
  input  logic [31:0] operand2_i ,
  input  logic [ 3:0] alu_op_i ,
  
  output logic [31:0] alu_data_o
);
  logic [31:0] add_result ;
  logic [31:0] sub_result ;
  logic [31:0] sll_result ;
  logic [31:0] slt_result ;
  logic [31:0] sltu_result ;
  logic [31:0] srl_result ;
  logic [31:0] sra_result ;

  logic slt_temp ;
  logic sltu_temp ;

  addsub_32b            ALU_ADD (.A( operand1_i ), .B( operand2_i ), .add_sub( 1'b0 ), .S( add_result ));
  addsub_32b            ALU_SUB (.A( operand1_i ), .B( operand2_i ), .add_sub( 1'b1 ), .S( sub_result ), .carry_o( sltu_temp ));
  shift_left_32b        ALU_SLL (.in( operand1_i ), .shamt( operand2_i[4:0] ), .out( sll_result ));
  shift_right_32b       ALU_SRL (.in( operand1_i ), .shamt( operand2_i[4:0] ), .out( srl_result ));
  shift_right_arith_32b ALU_SRA (.in( operand1_i ), .shamt( operand2_i[4:0] ), .out( sra_result ));
  set_less_than         ALU_SLT (.s_in1( operand1_i[31] ), .s_in2( operand2_i[31] ), .s_sub( sub_result[31] ), .slt( slt_temp ));

  assign  slt_result  = { 31'b0,   slt_temp } ;
  assign  sltu_result = { 31'b0, ~sltu_temp } ;

  always@(*)
    begin
        case( alu_op_i )
            `ADD :  alu_data_o <= add_result ;
            `SUB :  alu_data_o <= sub_result ;
            `SLL :  alu_data_o <= sll_result ;
            `SLT :  alu_data_o <= slt_result ;
            `SLTU:  alu_data_o <= sltu_result ;
            `XOR :  alu_data_o <= operand1_i ^ operand2_i ;
            `SRL :  alu_data_o <= srl_result ;
            `SRA :  alu_data_o <= sra_result ;
            `OR  :  alu_data_o <= operand1_i | operand2_i ;
            `AND :  alu_data_o <= operand1_i & operand2_i ;
            `LUI :  alu_data_o <= {operand2_i[31:12],12'd0} ;
            default:    alu_data_o <= 32'b0;
        endcase
    end

endmodule: ALU

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module fulladder
(
  input  logic A, B, Ci,
  output logic S, Co
);
  assign  S  = A ^ B ^ Ci;
  assign  Co = (A & B)|(A & Ci)|( B& Ci); // Co = AB + Ci(A^B)

endmodule:  fulladder

///////////////////////////////////////////////////////////////

module addsub_4b
(
  input  logic [3:0] A, B,
  input  logic sel, Cin,
  output logic [3:0] S,
  output logic Co, V
);
  logic [2:0] c;
  logic [3:0] b;
  
  assign b[0] = B[0]^sel ; // sel = 0 if ADD ( b^0 = b ), sel = 1 if SUB ( b^1 = ~b )
  assign b[1] = B[1]^sel ;
  assign b[2] = B[2]^sel ;
  assign b[3] = B[3]^sel ;
  
  fulladder u0( .A( A[0] ), .B( b[0] ), .Ci( Cin  ), .S( S[0] ), .Co( c[0] )); // Cin shoulb be 'sel': SUB when (sel = 1), a - b = a + (~b) + 1 
  fulladder u1( .A( A[1] ), .B( b[1] ), .Ci( c[0] ), .S( S[1] ), .Co( c[1] ));
  fulladder u2( .A( A[2] ), .B( b[2] ), .Ci( c[1] ), .S( S[2] ), .Co( c[2] ));
  fulladder u3( .A( A[3] ), .B( b[3] ), .Ci( c[2] ), .S( S[3] ), .Co( Co   ));

  assign V = Co ^ c[2] ; // V = 1: overflow
  
endmodule: addsub_4b


///////////////////////////////////////////////////////////////

module addsub_32b 
(
  input  logic [31: 0] A, B,
  input  logic add_sub,
  
  output logic [31: 0] S,
  output logic V, carry_o
);
  logic [ 7: 0] carry_in ;
  
  addsub_4b byte_03_00 (.A( A[ 3: 0] ), .B( B[ 3: 0] ), .sel( add_sub ), .Cin( add_sub     ), .S( S[ 3: 0] ), .Co( carry_in[0] ));
  addsub_4b byte_07_04 (.A( A[ 7: 4] ), .B( B[ 7: 4] ), .sel( add_sub ), .Cin( carry_in[0] ), .S( S[ 7: 4] ), .Co( carry_in[1] ));
  addsub_4b byte_11_08 (.A( A[11: 8] ), .B( B[11: 8] ), .sel( add_sub ), .Cin( carry_in[1] ), .S( S[11: 8] ), .Co( carry_in[2] ));
  addsub_4b byte_15_12 (.A( A[15:12] ), .B( B[15:12] ), .sel( add_sub ), .Cin( carry_in[2] ), .S( S[15:12] ), .Co( carry_in[3] ));
  addsub_4b byte_19_16 (.A( A[19:16] ), .B( B[19:16] ), .sel( add_sub ), .Cin( carry_in[3] ), .S( S[19:16] ), .Co( carry_in[4] ));
  addsub_4b byte_23_20 (.A( A[23:20] ), .B( B[23:20] ), .sel( add_sub ), .Cin( carry_in[4] ), .S( S[23:20] ), .Co( carry_in[5] ));
  addsub_4b byte_27_24 (.A( A[27:24] ), .B( B[27:24] ), .sel( add_sub ), .Cin( carry_in[5] ), .S( S[27:24] ), .Co( carry_in[6] ));
  addsub_4b byte_31_28 (.A( A[31:28] ), .B( B[31:28] ), .sel( add_sub ), .Cin( carry_in[6] ), .S( S[31:28] ), .Co( carry_in[7] ), .V(V));

  assign carry_o = carry_in[7] ;

endmodule: addsub_32b

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

module set_less_than
(
  input  logic s_in1, s_in2, s_sub,  // sign of in1, in2 and sub (in1 - in2)

  output logic slt
);  

  // CASE { sign_of_A != sign_of_B }: base on sign-bit => avoid overflow case when using SUB
//// [ -A; +B] => ( slt = 1 ) 
//// [ +A; -B] => ( slt = 0 )
////           => ( slt = sign_of_A ) 

  // CASE { sign_of_A  = sign_of_B }: overflow not happen when operating SUB with the same sign of A and B
//// [ -A - (-B) >= 0 ] => ( slt = 0 )
//// [ +A - (+B) >= 0 ] => ( slt = 0 )
//// [ -A - (-B)  < 0 ] => ( slt = 1 )
//// [ +A - (+B)  < 0 ] => ( slt = 1 )
////                    => ( slt = sign_of_A-B )
 
  always_comb begin
    if ( s_in1 != s_in2 ) begin
      slt = s_in1 ;
      end
    else begin
      slt = s_sub ;
      end
  end
  
endmodule: set_less_than
