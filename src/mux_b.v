module mux_b
  (input [1:0] MB,
   input [15:0] MDB_out,
   input [15:0] CALC_OUT,
   input [15:0] Dout,
   output [15:0] B);

   assign B = (MB == 2'b00) ? Dout     :
              (MB == 2'b01) ? MDB_out  :
              (MB == 2'b10) ? CALC_OUT : 16'bx;

endmodule
