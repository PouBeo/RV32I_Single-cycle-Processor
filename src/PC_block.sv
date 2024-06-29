module pc_plus_4(
  input  logic [31:0] pc_i ,
  output logic [31:0] pc4_o
);
  assign pc4_o = pc_i + 4;

endmodule: pc_plus_4

///////////////////////////////////////////////////////////////////////////

module PC_block
(
  input  logic  clk_i ,
  input  logic  br_sel_i ,
  
  input  logic [31:0] alu_data_i ,
  
  output logic [31:0] pc_o
);
  
  logic [31:0] pc4 ;
  logic [31:0] nxt_pc ;

  pc_plus_4 PC_PLUS_4( 
    .pc_i ( pc_o ),
    .pc4_o( pc4  )
	 );
  
  mux2_1_32b PC_MUX (
    .data0_i( alu_data_i ),
    .data1_i( pc4        ),
    .sel_i  ( br_sel_i   ),
    .data_o ( nxt_pc     )
	 );

  always_ff @( posedge clk_i ) begin : PC_FF
	     pc_o  <= nxt_pc  ;
        end
  
  initial begin
    pc_o = 0; 
  end
  
endmodule: PC_block

///////////////////////////////////////////////////////////////////////////

module mux2_1_32b
(
  input  logic  sel_i ,

  input  logic [31:0] data0_i ,
  input  logic [31:0] data1_i ,

  output logic [31:0] data_o	
);

  assign data_o = (sel_i) ? data1_i : data0_i ;
  
endmodule: mux2_1_32b
  


