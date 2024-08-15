module imem
(
  input  logic [31:0]  imem_addr_i,
  output logic [31:0]  instruct_o
);

  reg [3:0][7:0] i_mem [2**(11)-1:0];

  initial $readmemh("D:/BKU/CTMT/2011919_Processor/memory_files/testbench_mem/test.mem", i_mem);

  always_comb begin : load_from_imem
    instruct_o <= i_mem [imem_addr_i[12:2]][3:0];
  end
endmodule : imem
