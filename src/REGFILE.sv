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
  initial begin
    integer i;
    for (i = 0; i < 32; i = i + 1) begin
      register_file[i] = 32'b0; 
    end
    /*$monitor("Time=%0t\n x0=%h x1 =%h x2 =%h x3 =%h x4 =%h x5 =%h x6 =%h x7 =%h x8 =%h x9 =%h\n x10=%h x11=%h x12=%h x13=%h x14=%h x15=%h x16=%h x17=%h x18=%h x19=%h x20=%h x21=%h x22=%h x23=%h x24=%h x25=%h x26=%h x27=%h x28=%h x29=%h x30=%h x31=%h\n", 
                $time, register_file[ 0], register_file[ 1], register_file[ 2], register_file[ 3], register_file[ 4], register_file[ 5], register_file[ 6], register_file[ 7], register_file[ 8], register_file[ 9], register_file[10], register_file[11], 
                       register_file[12], register_file[13], register_file[14], register_file[15], register_file[16], register_file[17], register_file[18], register_file[19], register_file[20], register_file[21], register_file[22], register_file[23], 
                       register_file[24], register_file[25], register_file[26], register_file[27], register_file[28], register_file[29], register_file[30], register_file[31]);
    */end
  assign rs1_data_o = (rs1_addr_i != 0) ? register_file[rs1_addr_i] : 0;
  assign rs2_data_o = (rs2_addr_i != 0) ? register_file[rs2_addr_i] : 0;

endmodule : regfile
