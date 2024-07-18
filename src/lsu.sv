`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////
// Module: Load-Store Unit
/////////////////////////////////////////////////////////////////////

module lsu(
  input  logic 	clk_i,
  input  logic 	rst_ni,
  input  logic 	sten_i,

  input  logic  [ 3:0]  byte_num_i,
  input  logic  [31:0]  addr_i,
  input  logic  [31:0]  st_data_i,
  input  logic  [31:0]  io_sw_i,
  input  logic  [31:0]  io_push_i,
	
  output logic  [31:0]  ld_data_o,
  output logic  [31:0]  io_lcd_o,   
  output logic  [31:0]  io_ledg_o,
  output logic  [31:0]  io_ledr_o,
  output logic  [31:0]  io_hex0_o,
  output logic  [31:0]  io_hex1_o,
  output logic  [31:0]  io_hex2_o,
  output logic  [31:0]  io_hex3_o,
  output logic  [31:0]  io_hex4_o,
  output logic  [31:0]  io_hex5_o,
  output logic  [31:0]  io_hex6_o,
  output logic  [31:0]  io_hex7_o
 );
  logic [3:0][7:0] d_mem [0:2**9-1];
  logic [3:0][7:0] op_mem [0:2**6-1];
  logic [3:0][7:0] ip_mem [0:2**6-1];
  
  logic  [31:0]  ld_data_d ;
  logic  [31:0]  ld_data_op ;
  logic  [31:0]  ld_data_ip ;
  logic  [31:0]  io_sw_prev ;
  logic  [31:0]  io_push_prev ;
  logic  [ 1:0]  addr_sel ;	

  // Store to Data_mem and Output-peripherals_mem
  always_ff @(posedge clk_i) begin : store_to_DMEM_OPMEM
    if (!addr_i[11]  && sten_i) begin
      if (byte_num_i[0]) begin
        d_mem[addr_i[10:2]][0] <= st_data_i[ 7: 0];
      end
      if (byte_num_i[1]) begin
        d_mem[addr_i[10:2]][1] <= st_data_i[15: 8];
      end
      if (byte_num_i[2]) begin
        d_mem[addr_i[10:2]][2] <= st_data_i[23:16];
      end
      if (byte_num_i[3]) begin
        d_mem[addr_i[10:2]][3] <= st_data_i[31:24];
      end
    end
	 if ((addr_i[11]) && (sten_i)) begin
      if (byte_num_i[0]) begin
        op_mem[addr_i[7:2]][0] <= st_data_i[ 7: 0];
      end
      if (byte_num_i[1]) begin
        op_mem[addr_i[7:2]][1] <= st_data_i[15: 8];
      end
      if (byte_num_i[2]) begin
        op_mem[addr_i[7:2]][2] <= st_data_i[23:16];
      end
      if (byte_num_i[3]) begin
        op_mem[addr_i[7:2]][3] <= st_data_i[31:24];
      end
    end
	 if (!rst_ni) begin
	   for (int i = 0; i < (2**9); i++) begin
         d_mem[i] <= 32'h0;
		end
	   for (int i = 0; i < (2**6); i++) begin
        op_mem[i] <= 32'h0;
      end
    end
  $writememh("D:/BKU/CTMT/2011919_Processor/memory_files/data_mem.mem"    ,  d_mem);
  $writememh("D:/BKU/CTMT/2011919_Processor/memory_files/out_peri_mem.mem", op_mem);
  end

  // Input-peripherals_mem	
	always @(posedge clk_i) begin : write_to_IPMEM
    if (io_sw_i !== io_sw_prev) begin
      ip_mem[6'b0000_00][0] = io_sw_i[ 7: 0];
      ip_mem[6'b0000_00][1] = io_sw_i[15: 8];
      ip_mem[6'b0000_00][2] = io_sw_i[23:16];
      ip_mem[6'b0000_00][3] = io_sw_i[31:24];
      $writememh("D:/BKU/CTMT/2011919_Processor/memory_files/in_peri_mem.mem", ip_mem);
      io_sw_prev <= io_sw_i; 
    end
    if (io_push_i !== io_push_prev) begin
      ip_mem[6'b0001_00][0] = io_push_i[ 7: 0];
      ip_mem[6'b0001_00][1] = io_push_i[15: 8];
      ip_mem[6'b0001_00][2] = io_push_i[23:16];
      ip_mem[6'b0001_00][3] = io_push_i[31:24];
      $writememh("D:/BKU/CTMT/2011919_Processor/memory_files/in_peri_mem.mem", ip_mem);
      io_push_prev <= io_push_i; 
    end
    if (!rst_ni) begin
      for (int i = 0; i < (2**6); i++) begin
        ip_mem[i] <= 32'h0;
      end
    end
  end

  // Output-Peripheral connects directly
  assign  io_lcd_o  =  op_mem[6'b1010_00];
  assign  io_ledg_o =  op_mem[6'b1001_00];
  assign  io_ledr_o =  op_mem[6'b1000_00];
  assign  io_hex7_o =  op_mem[6'b0111_00];
  assign  io_hex6_o =  op_mem[6'b0110_00];
  assign  io_hex5_o =  op_mem[6'b0101_00];
  assign  io_hex4_o =  op_mem[6'b0100_00];
  assign  io_hex3_o =  op_mem[6'b0011_00];
  assign  io_hex2_o =  op_mem[6'b0010_00];
  assign  io_hex1_o =  op_mem[6'b0001_00];
  assign  io_hex0_o =  op_mem[6'b0000_00];

  // Three output-datas loaded from MEM
  assign  ld_data_d  =   d_mem[addr_i[10:2]];
  assign  ld_data_op =  op_mem[addr_i[ 7:2]];
  assign  ld_data_ip =  ip_mem[addr_i[ 7:2]];

  // Base on mapping address, bit 11 and 8 of address will be used as select bits for output by the mux 32 bit
  assign addr_sel = {addr_i[11], addr_i[8]} ;
  mux3to1_32b LSU_data_out (  .sel_i( addr_sel ), .data0_i( ld_data_d ), .data1_i( ld_data_op ), .data2_i( ld_data_ip ), .data_o( ld_data_o));

endmodule: lsu


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module mux3to1_32b(
  input  logic  [ 1:0] sel_i,
  input  logic  [31:0] data0_i,
  input  logic  [31:0] data1_i,
  input  logic  [31:0] data2_i,
  output logic  [31:0] data_o
);
  logic [31:0] data_o0 ;
  logic [31:0] data_o1 ;
  logic [31:0] data_o2 ;

  assign data_o0 = (  sel_i[1]  ==  1'b0   ) ? data0_i  : 0; 
  assign data_o1 = (     sel_i  ==  2'b10  ) ? data1_i  : 0;
  assign data_o2 = (     sel_i  ==  2'b11  ) ? data2_i  : 0;

  assign data_o = data_o0 | data_o1 | data_o2 ;
  
endmodule:  mux3to1_32b
