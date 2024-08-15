module regfile 
( 
  input  logic  clk_i, 
  input  logic  rst_ni, 
  input  logic  rd_wren_i,
  input  logic  [ 4:0]  rd_addr_i, 
  input  logic  [ 4:0]  rs1_addr_i, 
  input  logic  [ 4:0]  rs2_addr_i, 
  input  logic  [31:0]  rd_data_i, 
         
  output logic  [31:0]  rs1_data_o, 
  output logic  [31:0]  rs2_data_o  
);

  logic [31:0] register_file [31:0];

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      for (int i = 0; i < 32; i++) begin
        register_file[i] <= 32'b0;
      end
    end else if (rd_wren_i) begin
      register_file[rd_addr_i] <= rd_data_i;
    end
  $writememh("D:/BKU/CTMT/2011919_Processor/memory_files/REGFILE.mem", register_file);
  end

  assign rs1_data_o = (rs1_addr_i != 0) ? register_file[rs1_addr_i] : 0;
  assign rs2_data_o = (rs2_addr_i != 0) ? register_file[rs2_addr_i] : 0;

endmodule : regfile
