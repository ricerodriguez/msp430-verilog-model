module rom_tb;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]          rom_out;                // From uut of rom.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg                  BW;                     // To uut of rom.v
   reg [15:0]           rom_addr;               // To uut of rom.v
   // End of automatics

   rom uut
     (/*AUTOINST*/
      // Outputs
      .rom_out                          (rom_out[15:0]),
      // Inputs
      .BW                               (BW),
      .rom_addr                         (rom_addr[15:0]));


   initial
     begin
        rom_addr <= 0;
        BW <= 0;
        #50 BW <= 1;
     end

   always #5 rom_addr <= {rom_addr[15:1],1'b0}+2;

endmodule
