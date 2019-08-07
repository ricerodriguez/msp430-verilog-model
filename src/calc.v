module calc
  (input             clk,
   // input [2:0]       AdAs,
   input [1:0]       MC,
   input [15:0]      MDB_out,
   input [15:0]      Sout, Dout,
   output reg [15:0] CALC_OUT);

   // reg [15:0]        MDB_last;
   reg [15:0]        Sout_last1,
                     Sout_last2,
                     Sout_last3;
   reg [15:0]        Dout_last1,
                     Dout_last2,
                     Dout_last3;

   initial
     begin
        CALC_OUT   <= 0;
        // MDB_last   <= 0;
        Sout_last1 <= 0;
        Sout_last2 <= 0;
        Sout_last3 <= 0;
        Dout_last1 <= 0;
        Dout_last2 <= 0;
        Dout_last3 <= 0;
     end  

   // Latches
   always @ (posedge clk)
     begin
        // MDB_last   <= MDB_out;
        Sout_last1 <= Sout;
        Sout_last2 <= Sout_last1;
        Sout_last3 <= Sout_last2;
        Dout_last1 <= Dout;
        Dout_last2 <= Dout_last1;
        Dout_last3 <= Dout_last2;
     end

   always @ (posedge clk)
     case(MC)
       1: CALC_OUT <= Sout_last1 + 1;
       2: CALC_OUT <= Sout_last1 + MDB_out;
       3: CALC_OUT <= Dout_last1 + MDB_out;
       4: CALC_OUT <= Dout_last2 + MDB_out;
       default: CALC_OUT <= 0;
     endcase  

   // assign CALC_OUT = (MC == 3'b000) ? MDB_out                 :
   //                   (MC == 3'b001) ? (Sout_last1 + MDB_out)  :
   //                   (MC == 3'b010) ? (Dout_last1 + MDB_out)  :
   //                   (MC == 3'b011) ? (Sout_last2 + MDB_out)  :
   //                   (MC == 3'b100) ? (Sout_last2 + MDB_last) :
                     

endmodule
