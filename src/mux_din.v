module mux_din
  (input         clk,
   input [1:0]   MD,
   input [15:0]  MDB_out,
   input [15:0]  F_out,
   input [15:0]  Sout,
   input         BW,
   input         RW,
   output reg    MD_done,
   output [15:0] reg_Din);

   // assign reg_Din = (MD == 2'h0)        ? F_out    :
   //                  (MD == 2'h1)        ? MDB_out  :
   //                  BW && (MD == 2'h2)  ? Sout + 1 : 
   //                  ~BW && (MD == 2'h2) ? Sout + 2 : 16'bx;

   wire [15:0]   Sout_adjusted = (BW) ? Sout + 1 : Sout + 2;
   
   assign reg_Din = (MD == 2'h0) ? F_out :
                    (MD == 2'h1) ? MDB_out :
                    ((MD == 2'h2) && ~MD_done) ? Sout_adjusted : F_out;
   
   initial MD_done <= 0;

   always @ (posedge clk)
     begin
        if (MD == 2'h2)
          MD_done <= (RW) ? 1 : MD_done;
        else
          MD_done <= 0;
     end  
   

endmodule
