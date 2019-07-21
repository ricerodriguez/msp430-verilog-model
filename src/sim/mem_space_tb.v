module mem_space_tb;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]          MAB_out;                // From uut of mem_space.v
   wire [15:0]          MDB_out;                // From uut of mem_space.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg                  BW;                     // To uut of mem_space.v
   reg [15:0]           MAB_in;                 // To uut of mem_space.v
   reg [15:0]           MDB_in;                 // To uut of mem_space.v
   reg                  MW;                     // To uut of mem_space.v
   reg                  clk;                    // To uut of mem_space.v
   // End of automatics

   mem_space uut
     (/*AUTOINST*/
      // Outputs
      .MAB_out                          (MAB_out[15:0]),
      .MDB_out                          (MDB_out[15:0]),
      // Inputs
      .BW                               (BW),
      .MAB_in                           (MAB_in[15:0]),
      .MDB_in                           (MDB_in[15:0]),
      .MW                               (MW),
      .clk                              (clk));


   initial
     begin
        {clk,MW,BW} <= 0;
        MAB_in <= 16'h0200;
        MDB_in <= 16'hffff;        
     end

   always #5 clk = ~clk;
   always #10 MAB_in = MAB_in + 2;
   always #30 {BW,MW} = {BW,MW}+1;
   
   

endmodule
