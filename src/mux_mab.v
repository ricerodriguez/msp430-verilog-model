module mux_mab
  (input [15:0] regs_PC_out, regs_SP_out,
   input MAB_SEL,
   output [16:0] MAB); // Addressable memory is 128kB, ceil(log2(128k)) = 17 bits

   assign MAB = (MAB_SEL) ? regs_PC_out : regs_SP_out;

endmodule
