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

endmodule
