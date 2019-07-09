module rom
  (input [15:0] rom_addr,
   input BW,
   output [15:0] rom_out);

   parameter  BOUND_U = 16'hffff,
              BOUND_L = 16'hc000;
   localparam SIZE    = BOUND_U - BOUND_L;
   
   reg [15:0]    mem_rom [SIZE-1:0];
   initial 
     begin
        $readmemh("tester.mem",mem_rom);
        $readmemh("clear.mem",mem_rom,29);
     end  

   wire [7:0]    byte_out = mem_rom[rom_addr][7:0];
   assign rom_out = BW ? {8'bx,byte_out} : mem_rom[rom_addr];
   

endmodule
