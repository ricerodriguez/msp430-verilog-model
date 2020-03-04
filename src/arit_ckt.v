module arit_ckt #(parameter SIZE=16)
  (input [SIZE-1:0]  SRC,    DST,
   input             BW,
   input [1:0]       S,
   input             Cin,
   output [SIZE-1:0] ARIT_OUT,
   output            Cout_arit, V);

   wire [SIZE-1:0]   DST_BAR;
   assign DST_BAR = ~DST;

   // Outputs from first level of logic
   wire [SIZE-1:0]   Y;
   wire [SIZE-1:0]   ARIT_OUT_TMP;
   
   // Ripple carry bits
   wire [SIZE-1:0]   Cout_arit_full;

   // First level of logic
   wire [SIZE-1:0]   S0;
   wire [SIZE-1:0]   S1;

   // Make a data bus of same width as input so the bitwise operation
   // works and doesn't need to be assigned to each individual bit
   assign S1 = {SIZE{S[1]}};
   assign S0 = {SIZE{S[0]}};

   assign Y = (DST & S0) | (DST_BAR & S1);

   // Do all the ripple carries in one shot
   assign {Cout_arit_full,ARIT_OUT} = SRC+Y+Cin;

   // LSB of carry out bus is the final carry out
   assign Cout_arit = Cout_arit_full[0];

   // If we're ADDING, and both inputs have the same sign and output has opposite sign, OVERFLOW.
   // If we're SUBTRACTING, and the inputs sign bit do NOT match, and output sign matches B sign, OVERFLOW.
   assign V = ((!S[1]) & ~(SRC[SIZE-1] ^ DST[SIZE-1]) & (SRC[SIZE-1] ^ ARIT_OUT[SIZE-1])) ? 1 :
              ((S[1])   &  (SRC[SIZE-1] ^ DST[SIZE-1]) & ~(DST[SIZE-1] ^ ARIT_OUT[SIZE-1])) ? 1 : 0;

endmodule
