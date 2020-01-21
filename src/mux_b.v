module mux_b
  (input         clk,
   input [1:0]   MB,
   input [15:0]  MDB_out,
   input [15:0]  Dout,
   output [15:0] B);

   reg [15:0]    MDB_last;
   initial MDB_last <= 0;

   assign B = (MB == 2'h0) ? Dout     :
              (MB == 2'h1) ? MDB_out  : 
              (MB == 2'h2) ? MDB_last : 16'bx;

   always @ (negedge clk)
     MDB_last <= MDB_out;

endmodule
