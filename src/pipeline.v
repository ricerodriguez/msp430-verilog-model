module pipeline #(parameter SIZE=16)
  (/*AUTOARG*/
   // Inputs
   rst, clk, RST_VEC
   );

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [15:0]         RST_VEC;                // To u04_reg_file of reg_file.v
   input                clk;                    // To u00_mem_space of mem_space.v, ...
   input                rst;                    // To u04_reg_file of reg_file.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]          A;                      // From u11_mux_a of mux_a.v
   wire [2:0]           AdAs;                   // From u03_instr_dec of instr_dec.v
   wire [15:0]          B;                      // From u12_mux_b of mux_b.v
   wire                 BW;                     // From u03_instr_dec of instr_dec.v
   wire                 CALC_done;              // From u13_calc of calc.v
   wire [15:0]          CALC_out;               // From u13_calc of calc.v
   wire [3:0]           CVNZ_func;              // From u09_func_unit of func_unit.v
   wire [15:0]          Dout;                   // From u04_reg_file of reg_file.v
   wire [5:0]           FS;                     // From u03_instr_dec of instr_dec.v
   wire [SIZE-1:0]      F_out;                  // From u09_func_unit of func_unit.v
   wire [1:0]           MA;                     // From u03_instr_dec of instr_dec.v
   wire                 MAB_done;               // From u01_mux_mab of mux_mab.v
   wire [15:0]          MAB_in;                 // From u01_mux_mab of mux_mab.v
   wire [2:0]           MAB_sel;                // From u03_instr_dec of instr_dec.v
   wire [1:0]           MB;                     // From u03_instr_dec of instr_dec.v
   wire                 MC;                     // From u03_instr_dec of instr_dec.v
   wire [1:0]           MD;                     // From u03_instr_dec of instr_dec.v
   wire [15:0]          MDB_in;                 // From u02 of mux_mdb.v
   wire [15:0]          MDB_out;                // From u00_mem_space of mem_space.v
   wire [1:0]           MDB_sel;                // From u03_instr_dec of instr_dec.v
   wire                 MD_done;                // From u10_mux_din of mux_din.v
   wire [2:0]           MPC;                    // From u03_instr_dec of instr_dec.v
   wire [1:0]           MSP;                    // From u03_instr_dec of instr_dec.v
   wire [1:0]           MSR;                    // From u03_instr_dec of instr_dec.v
   wire                 MW;                     // From u03_instr_dec of instr_dec.v
   wire                 RW;                     // From u03_instr_dec of instr_dec.v
   wire [15:0]          Sout;                   // From u04_reg_file of reg_file.v
   wire                 ram_write_done;         // From u00_mem_space of mem_space.v
   wire [3:0]           reg_DA;                 // From u03_instr_dec of instr_dec.v
   wire [15:0]          reg_Din;                // From u10_mux_din of mux_din.v
   wire [15:0]          reg_PC_in;              // From u05_mux_pc of mux_pc.v
   wire [15:0]          reg_PC_out;             // From u04_reg_file of reg_file.v
   wire [3:0]           reg_SA;                 // From u03_instr_dec of instr_dec.v
   wire [15:0]          reg_SP_in;              // From u07 of mux_sp.v
   wire [15:0]          reg_SP_out;             // From u04_reg_file of reg_file.v
   wire [15:0]          reg_SR_in;              // From u06 of mux_sr.v
   wire [15:0]          reg_SR_out;             // From u04_reg_file of reg_file.v
   // End of automatics

   mem_space u00_mem_space
     (/*AUTOINST*/
      // Outputs
      .MDB_out                          (MDB_out[15:0]),
      .ram_write_done                   (ram_write_done),
      // Inputs
      .BW                               (BW),
      .MAB_in                           (MAB_in[15:0]),
      .MDB_in                           (MDB_in[15:0]),
      .MW                               (MW),
      .clk                              (clk));   

   mux_mab u01_mux_mab
     (/*AUTOINST*/
      // Outputs
      .MAB_done                         (MAB_done),
      .MAB_in                           (MAB_in[15:0]),
      // Inputs
      .CALC_done                        (CALC_done),
      .CALC_out                         (CALC_out[15:0]),
      .MAB_sel                          (MAB_sel[2:0]),
      .MD                               (MD),
      .MDB_out                          (MDB_out[15:0]),
      .RW                               (RW),
      .Sout                             (Sout[15:0]),
      .clk                              (clk),
      .reg_PC_out                       (reg_PC_out[15:0]),
      .reg_SP_out                       (reg_SP_out[15:0]));

   mux_mdb u02
     (/*AUTOINST*/
      // Outputs
      .MDB_in                           (MDB_in[15:0]),
      // Inputs
      .F_out                            (F_out[15:0]),
      .MDB_out                          (MDB_out[15:0]),
      .MDB_sel                          (MDB_sel[1:0]),
      .Sout                             (Sout[15:0]));   

   instr_dec u03_instr_dec
     (/*AUTOINST*/
      // Outputs
      .AdAs                             (AdAs[2:0]),
      .BW                               (BW),
      .FS                               (FS[5:0]),
      .MA                               (MA[1:0]),
      .MAB_sel                          (MAB_sel[2:0]),
      .MB                               (MB[1:0]),
      .MC                               (MC),
      .MD                               (MD[1:0]),
      .MDB_sel                          (MDB_sel[1:0]),
      .MPC                              (MPC[2:0]),
      .MSP                              (MSP[1:0]),
      .MSR                              (MSR[1:0]),
      .MW                               (MW),
      .RW                               (RW),
      .reg_DA                           (reg_DA[3:0]),
      .reg_SA                           (reg_SA[3:0]),
      // Inputs
      .CALC_done                        (CALC_done),
      .MAB_done                         (MAB_done),
      .MAB_in                           (MAB_in[15:0]),
      .MDB_out                          (MDB_out[15:0]),
      .MD_done                          (MD_done),
      .Sout                             (Sout[15:0]),
      .clk                              (clk),
      .ram_write_done                   (ram_write_done),
      .reg_Din                          (reg_Din[15:0]),
      .reg_PC_out                       (reg_PC_out[15:0]));

   reg_file u04_reg_file
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

   mux_pc u05_mux_pc
     (/*AUTOINST*/
      // Outputs
      .reg_PC_in                        (reg_PC_in[15:0]),
      // Inputs
      .CALC_out                         (CALC_out[15:0]),
      .MDB_out                          (MDB_out[15:0]),
      .MPC                              (MPC[2:0]),
      .reg_PC_out                       (reg_PC_out[15:0]));

   mux_sr u06
     (/*AUTOINST*/
      // Outputs
      .reg_SR_in                        (reg_SR_in[15:0]),
      // Inputs
      .CVNZ_func                        (CVNZ_func[3:0]),
      .MDB_out                          (MDB_out[15:0]),
      .MSR                              (MSR[1:0]),
      .reg_SR_out                       (reg_SR_out[15:0]));

   mux_sp u07
     (/*AUTOINST*/
      // Outputs
      .reg_SP_in                        (reg_SP_in[15:0]),
      // Inputs
      .MSP                              (MSP[1:0]),
      .reg_SP_out                       (reg_SP_out[15:0]));

   func_unit u09_func_unit
     (.Cin(reg_SR_out[0]),
      /*AUTOINST*/
      // Outputs
      .CVNZ_func                        (CVNZ_func[3:0]),
      .F_out                            (F_out[SIZE-1:0]),
      // Inputs
      .A                                (A[SIZE-1:0]),
      .B                                (B[SIZE-1:0]),
      .BW                               (BW),
      .FS                               (FS[5:0]),
      .MDB_out                          (MDB_out[15:0]),
      .reg_SR_out                       (reg_SR_out[15:0]));

   mux_din u10_mux_din
     (/*AUTOINST*/
      // Outputs
      .MD_done                          (MD_done),
      .reg_Din                          (reg_Din[15:0]),
      // Inputs
      .BW                               (BW),
      .F_out                            (F_out[15:0]),
      .MD                               (MD[1:0]),
      .MDB_out                          (MDB_out[15:0]),
      .RW                               (RW),
      .Sout                             (Sout[15:0]),
      .clk                              (clk));

   mux_a u11_mux_a
     (/*AUTOINST*/
      // Outputs
      .A                                (A[15:0]),
      // Inputs
      .MA                               (MA[1:0]),
      .MDB_out                          (MDB_out[15:0]),
      .Sout                             (Sout[15:0]),
      .clk                              (clk));
   
   mux_b u12_mux_b
     (/*AUTOINST*/
      // Outputs
      .B                                (B[15:0]),
      // Inputs
      .Dout                             (Dout[15:0]),
      .MB                               (MB[1:0]),
      .MDB_out                          (MDB_out[15:0]),
      .clk                              (clk));

   calc u13_calc
     (/*AUTOINST*/
      // Outputs
      .CALC_done                        (CALC_done),
      .CALC_out                         (CALC_out[15:0]),
      // Inputs
      .AdAs                             (AdAs[2:0]),
      .Dout                             (Dout[15:0]),
      .MC                               (MC),
      .MDB_out                          (MDB_out[15:0]),
      .Sout                             (Sout[15:0]),
      .clk                              (clk));
   
endmodule
