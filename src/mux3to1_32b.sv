module mux3to1_32b (
  input  logic [ 1:0]  sel_i,
  input  logic [31:0]  data0_i,
  input  logic [31:0]  data1_i,
  input  logic [31:0]  data2_i,
  output logic [31:0]  data_o
);
  assign data_o = ( sel_i == 2'b00 ) ? data0_i :
                  ( sel_i == 2'b01 ) ? data1_i :
                  ( sel_i == 2'b10 ) ? data2_i : 32'bx ;
endmodule
