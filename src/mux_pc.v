module mux_pc
  (input [2:0]   MPC,
   input [15:0]  MDB_out, CALC_out, reg_PC_out,
   output [15:0] reg_PC_in);

   wire [15:0]   next_PC = {reg_PC_out[15:1],1'b0}+2;
   wire [79:0]   mux_ins_flat = {MDB_out,
                                 MDB_out<<1,
                                 CALC_out, // Probably doesn't need this? Not sure
                                 next_PC,
                                 reg_PC_out}; // Make a flattened vector of all inputs
   wire [15:0]   mux_ins [4:0]; // Make a 5 x 16-bit mem to address inputs
   assign reg_PC_in = mux_ins[MPC];
   // Use generate statement to assign elements of mem to inputs from flattened vector
   genvar        i;
   for (i = 0; i < 5; i = i + 1)
   begin
     assign mux_ins[i] = mux_ins_flat[(16*(i+1)-1):16*i];
   end
   
   
endmodule
