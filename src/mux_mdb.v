module mux_mdb
  (// input [15:0]  MDB_out,
   // input [15:0]  CALC_out,
   input [15:0]  F_out,
   input         MDB_sel,
   // output [15:0] MDB_in,
   input [15:0]  MDB_out,
   output [15:0] MDB_in
   );

   // Just trying to test pipeline right now
   // assign MDB_in = MDB_out;


   assign MDB_in = (MDB_sel)  ? MDB_out :
                   (~MDB_sel) ? F_out   : MDB_out;
      

endmodule
