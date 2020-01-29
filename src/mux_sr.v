module mux_sr
  (input [15:0]  reg_SR_out,
   input [3:0]   CVNZ_func,
   input         MSR, // From instruction decoder
   output [15:0] reg_SR_in);

   wire [15:0]   reg_SR_func = {7'bx,
                                CVNZ_func[2],
                                reg_SR_out[7:3],
                                CVNZ_func[1],
                                CVNZ_func[0],
                                CVNZ_func[0]};

   assign reg_SR_in = (MSR) ? reg_SR_func : reg_SR_out;

   // wire [31:0] mux_ins_flat = {reg_SR_func,
   //                             reg_SR_out};
   
   // wire [15:0] mux_ins_deep [1:0];
   // genvar      i;
   // for (i=0;i<2;i=i+1)
   //   begin
   //      assign mux_ins_deep[i] = mux_ins_flat[16*(i+1)-1:16*i];
   //   end

   // assign reg_SR_in = mux_ins_deep[MSR];

endmodule
