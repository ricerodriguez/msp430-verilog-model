module mux_b
  (input MB,
   input [15:0] MDB_out,
   input [15:0] Dout,
   output [15:0] B);

   assign B = (MB == 1'b0) ? Dout     :
              (MB == 1'b1) ? MDB_out  : 16'bx;


endmodule
