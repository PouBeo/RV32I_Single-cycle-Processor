module single_cycle_rv32i (
  input  logic  clk_i,
  input  logic  rst_ni,
  input  logic [31:0] io_sw_i,
  input  logic [31:0] io_push_i,

  output logic [31:0] io_lcd_o,
  output logic [31:0] io_ledg_o,
  output logic [31:0] io_ledr_o,

  output logic [31:0] io_hex0_o,
  output logic [31:0] io_hex1_o,
  output logic [31:0] io_hex2_o,
  output logic [31:0] io_hex3_o,
  output logic [31:0] io_hex4_o,
  output logic [31:0] io_hex5_o,
  output logic [31:0] io_hex6_o,
  output logic [31:0] io_hex7_o,
  
  output logic [31:0] pc_debug
);

  logic [31:0]  alu_data;
  logic [31:0]  pc;
  logic [31:0]  pc4;
  logic [31:0]  instr;
  logic [31:0]  rs1_data;
  logic [31:0]  rs2_data;
  logic [31:0]  wb_data;
  logic [31:0]  operand_a;
  logic [31:0]  operand_b;
  logic [31:0]  ld_data;
  logic [31:0]  imm;
  
  logic [ 5:0]  rs1_addr;
  logic [ 5:0]  rs2_addr;
  logic [ 5:0]  rd_addr;
  
  logic [ 3:0]  alu_op;
  logic [ 3:0]  byte_num;
  
  logic [ 2:0] imm_sel;
  
  logic [ 1:0] wb_sel;
  
  logic  pc_sel;
  logic  br_unsigned;
  logic  br_less;
  logic  br_equal;
  logic  rd_wren;
  logic  mem_wren;
  logic  ld_unsigned;
  logic  op_a_sel;
  logic  op_b_sel;
  
  assign rs1_addr = instr[19:15];
  assign rs2_addr = instr[24:20];
  assign rd_addr = instr[11: 7];
  
  PC_block PC ( .clk_i     ( clk_i    ),
                .rst_ni    ( rst_ni   ),
                .br_sel_i  ( pc_sel   ),
                .alu_data_i( alu_data ),
                .pc4_o     ( pc4      ),
                .pc_o      ( pc       ));
  
  imem I_MEM ( .imem_addr_i( pc     ),
               .instruct_o ( instr  ));
  
  Imm_gen IMM ( .instr_i( instr[31:7] ),
                .type_i ( imm_sel     ),
                .imm_o  ( imm         ));
  
  BRCOMP BR_COMP ( .rs1_data_i   ( rs1_data    ),
                   .rs2_data_i   ( rs2_data    ),
                   .br_unsigned_i( br_unsigned ),
                   .br_less_o    ( br_less     ),
                   .br_equal_o   ( br_equal    ));
  
  ctrl_unit CTRL_UNIT ( .instr_i      ( instr       ),
                        .br_less_i    ( br_less     ),
                        .br_equal_i   ( br_equal    ),
                        .br_sel_o     ( pc_sel      ),
                        .br_unsigned_o( br_unsigned ),
                        .imm_sel_o    ( imm_sel     ),
                        .alu_op_o     ( alu_op      ),
                        .rd_wren_o    ( rd_wren     ),
                        .mem_wren_o   ( mem_wren    ),
                        .mem_us_o     ( ld_unsigned ),
                        .mem_wrnum_o  ( byte_num    ),
                        .op_a_sel_o   ( op_a_sel    ),
                        .op_b_sel_o   ( op_b_sel    ),
                        .wb_sel_o     ( wb_sel      ));
  
  
  regfile REG_FILE ( .clk_i     ( clk_i    ), 
                     .rst_ni    ( rst_ni   ), 
                     .rd_wren_i ( rd_wren  ),
                     .rd_addr_i ( rd_addr  ), 
                     .rs1_addr_i( rs1_addr ), 
                     .rs2_addr_i( rs2_addr ), 
                     .rd_data_i ( wb_data  ), 
                     .rs1_data_o( rs1_data ), 
                     .rs2_data_o( rs2_data ));

  ALU ALU ( .operand1_i( operand_a   ),
            .operand2_i( operand_b   ),
            .alu_op_i  ( alu_op      ),
            .alu_data_o( alu_data    ));
  
  mux2to1_32b OP_A_MUX( .sel_i  ( op_a_sel  ),
                        .data0_i( rs1_data  ),
                        .data1_i( pc        ),
                        .data_o ( operand_a ));
  
  mux2to1_32b OP_B_MUX( .sel_i  ( op_b_sel  ),
                        .data0_i( rs2_data  ),
                        .data1_i( imm       ),
                        .data_o ( operand_b ));
  
    lsu LSU ( .clk_i     ( clk_i       ),
              .rst_ni    ( rst_ni      ),
              .sten_i    ( mem_wren    ),
              .ld_us_i   ( ld_unsigned ),
              .byte_num_i( byte_num    ),
              .addr_i    ( alu_data    ),
              .st_data_i ( rs2_data    ),
              .io_sw_i   ( io_sw_i     ),
              .io_push_i ( io_push_i   ),
              .ld_data_o ( ld_data     ),
              .io_lcd_o  ( io_lcd_o    ),
              .io_ledg_o ( io_ledg_o   ),
              .io_ledr_o ( io_ledr_o   ),
              .io_hex0_o ( io_hex0_o   ),
              .io_hex1_o ( io_hex1_o   ),
              .io_hex2_o ( io_hex2_o   ),
              .io_hex3_o ( io_hex3_o   ),
              .io_hex4_o ( io_hex4_o   ),
              .io_hex5_o ( io_hex5_o   ),
              .io_hex6_o ( io_hex6_o   ),
              .io_hex7_o ( io_hex7_o   ));
  
  mux3to1_32b WB_MUX ( .sel_i  ( wb_sel   ),
                       .data0_i( alu_data ),
                       .data1_i( ld_data  ),
                       .data2_i( pc4      ),
                       .data_o ( wb_data  ));
  
  assign pc_debug = pc;
  
endmodule: single_cycle_rv32i