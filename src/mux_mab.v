module mux_mab
  (input [15:0] reg_PC_out, reg_SP_out, MDB_out, CALC_out, Sout,
   input [2:0]   MAB_sel, // Maybe change this to be based of AdAs?
   input         CALC_done,
   output [15:0] MAB_in);

   // MAB_sel TABLE:
   // 0: PC -> MAB         1: Sout -> MAB
   // 2: CALC_OUT -> MAB   3: SP -> MAB
   // 4: MDB_out -> MAB   

   assign MAB_in =
                  (MAB_sel == 3'h0)               ? reg_PC_out :
                  // MDB_out for RST_VEC and RETI. Implement later.
                  (MAB_sel == 3'h1)               ? Sout       :
                  (MAB_sel == 3'h2) && CALC_done  ? CALC_out   :
                  (MAB_sel == 3'h2) && ~CALC_done ? reg_PC_out :
                  // SP for RETI...?
                  (MAB_sel == 3'h3)               ? reg_SP_out : 
                  (MAB_sel == 3'h4)               ? MDB_out    : reg_PC_out;

endmodule
