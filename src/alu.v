module alu #(parameter SIZE=16)
  (input [SIZE-1:0]  SRC,
   input [SIZE-1:0]  DST,
   input             BW,
   input             Cin,
   input [5:0]       FS,
   output [3:0]      CVNZ_alu,
   output [SIZE-1:0] ALU_OUT);

   wire [SIZE-1:0]   ARIT_OUT;
   wire [SIZE-1:0]   LOG_OUT;
   wire              Cout_arit;
   wire              Cout_log;

   // Assign status bits
   assign CVNZ_alu[3] = !FS[4] ? Cout_arit : Cout_log;
   assign CVNZ_alu[1] = (~BW && ALU_OUT[SIZE-1])   ? 1'b1 :
                        ( BW && ALU_OUT[SIZE/2-1]) ? 1'b1 : 0;
   assign CVNZ_alu[0] = !ALU_OUT ? 1'b1 : 0;

   
   arit_ckt #(SIZE) u1
     (.S(FS[1:0]),
      // .Cout(CVNZ_alu[3]),
      .V(CVNZ_alu[2]),
      /*AUTOINST*/
      // Outputs
      .ARIT_OUT                         (ARIT_OUT[SIZE-1:0]),
      .Cout_arit                        (Cout_arit),
      // Inputs
      .BW                               (BW),
      .Cin                              (Cin),
      .DST                              (DST[SIZE-1:0]),
      .SRC                              (SRC[SIZE-1:0]));

   log_ckt #(SIZE) u2
     (/*AUTOINST*/
      // Outputs
      .Cout_log                         (Cout_log),
      .LOG_OUT                          (LOG_OUT[SIZE-1:0]),
      // Inputs
      .DST                              (DST[SIZE-1:0]),
      .FS                               (FS[3:0]),
      .SRC                              (SRC[SIZE-1:0]));

   assign ALU_OUT = !FS[4] ? ARIT_OUT     :
                     FS[4] ? LOG_OUT      : 'bx;
   

endmodule
