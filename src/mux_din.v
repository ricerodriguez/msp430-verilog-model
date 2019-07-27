module mux_din
  (input         MD,
   input [15:0]  MDB_out,
   input [15:0]  F_OUT,
   output [15:0] reg_Din);

   assign reg_Din = MD ? MDB_out : F_OUT;
   

endmodule
