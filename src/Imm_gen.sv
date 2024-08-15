`include "D:/BKU/CTMT/2011919_Processor/Parameter.sv"   
module Imm_gen (
  input  logic [31:7] instr_i,
  input  logic [ 2:0] type_i,
  output logic [31:0] imm_o
);
  always@(*)
  begin
     case( type_i )
         `RTYPE:     imm_o <= 32'd0;
         `ITYPE:     imm_o <= { {20{instr_i[31]}}, instr_i[31:20] }; 
         `STYPE:     imm_o <= { {20{instr_i[31]}}, instr_i[31:25], instr_i[11:7] };
         `BTYPE:     imm_o <= { {20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0 };
         `UTYPE:     imm_o <= { instr_i[31:12], 12'b0 };
         `JTYPE:     imm_o <= { {12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
         default:    imm_o <= 32'bxxxxxxxx;
     endcase
    end
endmodule: Imm_gen