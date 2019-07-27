module mem_space
  (input [15:0] MAB_in, MDB_in,
   input clk, MW, BW,
   output [15:0] MDB_out);

   // Parameters for upper bound of memory spaces (end + 1)
   // These are also lower bounds of the following space
   parameter ub_SFRs   = 'h0010, ub_peri8 = 'h0100, 
             ub_peri16 = 'h0200, ub_ram   = 'h0400,
             ub_UNUSED = 'hc000, ub_rom   = 'hffff;
   // Note: For MSP430x2xx Family, range for ROM and IVT overlap. So
   // there isn't really an upper bound to ROM since it continues all
   // the way to the top and IVT occupies that space in ROM.
   
   wire [15:0]   rom_addr, ram_addr;
   wire          ram_RW;
   wire [2:0]    range;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]          ram_out;                // From u2 of ram.v
   wire [15:0]          rom_out;                // From u1 of rom.v
   // End of automatics

   // Decoder uses address bounds to find which partition address is
   // for   
   assign range =   (MAB_in < ub_SFRs)   ? 3'd0 :
                    (MAB_in < ub_peri8)  ? 3'd1 :
                    (MAB_in < ub_peri16) ? 3'd2 :
                    (MAB_in < ub_ram)    ? 3'd3 :
                    (MAB_in < ub_UNUSED) ? 3'd4 :
                    (MAB_in < ub_rom)    ? 3'd5 : 3'bx;


   // Encoder uses address bounds to determine correct offset
   assign rom_addr = (range == 5) ? (MAB_in - ub_UNUSED) : 'bx;
   assign ram_addr = (range == 3) ? (MAB_in - ub_peri16) : 'bx;
   assign ram_RW   = (range == 3) ? (MW)                 : 'b0;
   
   rom u1
     (/*AUTOINST*/
      // Outputs
      .rom_out                          (rom_out[15:0]),
      // Inputs
      .rom_addr                         (rom_addr[15:0]));

   ram u2
     (.ram_Din                          (MDB_in[15:0]),
      .ram_RW                           (MW),
      /*AUTOINST*/
      // Outputs
      .ram_out                          (ram_out[15:0]),
      // Inputs
      .BW                               (BW),
      .clk                              (clk),
      .ram_addr                         (ram_addr[15:0]));

   // MUX out for MDB out
   // Eventually replace 48 bits with outputs from peripherals. 16
   // bits of X stay that way because you are not supposed to use that
   // space.
   wire [95:0] outs_flat = {rom_out, 16'bx, ram_out, 48'bx};
   wire [15:0] outs_deep [5:0];
   genvar        i;
   for (i=0;i<6;i=i+1)
     begin
        assign outs_deep[i] = outs_flat[16*(i+1)-1:16*i];
     end

   assign MDB_out = outs_deep[range];

endmodule
