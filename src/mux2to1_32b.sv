module mux2to1_32b (
  input  logic sel_i,
  input  logic [31:0]  data0_i,
  input  logic [31:0]  data1_i,
  output logic [31:0]  data_o
);
  assign data_o = (!sel_i) ? data0_i : data1_i ;
  
endmodule
