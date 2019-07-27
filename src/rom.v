module rom
  (input [15:0] rom_addr,
   // input BW,
   output [15:0] rom_out);

   parameter  BOUND_U = 16'hffff,
              BOUND_L = 16'hc000;
   localparam SIZE    = BOUND_U - BOUND_L;
   
   reg [7:0]    mem_rom [SIZE-1:0];
   initial 
     begin
        $readmemh("tester-01.mem",mem_rom);
//        $readmemh("clear.mem",mem_rom,6);
     end  

   // Double fetch for 16-bits
   assign rom_out = {mem_rom[rom_addr+1],mem_rom[rom_addr]};
   

endmodule
