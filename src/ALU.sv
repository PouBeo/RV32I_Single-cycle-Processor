`include "D:/BKU/CTMT/2011919_Processor/Parameter.sv"
/////////////////////////////////////////////////////////////////////
// Module: ALU
// Description:
/////////////////////////////////////////////////////////////////////
module ALU
(
  input  logic [31:0] operand1_i,
  input  logic [31:0] operand2_i,
  input  logic [ 3:0] alu_op_i,
  
  output logic [31:0] alu_data_o
);
  logic [31:0] add_result;
  logic [31:0] sub_result;
  logic [31:0] sll_result;
  logic [31:0] slt_result;
  logic [31:0] sltu_result;
  logic [31:0] srl_result;
  logic [31:0] sra_result;

  logic slt_temp;
  logic sltu_temp;

  addsub_32b        ALU_ADD (.A( operand1_i ), .B( operand2_i ), .add_sub( 1'b0 ), .S( add_result ));
  addsub_32b        ALU_SUB (.A( operand1_i ), .B( operand2_i ), .add_sub( 1'b1 ), .S( sub_result ), .carry_o( sltu_temp ));
  shift_left        ALU_SLL (.in1( operand1_i ), .in2( operand2_i[4:0] ), .out( sll_result ));
  shift_right       ALU_SRL (.in1( operand1_i ), .in2( operand2_i[4:0] ), .out( srl_result ));
  shift_right_arith ALU_SRA (.in1( operand1_i ), .in2( operand2_i[4:0] ), .out( sra_result ));
  set_less_than     ALU_SLT (.s_in1( operand1_i[31] ), .s_in2( operand2_i[31] ), .s_sub( sub_result[31] ), .slt( slt_temp ));

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
  input 	logic sel, Cin,
  output logic [3:0] S,
  output logic	Co, V
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
////                    => (slt = sign_of_A-B )
 
  always_comb begin
    if ( s_in1 != s_in2 ) begin
      slt = s_in1 ;
      end
    else begin
      slt = s_sub ;
      end
  end
  
endmodule: set_less_than

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

module shift_left
(
  input  logic [31:0] in1,
  input  logic [ 4:0] in2,
  output logic [31:0] out
);
  logic [31:0] out_temp;

  always_comb begin
        case (in2)
               5'b00000: out_temp = in1 ;
               5'b00001: out_temp = {in1[30:0], 1'b0};
               5'b00010: out_temp = {in1[29:0], 2'b0};
               5'b00011: out_temp = {in1[28:0], 3'b0};
               5'b00100: out_temp = {in1[27:0], 4'b0};
               5'b00101: out_temp = {in1[26:0], 5'b0};
               5'b00110: out_temp = {in1[25:0], 6'b0};
               5'b00111: out_temp = {in1[24:0], 7'b0};
               5'b01000: out_temp = {in1[23:0], 8'b0};
               5'b01001: out_temp = {in1[22:0], 9'b0};
               5'b01010: out_temp = {in1[21:0], 10'b0};
               5'b01011: out_temp = {in1[20:0], 11'b0};
               5'b01100: out_temp = {in1[19:0], 12'b0};
               5'b01101: out_temp = {in1[18:0], 13'b0};
               5'b01110: out_temp = {in1[17:0], 14'b0};
               5'b01111: out_temp = {in1[16:0], 15'b0};
               5'b10000: out_temp = {in1[15:0], 16'b0};
               5'b10001: out_temp = {in1[14:0], 17'b0};
               5'b10010: out_temp = {in1[13:0], 18'b0};
               5'b10011: out_temp = {in1[12:0], 19'b0};
               5'b10100: out_temp = {in1[11:0], 20'b0};
               5'b10101: out_temp = {in1[10:0], 21'b0};
               5'b10110: out_temp = {in1[9:0], 22'b0};
               5'b10111: out_temp = {in1[8:0], 23'b0};
               5'b11000: out_temp = {in1[7:0], 24'b0};
               5'b11001: out_temp = {in1[6:0], 25'b0};
               5'b11010: out_temp = {in1[5:0], 26'b0};
               5'b11011: out_temp = {in1[4:0], 27'b0};
               5'b11100: out_temp = {in1[3:0], 28'b0};
               5'b11101: out_temp = {in1[2:0], 29'b0};
               5'b11110: out_temp = {in1[1:0], 30'b0};
               5'b11111: out_temp = {in1[0], 31'b0};
           default: out_temp = 32'b0;
           endcase
  end

  assign out = out_temp;

endmodule: shift_left

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

module shift_right
(	
  input  logic [31:0] in1,
  input  logic [ 4:0] in2,
  output logic [31:0] out
);    
  logic [31:0] out_temp;

    always_comb begin
        case (in2)
                     5'b00000: out_temp = in1;
                     5'b00001: out_temp = {1'b0, in1[31:1]};
                     5'b00010: out_temp = {2'b0, in1[31:2]};
                     5'b00011: out_temp = {3'b0, in1[31:3]};
                     5'b00100: out_temp = {4'b0, in1[31:4]};
                     5'b00101: out_temp = {5'b0, in1[31:5]};
                     5'b00110: out_temp = {6'b0, in1[31:6]};
                     5'b00111: out_temp = {7'b0, in1[31:7]};
                     5'b01000: out_temp = {8'b0, in1[31:8]};
                     5'b01001: out_temp = {9'b0, in1[31:9]};
                     5'b01010: out_temp = {10'b0, in1[31:10]};
                     5'b01011: out_temp = {11'b0, in1[31:11]};
                     5'b01100: out_temp = {12'b0, in1[31:12]};
                     5'b01101: out_temp = {13'b0, in1[31:13]};
                     5'b01110: out_temp = {14'b0, in1[31:14]};
                     5'b01111: out_temp = {15'b0, in1[31:15]};
                     5'b10000: out_temp = {16'b0, in1[31:16]};
                     5'b10001: out_temp = {17'b0, in1[31:17]};
                     5'b10010: out_temp = {18'b0, in1[31:18]};
                     5'b10011: out_temp = {19'b0, in1[31:19]};
                     5'b10100: out_temp = {20'b0, in1[31:20]};
                     5'b10101: out_temp = {21'b0, in1[31:21]};
                     5'b10110: out_temp = {22'b0, in1[31:22]};
                     5'b10111: out_temp = {23'b0, in1[31:23]};
                     5'b11000: out_temp = {24'b0, in1[31:24]};
                     5'b11001: out_temp = {25'b0, in1[31:25]};
                     5'b11010: out_temp = {26'b0, in1[31:26]};
                     5'b11011: out_temp = {27'b0, in1[31:27]};
                     5'b11100: out_temp = {28'b0, in1[31:28]};
                     5'b11101: out_temp = {29'b0, in1[31:29]};
                     5'b11110: out_temp = {30'b0, in1[31:30]};
                     5'b11111: out_temp = {31'b0, in1[31:31]};
                endcase
    end

    assign out = out_temp;

endmodule: shift_right

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

module shift_right_arith 
(	
  input  logic [31:0] in1,
  input  logic [ 4:0] in2,
  output logic [31:0] out
);    
  logic [31:0] out_temp;

    always_comb begin
        case (in1[31])      
            0: begin
                case (in2)
                     5'b00000: out_temp = in1;
                     5'b00001: out_temp = {1'b0, in1[31:1]};
                     5'b00010: out_temp = {2'b0, in1[31:2]};
                     5'b00011: out_temp = {3'b0, in1[31:3]};
                     5'b00100: out_temp = {4'b0, in1[31:4]};
                     5'b00101: out_temp = {5'b0, in1[31:5]};
                     5'b00110: out_temp = {6'b0, in1[31:6]};
                     5'b00111: out_temp = {7'b0, in1[31:7]};
                     5'b01000: out_temp = {8'b0, in1[31:8]};
                     5'b01001: out_temp = {9'b0, in1[31:9]};
                     5'b01010: out_temp = {10'b0, in1[31:10]};
                     5'b01011: out_temp = {11'b0, in1[31:11]};
                     5'b01100: out_temp = {12'b0, in1[31:12]};
                     5'b01101: out_temp = {13'b0, in1[31:13]};
                     5'b01110: out_temp = {14'b0, in1[31:14]};
                     5'b01111: out_temp = {15'b0, in1[31:15]};
                     5'b10000: out_temp = {16'b0, in1[31:16]};
                     5'b10001: out_temp = {17'b0, in1[31:17]};
                     5'b10010: out_temp = {18'b0, in1[31:18]};
                     5'b10011: out_temp = {19'b0, in1[31:19]};
                     5'b10100: out_temp = {20'b0, in1[31:20]};
                     5'b10101: out_temp = {21'b0, in1[31:21]};
                     5'b10110: out_temp = {22'b0, in1[31:22]};
                     5'b10111: out_temp = {23'b0, in1[31:23]};
                     5'b11000: out_temp = {24'b0, in1[31:24]};
                     5'b11001: out_temp = {25'b0, in1[31:25]};
                     5'b11010: out_temp = {26'b0, in1[31:26]};
                     5'b11011: out_temp = {27'b0, in1[31:27]};
                     5'b11100: out_temp = {28'b0, in1[31:28]};
                     5'b11101: out_temp = {29'b0, in1[31:29]};
                     5'b11110: out_temp = {30'b0, in1[31:30]};
                     5'b11111: out_temp = {31'b0, in1[31:31]};
                endcase
            end
            1: begin
                case (in2)
                     5'b00000: out_temp = in1;
                     5'b00001: out_temp = {{1{1'b1}}, in1[31:1]};
                     5'b00010: out_temp = {{2{1'b1}}, in1[31:2]};
                     5'b00011: out_temp = {{3{1'b1}}, in1[31:3]};
                     5'b00100: out_temp = {{4{1'b1}}, in1[31:4]};
                     5'b00101: out_temp = {{5{1'b1}}, in1[31:5]};
                     5'b00110: out_temp = {{6{1'b1}}, in1[31:6]};
                     5'b00111: out_temp = {{7{1'b1}}, in1[31:7]};
                     5'b01000: out_temp = {{8{1'b1}}, in1[31:8]};
                     5'b01001: out_temp = {{9{1'b1}}, in1[31:9]};
                     5'b01010: out_temp = {{10{1'b1}}, in1[31:10]};
                     5'b01011: out_temp = {{11{1'b1}}, in1[31:11]};
                     5'b01100: out_temp = {{12{1'b1}}, in1[31:12]};
                     5'b01101: out_temp = {{13{1'b1}}, in1[31:13]};
                     5'b01110: out_temp = {{14{1'b1}}, in1[31:14]};
                     5'b01111: out_temp = {{15{1'b1}}, in1[31:15]};
                     5'b10000: out_temp = {{16{1'b1}}, in1[31:16]};
                     5'b10001: out_temp = {{17{1'b1}}, in1[31:17]};
                     5'b10010: out_temp = {{18{1'b1}}, in1[31:18]};
                     5'b10011: out_temp = {{19{1'b1}}, in1[31:19]};
                     5'b10100: out_temp = {{20{1'b1}}, in1[31:20]};
                     5'b10101: out_temp = {{21{1'b1}}, in1[31:21]};
                     5'b10110: out_temp = {{22{1'b1}}, in1[31:22]};
                     5'b10111: out_temp = {{23{1'b1}}, in1[31:23]};
                     5'b11000: out_temp = {{24{1'b1}}, in1[31:24]};
                     5'b11001: out_temp = {{25{1'b1}}, in1[31:25]};
                     5'b11010: out_temp = {{26{1'b1}}, in1[31:26]};
                     5'b11011: out_temp = {{27{1'b1}}, in1[31:27]};
                     5'b11100: out_temp = {{28{1'b1}}, in1[31:28]};
                     5'b11101: out_temp = {{29{1'b1}}, in1[31:29]};
                     5'b11110: out_temp = {{30{1'b1}}, in1[31:30]};
                     5'b11111: out_temp = {{31{1'b1}}, in1[31:31]};

                endcase
            end
        endcase
    end

    assign out = out_temp;

endmodule: shift_right_arith