module mux_pc
  (input [2:0]   sel,
   input [15:0]  MDB,
   input [15:0]  CALC_OUT,
   input [15:0]  reg_PC_out,
   output [15:0] reg_PC_in);

   wire [15:0]   next_PC = reg_PC_out + 2;
   wire [15:0]   mux_ins [4:0];
   assign mux_ins[0] = MDB;
   assign mux_ins[1] = MDB << 1;   
   assign mux_ins[2] = CALC_OUT;
   assign mux_ins[3] = reg_PC_out;
   assign mux_ins[4] = next_PC;

   assign reg_PC_in = mux_ins[sel];
endmodule
