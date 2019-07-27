module shifter_tb;
   parameter SIZE_BYTE = 8, SIZE_WORD = 16;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [3:0]           CVNZ_shift;             // From uut of shifter.v
   wire [SIZE_WORD-1:0] SHIFT_OUT;              // From uut of shifter.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg                  BW;                     // To uut of shifter.v
   reg [SIZE_WORD-1:0]  DST;                    // To uut of shifter.v
   reg [1:0]            FS;                     // To uut of shifter.v
   // End of automatics

   shifter uut
     (/*AUTOINST*/
      // Outputs
      .CVNZ_shift                       (CVNZ_shift[3:0]),
      .SHIFT_OUT                        (SHIFT_OUT[SIZE_WORD-1:0]),
      // Inputs
      .BW                               (BW),
      .DST                              (DST[SIZE_WORD-1:0]),
      .FS                               (FS[1:0]));


   initial
     begin
        BW  <= 0;
        FS  <= 0;
        DST <= 'hCCCC;
        repeat (8)
          #50 {BW,FS} <= {BW,FS} + 1;
     end

endmodule
