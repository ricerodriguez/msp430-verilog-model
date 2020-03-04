module func_unit #(parameter SIZE=16)
  (input [SIZE-1:0]  A, B, 
   input [5:0]       FS,
   input             Cin,
   input             BW,
   input [15:0]      MDB_out,
   input [15:0]      reg_SR_out,
   output [3:0]      CVNZ_func,
   output [SIZE-1:0] F_out);

   localparam SIZE_BYTE = SIZE/2, SIZE_WORD = SIZE;

   wire              Cin_mux_out;
   wire [SIZE-1:0]   ALU_OUT, SHIFT_OUT;
   wire [SIZE-1:0]   SRC, DST;
   wire [3:0]        CVNZ_alu, CVNZ_shift;

   // MUX O decides order of src, dst
   assign SRC = !FS[2] ? A : B;
   assign DST = !FS[2] ? B : A;

   // MUX F decides output from ALU or shifter
   assign F_out     = !FS[5] ? ALU_OUT   : 
                      FS[5]  ? SHIFT_OUT : MDB_out;
   assign CVNZ_func = !FS[5] ? CVNZ_alu : CVNZ_shift;
   

   // MUX Cin determines what to use as Cin
   assign Cin_mux_out = FS[3] ? Cin : FS[2];

   
   alu #(SIZE) u1
     (.Cin                              (Cin_mux_out),
      /*AUTOINST*/
      // Outputs
      .ALU_OUT                          (ALU_OUT[SIZE-1:0]),
      .CVNZ_alu                         (CVNZ_alu[3:0]),
      // Inputs
      .BW                               (BW),
      .DST                              (DST[SIZE-1:0]),
      .FS                               (FS[5:0]),
      .SRC                              (SRC[SIZE-1:0]));

   shifter #(SIZE_BYTE,SIZE_WORD) u2
     (/*AUTOINST*/
      // Outputs
      .CVNZ_shift                       (CVNZ_shift[3:0]),
      .SHIFT_OUT                        (SHIFT_OUT[SIZE_WORD-1:0]),
      // Inputs
      .BW                               (BW),
      .DST                              (DST[SIZE_WORD-1:0]),
      .FS                               (FS[1:0]));

endmodule
