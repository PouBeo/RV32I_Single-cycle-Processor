/*This module is used for connect pins to DE2-FPGA-Kit*/ // WRAPPER

module _2011919_SingleCycleProcessor 
(
  input  wire  CLOCK_50,
  input  wire [17:0] SW,
  input  wire [ 3:0] KEY,
  output wire [17:0] LEDR,
  output wire [ 8:0] LEDG,
  output wire [ 6:0] HEX0,
  output wire [ 6:0] HEX1,
  output wire [ 6:0] HEX2,
  output wire [ 6:0] HEX3,
  output wire [ 6:0] HEX4,
  output wire [ 6:0] HEX5,
  output wire [ 6:0] HEX6,
  output wire [ 6:0] HEX7,
  output wire [ 7:0] LCD_DATA,
  output wire  LCD_RW,
  output wire  LCD_RS,
  output wire  LCD_EN,
  output wire  LCD_ON
);

  wire [31:0]  io_sw  ;
  wire [31:0]  io_push;
  wire [31:0]  io_lcd ;
  wire [31:0]  io_ledg;
  wire [31:0]  io_ledr;
  wire [31:0]  io_hex0;
  wire [31:0]  io_hex1;
  wire [31:0]  io_hex2;
  wire [31:0]  io_hex3;
  wire [31:0]  io_hex4;
  wire [31:0]  io_hex5;
  wire [31:0]  io_hex6;
  wire [31:0]  io_hex7;
  wire [31:0]  pc_debug;

  assign LEDG[8] = |io_lcd[28:10] || |io_hex0[31:7] || |io_hex1[31:7] || |io_hex2[31:7]|| |io_hex3[31:7] || |io_hex4[31:7] || |io_hex5[31:7]
                || |io_hex6[31:7] || |io_hex7[31:7] ||  io_ledg[31:8] | io_ledr[31:17];

  assign HEX0 = io_hex0[6:0];
  assign HEX1 = io_hex1[6:0];
  assign HEX2 = io_hex2[6:0];
  assign HEX3 = io_hex3[6:0];
  assign HEX4 = io_hex4[6:0];
  assign HEX5 = io_hex5[6:0];
  assign HEX6 = io_hex6[6:0];
  assign HEX7 = io_hex7[6:0];
  /*assign HEX0 = ~io_hex0[6:0];
  assign HEX1 = ~io_hex1[6:0];
  assign HEX2 = ~io_hex2[6:0];
  assign HEX3 = ~io_hex3[6:0];
  assign HEX4 = ~io_hex4[6:0];
  assign HEX5 = ~io_hex5[6:0];
  assign HEX6 = ~io_hex6[6:0];
  assign HEX7 = ~io_hex7[6:0];*/

  assign LEDG[7:0]  = io_ledg[7:0];
  assign LEDR = io_ledr[17:0];

  assign LCD_DATA = io_lcd[7:0];
  assign LCD_RW   = io_lcd[8];
  assign LCD_RS   = io_lcd[9];
  assign LCD_EN   = io_lcd[10];
  assign LCD_ON   = io_lcd[31];

  assign io_sw   = {{15{1'b0}},SW[16:0]};
  assign io_push = KEY;

  single_cycle_rv32i SINGLECYCLE_PROCESSOR ( 
                       .clk_i    ( CLOCK_50 ),
                       .rst_ni   ( SW[17]   ),
                       .io_sw_i  ( io_sw    ),
                       .io_push_i( io_push  ),
                       .io_lcd_o ( io_lcd   ),
                       .io_ledg_o( io_ledg  ),
                       .io_ledr_o( io_ledr  ),
                       .io_hex0_o( io_hex0  ),
                       .io_hex1_o( io_hex1  ),
                       .io_hex2_o( io_hex2  ),
                       .io_hex3_o( io_hex3  ),
                       .io_hex4_o( io_hex4  ),
                       .io_hex5_o( io_hex5  ),
                       .io_hex6_o( io_hex6  ),
                       .io_hex7_o( io_hex7  ),
                       .pc_debug ( pc_debug ));
endmodule
