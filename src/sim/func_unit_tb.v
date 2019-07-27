`include "msp430_ops.vh"
module func_unit_tb;
   parameter SIZE=16;
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [3:0]           CVNZ_func;              // From uut of func_unit.v
   wire [SIZE-1:0]      F_OUT;                  // From uut of func_unit.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [SIZE-1:0]       A;                      // To uut of func_unit.v
   reg [SIZE-1:0]       B;                      // To uut of func_unit.v
   reg                  BW;                     // To uut of func_unit.v
   reg                  Cin;                    // To uut of func_unit.v
   reg [5:0]            FS;                     // To uut of func_unit.v
   // End of automatics

   func_unit uut
     (/*AUTOINST*/
      // Outputs
      .CVNZ_func                        (CVNZ_func[3:0]),
      .F_OUT                            (F_OUT[SIZE-1:0]),
      // Inputs
      .A                                (A[SIZE-1:0]),
      .B                                (B[SIZE-1:0]),
      .BW                               (BW),
      .Cin                              (Cin),
      .FS                               (FS[5:0]));

   always #20 Cin = CVNZ_func[3];
   
   initial
     begin
        {BW,Cin,FS} <= 0;
        A <= 'hABCD;
        B <= 'hDCBA;
        #20 FS = `FS_MOV;
        #20 FS = `FS_ADD;
        #20 FS = `FS_ADDC;
        #20 FS = `FS_SUB;
        #20 FS = `FS_SUBC;
        #20 FS = `FS_CMP;
        #20 FS = `FS_DADD;
        #20 FS = `FS_BIT;
        #20 FS = `FS_BIC;
        #20 FS = `FS_BIS;
        #20 FS = `FS_XOR;
        #20 FS = `FS_AND;
        #20 FS = `FS_RRC;
        #20 FS = `FS_RRA;
        #20 FS = `FS_PUSH;
        #20 FS = `FS_SWPB;
        #20 FS = `FS_CALL;
        #20 FS = `FS_RETI;
        #20 FS = `FS_SXT;
     end

endmodule
