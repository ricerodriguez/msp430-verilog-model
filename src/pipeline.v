module pipeline #(parameter SIZE=16)
  (/*AUTOARG*/
   // Inputs
   rst, reg_SR_in, reg_SP_in, clk, RST_VEC, MDB_in, CALC_OUT
   );

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [15:0]         CALC_OUT;               // To u01 of mux_mab.v, ...
   input [15:0]         MDB_in;                 // To u00 of mem_space.v
   input [15:0]         RST_VEC;                // To u04 of reg_file.v
   input                clk;                    // To u00 of mem_space.v, ...
   input [15:0]         reg_SP_in;              // To u04 of reg_file.v
   input [15:0]         reg_SR_in;              // To u04 of reg_file.v
   input                rst;                    // To u04 of reg_file.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [2:0]           AdAs;                   // From u03 of instr_dec.v
   wire                 BW;                     // From u03 of instr_dec.v
   wire [3:0]           CVNZ_func;              // From u09 of func_unit.v
   wire [15:0]          Dout;                   // From u04 of reg_file.v
   wire [1:0]           FORMAT;                 // From u03 of instr_dec.v
   wire [5:0]           FS;                     // From u03 of instr_dec.v
   wire [SIZE-1:0]      F_OUT;                  // From u09 of func_unit.v
   wire [2:0]           MAB_SEL;                // From u03 of instr_dec.v
   wire [15:0]          MAB_in;                 // From u01 of mux_mab.v
   wire [2:0]           MC;                     // From u03 of instr_dec.v
   wire [1:0]           MD;                     // From u03 of instr_dec.v
   wire [15:0]          MDB_out;                // From u00 of mem_space.v
   wire [2:0]           MPC;                    // From u03 of instr_dec.v
   wire [1:0]           MSP;                    // From u03 of instr_dec.v
   wire                 MSR;                    // From u03 of instr_dec.v
   wire                 RW;                     // From u03 of instr_dec.v
   wire [15:0]          Sout;                   // From u04 of reg_file.v
   wire [3:0]           reg_DA;                 // From u03 of instr_dec.v
   wire [15:0]          reg_Din;                // From u10 of mux_din.v
   wire [15:0]          reg_PC_in;              // From u05 of mux_pc.v
   wire [15:0]          reg_PC_out;             // From u04 of reg_file.v
   wire [3:0]           reg_SA;                 // From u03 of instr_dec.v
   wire [15:0]          reg_SP_out;             // From u04 of reg_file.v
   wire [15:0]          reg_SR_out;             // From u04 of reg_file.v
   // End of automatics

   mem_space u00
     (.MW(RW),
      /*AUTOINST*/
      // Outputs
      .MDB_out                          (MDB_out[15:0]),
      // Inputs
      .BW                               (BW),
      .MAB_in                           (MAB_in[15:0]),
      .MDB_in                           (MDB_in[15:0]),
      .clk                              (clk));   

   mux_mab u01
     (/*AUTOINST*/
      // Outputs
      .MAB_in                           (MAB_in[15:0]),
      // Inputs
      .CALC_OUT                         (CALC_OUT[15:0]),
      .Dout                             (Dout[15:0]),
      .MAB_SEL                          (MAB_SEL[2:0]),
      .MDB_out                          (MDB_out[15:0]),
      .Sout                             (Sout[15:0]),
      .reg_PC_out                       (reg_PC_out[15:0]),
      .reg_SP_out                       (reg_SP_out[15:0]));

   // mux_mdb u02
   //   (/*AUTOINST*/);   

   instr_dec u03
     (/*AUTOINST*/
      // Outputs
      .AdAs                             (AdAs[2:0]),
      .BW                               (BW),
      .FORMAT                           (FORMAT[1:0]),
      .FS                               (FS[5:0]),
      .MAB_SEL                          (MAB_SEL[2:0]),
      .MC                               (MC[2:0]),
      .MD                               (MD[1:0]),
      .MPC                              (MPC[2:0]),
      .MSP                              (MSP[1:0]),
      .MSR                              (MSR),
      .RW                               (RW),
      .reg_DA                           (reg_DA[3:0]),
      .reg_SA                           (reg_SA[3:0]),
      // Inputs
      .MDB_out                          (MDB_out[15:0]),
      .clk                              (clk));

   reg_file u04
     (.As(AdAs[1:0]),
      /*AUTOINST*/
      // Outputs
      .Dout                             (Dout[15:0]),
      .Sout                             (Sout[15:0]),
      .reg_PC_out                       (reg_PC_out[15:0]),
      .reg_SP_out                       (reg_SP_out[15:0]),
      .reg_SR_out                       (reg_SR_out[15:0]),
      // Inputs
      .RST_VEC                          (RST_VEC[15:0]),
      .RW                               (RW),
      .clk                              (clk),
      .reg_DA                           (reg_DA[3:0]),
      .reg_Din                          (reg_Din[15:0]),
      .reg_PC_in                        (reg_PC_in[15:0]),
      .reg_SA                           (reg_SA[3:0]),
      .reg_SP_in                        (reg_SP_in[15:0]),
      .reg_SR_in                        (reg_SR_in[15:0]),
      .rst                              (rst));

   mux_pc u05
     (/*AUTOINST*/
      // Outputs
      .reg_PC_in                        (reg_PC_in[15:0]),
      // Inputs
      .CALC_OUT                         (CALC_OUT[15:0]),
      .MDB_out                          (MDB_out[15:0]),
      .MPC                              (MPC[2:0]),
      .reg_PC_out                       (reg_PC_out[15:0]));

   // mux_sr u06
   //   (/*AUTOINST*/);

   // mux_sp u07
   //   (/*AUTOINST*/);

   func_unit u09
     (.A(Sout),
      .B(Dout),
      .Cin(reg_SR_out[0]),
      /*AUTOINST*/
      // Outputs
      .CVNZ_func                        (CVNZ_func[3:0]),
      .F_OUT                            (F_OUT[SIZE-1:0]),
      // Inputs
      .BW                               (BW),
      .FS                               (FS[5:0]));

   mux_din u10
     (/*AUTOINST*/
      // Outputs
      .reg_Din                          (reg_Din[15:0]),
      // Inputs
      .CALC_OUT                         (CALC_OUT[15:0]),
      .F_OUT                            (F_OUT[15:0]),
      .MD                               (MD[1:0]),
      .MDB_out                          (MDB_out[15:0]));
   

   

endmodule
