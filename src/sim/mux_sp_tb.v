module mux_sp_tb;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]          reg_SP_in;              // From uut of mux_sp.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [1:0]            MUX_SP_SEL;             // To uut of mux_sp.v
   reg [15:0]           reg_SP_out;             // To uut of mux_sp.v
   // End of automatics

   mux_sp uut
     (/*AUTOINST*/
      // Outputs
      .reg_SP_in                        (reg_SP_in[15:0]),
      // Inputs
      .MUX_SP_SEL                       (MUX_SP_SEL[1:0]),
      .reg_SP_out                       (reg_SP_out[15:0]));


   initial
     begin
        MUX_SP_SEL <= 0;
        reg_SP_out <= 16'h0400;
        repeat (3)
          #30 MUX_SP_SEL <= MUX_SP_SEL + 1;
        
     end

   always #10 reg_SP_out <= reg_SP_in;


endmodule
