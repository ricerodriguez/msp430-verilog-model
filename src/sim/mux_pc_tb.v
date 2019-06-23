module mux_pc_tb;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]          reg_PC_in;              // From uut of mux_pc.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [15:0]           CALC_OUT;               // To uut of mux_pc.v
   reg [15:0]           MDB;                    // To uut of mux_pc.v
   reg [15:0]           reg_PC_out;             // To uut of mux_pc.v
   reg [2:0]            sel;                    // To uut of mux_pc.v
   // End of automatics

   mux_pc uut
     (/*AUTOINST*/
      // Outputs
      .reg_PC_in                        (reg_PC_in[15:0]),
      // Inputs
      .CALC_OUT                         (CALC_OUT[15:0]),
      .MDB                              (MDB[15:0]),
      .reg_PC_out                       (reg_PC_out[15:0]),
      .sel                              (sel[2:0]));


   initial
     begin
        sel <= 0;
        MDB <= 0;
        CALC_OUT <= 0;
        reg_PC_out <= 0;
     end

endmodule
