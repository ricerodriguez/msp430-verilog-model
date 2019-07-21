module ram_tb;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]          ram_out;                // From uut of ram.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg                  BW;                     // To uut of ram.v
   reg                  clk;                    // To uut of ram.v
   reg [15:0]           ram_Din;                // To uut of ram.v
   reg                  ram_RW;                 // To uut of ram.v
   reg [15:0]           ram_addr;               // To uut of ram.v
   // End of automatics

   ram uut
     (/*AUTOINST*/
      // Outputs
      .ram_out                          (ram_out[15:0]),
      // Inputs
      .BW                               (BW),
      .clk                              (clk),
      .ram_Din                          (ram_Din[15:0]),
      .ram_RW                           (ram_RW),
      .ram_addr                         (ram_addr[15:0]));


   initial
     begin
        {BW, clk, ram_RW, ram_addr} <= 0;
        ram_Din <= 16'hffff;
        #120 BW <= 1;
     end

   always #5 clk = ~clk;
   always #10 ram_RW = ~ram_RW;   
   always #20 ram_addr = ram_addr+2;

endmodule
