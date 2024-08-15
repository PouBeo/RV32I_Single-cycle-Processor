`timescale 1ns / 1ps

`ifndef CONST_VALUES

`define CONST_VALUES
// PC_select
    `define pc4    1'b0
    `define branch 1'b1
// ALU_select [3:0]
    `define ADD   4'd0
    `define SUB   4'd1
    `define SLL   4'd2
    `define SLT   4'd3
    `define SLTU  4'd4
    `define XOR   4'd5
    `define SRL   4'd6
    `define SRA   4'd7
    `define OR    4'd8
    `define AND   4'd9
    `define LUI   4'd10
//BranchType[2:0]
    `define NOB  3'b000
    `define BEQ  3'b000
    `define BNE  3'b001
    `define BLT  3'b100
    `define BGE  3'b101
    `define BLTU 3'b110
    `define BGEU 3'b111
//ImmType[2:0]
    `define RTYPE  3'd0
    `define ITYPE  3'd1
    `define STYPE  3'd2
    `define BTYPE  3'd3
    `define UTYPE  3'd4
    `define JTYPE  3'd5
`endif
