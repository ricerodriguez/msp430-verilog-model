module mux_mab
  (input [15:0] reg_PC_out, reg_SP_out, MDB_out, CALC_out,
   input [1:0]   MAB_sel, // Maybe change this to be based of AdAs?
   input         CALC_done,
   output [15:0] MAB_in);

   // MAB_sel TABLE:
   // 0: PC -> MAB         1: MDB_out -> MAB   
   // 2: CALC_OUT -> MAB   3: SP -> MAB

   assign MAB_in =
                  (MAB_sel == 2'h0)  ? reg_PC_out :
                  (MAB_sel == 2'h1)  ? MDB_out : // Is this necessary?
                  (MAB_sel == 2'h2) && CALC_done  ? CALC_out :
                  (MAB_sel == 2'h2) && ~CALC_done ? reg_PC_out :
                  (MAB_sel == 2'h3)  ? reg_SP_out : reg_PC_out;

   
   // wire [95:0]   mux_ins_flat = {reg_SP_out,Dout,Sout,CALC_OUT,MDB_out,reg_PC_out}; // Make a flattened vector of all inputs
   // wire [15:0]   mux_ins [6:0]; // Make a 6 x 16-bit mem to address inputs
   // assign MAB_in = mux_ins[MAB_sel];
   // // Use generate statement to assign elements of mem to inputs from flattened vector
   // genvar        i;
   // for (i = 0; i < 6; i = i + 1)
   // begin
   //   assign mux_ins[i] = mux_ins_flat[(16*(i+1)-1):16*i];
   // end
   
   // assign MAB_in = (MAB_sel) ? regs_PC_out : regs_SP_out;

endmodule
