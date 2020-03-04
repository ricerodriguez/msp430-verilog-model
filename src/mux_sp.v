// `include "msp430_ops.vh"
module mux_sp
  (input [15:0]  reg_SP_out,
   input [1:0]   MSP, // From instruction decoder
   output [15:0] reg_SP_in);
   
   wire [15:0] SP_force_even = {reg_SP_out[15:1],1'b0};

   wire [47:0] mux_ins_flat = {SP_force_even+2'd2,
                               SP_force_even-2'd2,
                               SP_force_even};
   
   wire [15:0] mux_ins_deep [2:0];
   genvar      i;
   assign reg_SP_in = mux_ins_deep[MSP];
   for (i=0;i<3;i=i+1)
     begin
        assign mux_ins_deep[i] = mux_ins_flat[16*(i+1)-1:16*i];
     end


endmodule
