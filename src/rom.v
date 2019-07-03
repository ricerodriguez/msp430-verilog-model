module rom
  (input [15:0] rom_addr,
   input BW,
   output [15:0] rom_out);

   reg [7:0]    mem_rom [65535:0];
   
   initial $readmemh("mems/tester-00.mem",mem_rom);

   // Dr. Nutter's ROM:
   // wire [7:0] actual_address;
   // wire valid_minimum;
   // wire valid_maximum;
   // wire [7:0] address1;
   // wire [7:0] address2;
   // wire low_bit;
   // wire [7:0] upperbyte;

   // assign address1 = (address - ROMADDR);
   // assign address2 = address1 & 16'hfffe;
   // assign low_bit = address[0] & Width;
   // assign actual_address = address2 | low_bit;

   // assign valid_minimum = (address >= ROMADDR) ? 1 : 0;
   // assign valid_maximum = (address < ROMADDR + ROMSIZE) ? 1 : 0;
   // assign valid_address = valid_minimum & valid_maximum;

   // assign upperbyte = (Width == 0) ? data[actual_address+1] : 8'h0;

   // assign dataout = {upperbyte, data[actual_address]};


endmodule
