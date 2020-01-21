module mux_a
  (input         clk,
   input [1:0]   MA,
   input [15:0]  MDB_out,
   input [15:0]  Sout,
   output [15:0] A);

   reg [15:0]    MDB_last;
   
   assign A = (MA == 2'h0) ? Sout     :
              (MA == 2'h1) ? MDB_out  : 
              (MA == 2'h2) ? MDB_last : 16'bx;

   always @ (negedge clk)
     MDB_last <= MDB_out;

endmodule
