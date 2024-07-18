`timescale 1ns / 1ps

module tb_lsu;

  logic clk;
  logic rst_ni;
  logic sten_i;
  logic [ 3:0] byte_num_i;
  logic [31:0] addr_i;
  logic [31:0] st_data_i;
  logic [31:0] io_sw_i;
  logic [31:0] io_push_i;
  logic [31:0] ld_data_o;
  logic [31:0] io_lcd_o;
  logic [31:0] io_ledg_o;
  logic [31:0] io_ledr_o;
  logic [31:0] io_hex0_o;
  logic [31:0] io_hex1_o;
  logic [31:0] io_hex2_o;
  logic [31:0] io_hex3_o;
  logic [31:0] io_hex4_o;
  logic [31:0] io_hex5_o;
  logic [31:0] io_hex6_o;
  logic [31:0] io_hex7_o;

  // Instantiate the LSU module
  lsu dut (
    .clk_i	(	clk		),
    .rst_ni	(	rst_ni		),
    .sten_i	(	sten_i		),
    .byte_num_i	(	byte_num_i	),
    .addr_i	(	addr_i		),
    .st_data_i	(	st_data_i	),
    .io_sw_i	(	io_sw_i		),
    .io_push_i	(	io_push_i	),
    .ld_data_o	(	ld_data_o	),
    .io_lcd_o	(	io_lcd_o	),
    .io_ledg_o	(	io_ledg_o	),
    .io_ledr_o	(	io_ledr_o	),
    .io_hex0_o	(	io_hex0_o	),
    .io_hex1_o	(	io_hex1_o	),
    .io_hex2_o	(	io_hex2_o	),
    .io_hex3_o	(	io_hex3_o	),
    .io_hex4_o	(	io_hex4_o	),
    .io_hex5_o	(	io_hex5_o	),
    .io_hex6_o	(	io_hex6_o	),
    .io_hex7_o	(	io_hex7_o	)
  );
  
  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Task to perform store operation
  task LSU_result () ;
    $display("- Address: 0x%h \n Num-of-byte: %b ;\n Data_store: %h ;\n Data_load : %h ;\n -- -- -- --", addr_i[11:0], byte_num_i, st_data_i, ld_data_o);
	#50;
  endtask
  
  initial begin
	  #100;
         rst_ni = 0;
	  #10;
         rst_ni = 1;
	  #100;

     // WORD - DMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = {12'h0, $random} & 32'h7FF;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // halfWORD - DMEM
     repeat(10) begin
         byte_num_i = 4'b0011     ;
         addr_i     = {12'h0, $random} & 32'h7FF;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // BYTE - DMEM
     repeat(10) begin
         byte_num_i = 4'b0001     ;
         addr_i     = {12'h0, $random} & 32'h7FF;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - OPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h800	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end


     // WORD - OPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h810	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - OPMEM 
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h820	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - OPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h830	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
         sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - OPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h840	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - OPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h850	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - OPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h860	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - OPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h870	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - OPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h880	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - OPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h890	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - OPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h8A0	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - IPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h900	  ;
         st_data_i  = $random	  ;
	 io_sw_i    = st_data_i	  ;
  	 io_push_i  = 32'hFFFFFFFF;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end

     // WORD - IPMEM
     repeat(10) begin
         byte_num_i = 4'b1111     ;
         addr_i     = 32'h910	  ;
         st_data_i  = $random     ;
	 io_sw_i    = 32'hFFFFFFFF;
  	 io_push_i  = st_data_i	  ;
	 sten_i = 1;
	 #20;
         LSU_result();
	 #20;
	 sten_i = 0;
	 #10;
	end
   $stop;
   $finish;
  end
endmodule
