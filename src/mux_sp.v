module mux_sp
  (input [15:0]  reg_SP_out,
   input [1:0]   MUX_SP_SEL, // From control unit
   output [15:0] reg_SP_in);

   wire [15:0] SP_force_even = {reg_SP_out[15:1],1'b0};
   wire [47:0] mux_ins_flat = {SP_force_even,
                               SP_force_even+2'd2,
                               SP_force_even-2'd2};
   
   wire [15:0] mux_ins_deep [2:0];
   genvar      i;
   for (i=0;i<3;i=i+1)
     begin
        assign mux_ins_deep[i] = mux_ins_flat[16*(i+1)-1:16*i];
     end

   assign reg_SP_in = mux_ins_deep[MUX_SP_SEL];

endmodule
