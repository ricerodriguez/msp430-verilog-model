module mem_space
  (input [15:0] MAB_in, MDB_in,
   input clk, MW, BW,
   output [15:0] MAB_out, MDB_out);

   wire [15:0]   rom_addr, ram_addr;
   // Address offset is probably wrong?
   assign rom_addr = (MAB_in > 16'hC000) ? (16'hFFFF - MAB_in) : 16'h0;
   assign ram_addr = ((MAB_in > 16'h0200) || (MAB_in < 16'h03FF)) ? (16'h0400 - MAB_in) : 16'h0;
   assign ram_RW = (!rom_addr) ? MW : 1'b0;
   assign rom_RW = (!ram_addr) ? MW : 1'b0;
   
   rom u1
     (/*AUTOINST*/
      // Outputs
      .rom_out                          (rom_out[15:0]),
      // Inputs
      .BW                               (BW),
      .rom_addr                         (rom_addr[15:0]));

   ram u2
     (/*AUTOINST*/
      // Outputs
      .ram_out                          (ram_out[15:0]),
      // Inputs
      .BW                               (BW),
      .clk                              (clk),
      .ram_Din                          (ram_Din[15:0]),
      .ram_RW                           (ram_RW),
      .ram_addr                         (ram_addr[15:0]));

   assign MDB_out = (!ram_addr) ? rom_out : (!rom_addr) ? ram_out : 'bx;

endmodule
