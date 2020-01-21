module mux_a
  (input         clk,
   input [1:0]   MA,
   input [15:0]  MDB_out,
   input [15:0]  Sout,
   output [15:0] A);

   reg [15:0]    MDB_last1,
                 MDB_last2;

   initial
     begin
        MDB_last1 <= 0;
        MDB_last2 <= 0;
     end  
   
   assign A = (MA == 2'h0) ? Sout      :
              (MA == 2'h1) ? MDB_out   : 
              (MA == 2'h2) ? MDB_last1 : 
              (MA == 2'h3) ? MDB_last2 : 16'bx;

   always @ (negedge clk)
     begin
        MDB_last1 <= MDB_out;
        MDB_last2 <= MDB_last1;
     end  

endmodule
