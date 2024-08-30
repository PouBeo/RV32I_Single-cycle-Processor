`include "D:/BKU/CTMT/2011919_Pipelined_Processor/Parameter.sv"
module ctrl_unit
(
    input  logic [31:0] instr_i,
    input  logic br_less_i,
    input  logic br_equal_i,
    
    output logic br_sel_o,
    output logic br_unsigned_o,
    output logic [2:0] imm_sel_o,
    output logic [3:0] alu_op_o,
    output logic rd_wren_o,
    output logic mem_wren_o,
    output logic mem_us_o,
    output logic [3:0] mem_wrnum_o,
    output logic op_a_sel_o,
    output logic op_b_sel_o,
    output logic [1:0] wb_sel_o
);
  logic [6:0] op ;
  logic [2:0] funct3 ;
  logic b5_funct7 ;

  assign        op = instr_i[ 6: 0];
  assign    funct3 = instr_i[14:12];
  assign b5_funct7 = instr_i[30];

  // OpCode - Instruction[6:0]
  localparam  OP_LOAD  = 7'b00000_11;  // load opcode
  localparam  OP_ALU_I = 7'b00100_11;  // i-type alu opcode
  localparam  OP_AUIPC = 7'b00101_11;  // add upper immediate to pc
  localparam  OP_STORE = 7'b01000_11;  // store opcode
  localparam  OP_ALU_R = 7'b01100_11;  // r-type alu opcode
  localparam  OP_LUI   = 7'b01101_11;  // load upper immediate
  localparam  OP_BR    = 7'b11000_11;  // brach opcode
  localparam  OP_JALR  = 7'b11001_11;  // jump and link reg
  localparam  OP_JAL   = 7'b11011_11;  // jump and link

  // Funct_3 of OP_ALU_R
  localparam  ADD  =   3'b000;
  localparam  SLL  =   3'b001;
  localparam  SLT  =   3'b010;
  localparam  SLTU =   3'b011;
  localparam  XOR  =   3'b100;
  localparam  SR   =   3'b101;
  localparam  OR   =   3'b110;
  localparam  AND  =   3'b111;
        
  // Funct_3 of OP_ALU_I 
  localparam  ADDI  = 3'b000;
  localparam  SLLI  = 3'b001;
  localparam  SLTI  = 3'b010; 
  localparam  SLTIU = 3'b011;
  localparam  XORI  = 3'b100;
  localparam  SRI   = 3'b101;
  localparam  ORI   = 3'b110;
  localparam  ANDI  = 3'b111;
        
  // Funct_3 of OP_LOAD  
  localparam  LB  = 3'b000;
  localparam  LH  = 3'b001;
  localparam  LW  = 3'b010;
  localparam  LBU = 3'b100;
  localparam  LHU = 3'b101;

  // Funct_3 of OP_STORE 
  localparam  SB = 3'b000;
  localparam  SH = 3'b001;
  localparam  SW = 3'b010;

  // Funct_3 of OP_BR 
  localparam  BEQ  = 3'b000;
  localparam  BNE  = 3'b001;
  localparam  BLT  = 3'b100;
  localparam  BGE  = 3'b101;
  localparam  BLTU = 3'b110;
  localparam  BGEU = 3'b111;
  
  always_comb begin
    case( op )
     // OPCODE
        OP_LOAD   : begin
                    br_sel_o      = `pc4;
                    imm_sel_o     = `ITYPE;
                    alu_op_o      = `ADD;
                    br_unsigned_o = 1'bx;
                    mem_wren_o    = 1'b0;    // not store
                    op_a_sel_o    = 1'b0;    // rs1 selected
                    op_b_sel_o    = 1'b1;    // imm selected
                    wb_sel_o      = 2'd1;    // data from LSU
                    rd_wren_o     = 1'b1;    // write to rd
                    case ( funct3 )
                           LB :  begin
                                 mem_wrnum_o   = 4'b0001; // byte
                                 mem_us_o      = 1'b0;    // sign_ext
                                 end
                           LH :  begin
                                 mem_wrnum_o   = 4'b0011; // half-word
                                 mem_us_o      = 1'b0;    // sign_ext
                                 end
                           LW :  begin
                                 mem_wrnum_o   = 4'b1111; // word
                                 mem_us_o      = 1'b0;    // sign_ext
                                 end
                           LBU:  begin
                                 mem_wrnum_o   = 4'b0001; // byte
                                 mem_us_o      = 1'b1;    // zero_ext
                                 end  
                           LHU:  begin
                                 mem_wrnum_o   = 4'b0011; // half-word
                                 mem_us_o      = 1'b1;    // zero_ext
                                 end
                           default: begin
                                    mem_wrnum_o   = 4'b0;
                                    mem_us_o      = 1'b0;
                                    end
                    endcase
                    end
     // OPCODE
        OP_ALU_I  : begin
                    br_sel_o      = `pc4;
                    imm_sel_o     = `ITYPE;
                    br_unsigned_o = 1'bx;
                    mem_wren_o    = 1'b0;
                    mem_wrnum_o   = 4'bxxxx;
                    mem_us_o      = 1'bx;
                    op_a_sel_o    = 1'b0;    // rs1 selected
                    op_b_sel_o    = 1'b1;    // imm selected
                    wb_sel_o      = 2'd0;    // data from ALU
                    rd_wren_o     = 1'b1;    // write to rd
                    case ( funct3 )
                          ADDI :  alu_op_o = `ADD;
                          SLLI :  alu_op_o = `SLL;
                          SLTI :  alu_op_o = `SLT;
                          SLTIU:  alu_op_o = `SLTU;
                          XORI :  alu_op_o = `XOR;
                          SRI  :  alu_op_o = ( b5_funct7 ) ? `SRA : `SRL ;
                          ORI  :  alu_op_o = `OR;
                          ANDI :  alu_op_o = `AND;
                          default: alu_op_o = 4'bxxxx;
                    endcase
                    end
     // OPCODE
        OP_AUIPC  : begin
                    br_sel_o      = `pc4;
                    imm_sel_o     = `UTYPE;
                    alu_op_o      = `ADD;
                    br_unsigned_o = 1'bx;
                    mem_wren_o    = 1'b0;
                    mem_wrnum_o   = 4'bxxxx;
                    mem_us_o      = 1'bx;
                    op_a_sel_o    = 1'b1;    // pc selected
                    op_b_sel_o    = 1'b1;    // imm selected
                    wb_sel_o      = 2'd0;    // data from ALU
                    rd_wren_o     = 1'b1;    // write to rd
                    end
     // OPCODE
        OP_STORE  : begin
                    br_sel_o      = `pc4;
                    imm_sel_o     = `STYPE;
                    alu_op_o      = `ADD;
                    br_unsigned_o = 1'b0;
                    mem_wren_o    = 1'b1;    // store
                    mem_us_o      = 1'bx;
                    op_a_sel_o    = 1'b0;    // rs1 selected
                    op_b_sel_o    = 1'b1;    // imm selected
                    wb_sel_o      = 2'd0;
                    rd_wren_o     = 1'b0;    // not write to rd
                    case ( funct3 )
                           SB :  mem_wrnum_o   = 4'b0001; // byte
                           SH :  mem_wrnum_o   = 4'b0011; // half-word
                           SW :  mem_wrnum_o   = 4'b1111; // word
                           default: mem_wrnum_o   = 4'b0000;
                    endcase
                    end
     // OPCODE
        OP_ALU_R  : begin
                    br_sel_o      = `pc4;
                    imm_sel_o     = `RTYPE;
                    br_unsigned_o = 1'bx;
                    mem_wren_o    = 1'b0;
                    mem_wrnum_o   = 4'b0000;
                    mem_us_o      = 1'bx;
                    op_a_sel_o    = 1'b0;    // rs1 selected
                    op_b_sel_o    = 1'b0;    // rs2 selected
                    wb_sel_o      = 2'd0;    // data from ALU
                    rd_wren_o     = 1'b1;    // write to rd
                    case ( funct3 )
                          ADD :  alu_op_o = ( b5_funct7 ) ? `SUB : `ADD;
                          SLL :  alu_op_o = `SLL;
                          SLT :  alu_op_o = `SLT;
                          SLTU:  alu_op_o = `SLTU;
                          XOR :  alu_op_o = `XOR;
                          SR  :  alu_op_o = ( b5_funct7 ) ? `SRA : `SRL ;
                          OR  :  alu_op_o = `OR;
                          AND :  alu_op_o = `AND;
                          default: alu_op_o = 4'bxxxx;
                    endcase
                    end
     // OPCODE
        OP_LUI    : begin
                    br_sel_o      = `pc4;
                    imm_sel_o     = `UTYPE;
                    alu_op_o      = `LUI;    // alu include additional operator lui
                    br_unsigned_o = 1'bx;
                    mem_wren_o    = 1'b0;
                    mem_wrnum_o   = 4'b0000;
                    mem_us_o      = 1'bx;
                    op_a_sel_o    = 1'bx;
                    op_b_sel_o    = 1'b1;    // imm selected
                    wb_sel_o      = 2'd0;    // data from ALU
                    rd_wren_o     = 1'b1;    // write to rd
                    end
     // OPCODE
        OP_BR     : begin
                    imm_sel_o     = `BTYPE;
                    alu_op_o      = `ADD;
                    mem_wren_o    = 1'b0;
                    mem_wrnum_o   = 4'b0000;
                    mem_us_o      = 1'bx;
                    op_a_sel_o    = 1'b1;    // pc selected
                    op_b_sel_o    = 1'b1;    // imm selected
                    wb_sel_o      = 2'd0;
                    rd_wren_o     = 1'b0;
                    case ( funct3 )
                           BEQ :  begin
                                  br_unsigned_o = 1'b0;                 // unsigned_branching
                                  br_sel_o = ( br_equal_i ) ? `branch : `pc4 ; // branch ( nxt_pc <= alu_dat )
                                  end
                           BNE :  begin
                                  br_unsigned_o = 1'b0;
                                  br_sel_o = ( !br_equal_i ) ? `branch : `pc4 ;
                                  end
                           BLT :  begin
                                  br_unsigned_o = 1'b0;
                                  br_sel_o = ( br_less_i ) ? `branch : `pc4 ;
                                  end
                           BGE :  begin
                                  br_unsigned_o = 1'b0;
                                  br_sel_o  = ( ( !br_less_i && !br_equal_i ) || br_equal_i ) ? `branch : `pc4 ;
                                  end
                           BLTU:  begin
                                  br_unsigned_o = 1'b1;
                                  br_sel_o  = ( br_less_i ) ? `branch : `pc4 ;
                                  end
                           BGEU:  begin
                                  br_unsigned_o = 1'b1;
                                  br_sel_o  = ( ( !br_less_i && !br_equal_i ) || br_equal_i ) ? `branch : `pc4 ; // branch ( nxt_pc <= alu_dat )
                                  end 
                           default: begin
                                    br_unsigned_o = 1'bx;
                                    br_sel_o      = 1'bx;
                                    end
                    endcase
                    end
     // OPCODE
        OP_JALR   : begin
                    br_sel_o      = `branch;
                    imm_sel_o     = `ITYPE;
                    alu_op_o      = `ADD;
                    br_unsigned_o = 1'bx;
                    mem_wren_o    = 1'b0;
                    mem_wrnum_o   = 4'bxxxx;
                    mem_us_o      = 1'bx;
                    op_a_sel_o    = 1'b0;    // rs1 selected
                    op_b_sel_o    = 1'b1;    // imm selected
                    wb_sel_o      = 2'd2;    // pc + 4 
                    rd_wren_o     = 1'b1;    // write to rd
                    end
     // OPCODE
        OP_JAL    : begin
                    br_sel_o      = `branch;
                    imm_sel_o     = `JTYPE;
                    alu_op_o      = `ADD;
                    br_unsigned_o = 1'bx;
                    mem_wren_o    = 1'b0;
                    mem_wrnum_o   = 4'bxxxx;
                    mem_us_o      = 1'bx;
                    op_a_sel_o    = 1'b1;    // pc selected
                    op_b_sel_o    = 1'b1;    // imm selected
                    wb_sel_o      = 2'd2;    // pc + 4 
                    rd_wren_o     = 1'b1;    // write to rd
                    end
         default   : begin
                    br_sel_o      = 1'b0;
                    imm_sel_o     = 2'b0;
                    alu_op_o      = 4'b0;
                    br_unsigned_o = 1'b0;
                    mem_wren_o    = 1'b0;
                    mem_wrnum_o   = 4'b0;
                    mem_us_o      = 1'b0;
                    op_a_sel_o    = 1'b0;
                    op_b_sel_o    = 1'b0;
                    wb_sel_o      = 2'b0;
                    rd_wren_o     = 1'b0;
                    end
    endcase
    end

endmodule: ctrl_unit