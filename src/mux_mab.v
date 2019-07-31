module mux_mab
  (input [15:0] reg_PC_out, reg_SP_out, Sout, Dout, CALC_OUT,
   input [1:0] MAB_SEL,   // Maybe change this to be based of AdAs?
   output [15:0] MAB_in);

   wire [63:0]   mux_ins_flat = {reg_SP_out,Sout,CALC_OUT,reg_PC_out}; // Make a flattened vector of all inputs
   wire [15:0]   mux_ins [4:0]; // Make a 5 x 16-bit mem to address inputs
   assign MAB_in = mux_ins[MAB_SEL];
   // Use generate statement to assign elements of mem to inputs from flattened vector
   genvar        i;
   for (i = 0; i < 4; i = i + 1)
   begin
     assign mux_ins[i] = mux_ins_flat[(16*(i+1)-1):16*i];
   end
   
   // assign MAB_in = (MAB_SEL) ? regs_PC_out : regs_SP_out;

endmodule
