module mux_din
  (input [1:0]   MD,
   input [15:0]  MDB_out,
   input [15:0]  F_out,
   input [15:0]  Sout,
   input         BW,
   output [15:0] reg_Din);

   assign reg_Din = (MD == 2'h0)        ? F_out    :
                    (MD == 2'h1)        ? MDB_out  :
                    BW && (MD == 2'h2)  ? Sout + 1 : 
                    ~BW && (MD == 2'h2) ? Sout + 2 : 16'bx;

endmodule
