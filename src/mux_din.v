module mux_din
  (input [1:0]   MD,
   input [15:0]  MDB_out,
   input [15:0]  F_OUT,
   input [15:0]  CALC_OUT,
   output [15:0] reg_Din);

   assign reg_Din = (MD == 2'b00) ? F_OUT    :
                    (MD == 2'b01) ? MDB_out  :
                    (MD == 2'b10) ? CALC_OUT : 16'bx;

endmodule
