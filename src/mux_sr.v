module mux_sr
  (input [15:0]  MDB_out,
   input [15:0]  reg_SR_out,
   input [3:0]   CVNZ_func,
   input [1:0]   MSR, // From instruction decoder
   output [15:0] reg_SR_in);

   wire [15:0]   reg_SR_func = {7'bx,
                                CVNZ_func[2],
                                reg_SR_out[7:3],
                                CVNZ_func[1],
                                CVNZ_func[0],
                                CVNZ_func[0]};

   assign reg_SR_in = (MSR == 2'h0) ? reg_SR_out :
                      (MSR == 2'h1) ? reg_SR_func :
                      (MSR == 2'h2) ? MDB_out : reg_SR_out;
                      // (MSR == 2'h2) ? reg_SP_out :

endmodule
