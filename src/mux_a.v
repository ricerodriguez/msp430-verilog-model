module mux_a
  (input [1:0] MA,
   input [15:0] MDB_out,
   input [15:0] CALC_OUT,
   input [15:0] Sout,
   output [15:0] A);

   assign A = (MA == 2'b00) ? Sout     :
              (MA == 2'b01) ? MDB_out  :
              (MA == 2'b10) ? CALC_OUT : 16'bx;

endmodule
