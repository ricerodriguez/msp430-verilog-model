module mux_mdb
  (// input [15:0]  MDB_out,
   // input [15:0]  CALC_out,
   input [15:0]  F_out,
   input [15:0]  Sout,
   input [1:0]   MDB_sel,
   // output [15:0] MDB_in,
   input [15:0]  MDB_out,
   output [15:0] MDB_in
   );

   // Just trying to test pipeline right now
   // assign MDB_in = MDB_out;


   assign MDB_in = (MDB_sel == 2'h0) ? F_out   :
                   (MDB_sel == 2'h1) ? MDB_out :
                   (MDB_sel == 2'h2) ? Sout    : MDB_out;
      

endmodule
