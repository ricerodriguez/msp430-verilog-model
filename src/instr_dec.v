/*
 Instruction Decoder
 ~~~~~~~~~~~~~~~~~~~
 Decodes the instructions coming off the MDB from ROM. First
 determines how many instructions to expect, then counts until that
 number of instructions has passed.
 TODO:
 - RE-DO COMPLETELY, MAKE MUX SELS ASYNC
 - MOVE COUNTER TO CALC
 x IGNORE MDB IF MAB != PC
 - RW SHOULD COME FROM CALC? OR FUNC UNIT?
 Notes:
 - IN PROGRESS. Will not work right now as it is being rewritten from
 the ground up.
 - Right now it sets PC to hold when instruction is not an 
 instruction, so that it way it doesn't pass over the 
 instruction before the register file receives it on the Din. 
 When is it supposed to tell PC to continue? How?
 */
`include "msp430_ops.vh"
module instr_dec
  (input        clk,
   input [15:0] MDB_out,
   input [15:0] MAB_in,
   input [15:0] reg_PC_out,
   input        CALC_done,
   input        MD_done,
   input [15:0] Sout,
   output [2:0] MAB_sel,
   output       MDB_sel,
   // output reg [1:0] FORMAT,
   output [5:0] FS,
   output       BW,
   output       RW,
   output       MW,
   output [1:0] MA, MB,
   output [3:0] reg_SA, reg_DA,
   output [2:0] AdAs, 
   output [1:0] MD,
   output       MC,
   output [2:0] MPC, 
   output [1:0] MSP, 
   output       MSR);
   // MPC - Select bit for MUX PC
   // MSP - Select bit for MUX SP
   // MSR - Select bit for MUX SR
   // MC  - Select bit for MUX CALC
   // MD  - Select bit for MUX Din

   localparam 
     FMT_I    = 1, FMT_II   = 2, FMT_J    = 3,
     MAB_PC   = 0, MAB_Sout = 1, MAB_CALC = 2,
     MAB_MDB  = 3;
   


   // Registers
   reg [15:0]       INSTR_REG_sync;
   reg [15:0]       INSTR_LAST;
   reg [15:0]       reg_PC_last;
   
   reg [3:0]        reg_DA_last;
   reg [1:0]        MD_last;
   reg              IMM_done; // Immediate mode instruction is already in IR
   reg [15:0]       MAB_last;
   reg [15:0]       MAB_IMM_last;
   
   
   
   // Initialize registers
   initial
     begin
        reg_PC_last <= reg_PC_out;
        INSTR_REG_sync <= 0;
        INSTR_LAST <= 0;
        reg_DA_last <= 0;
        MD_last <= 0;
        IMM_done <= 0;
        MAB_last <= 0;
        MAB_IMM_last <= 0;
     end // initial begin
   

   // Wires
   wire [1:0]  FORMAT;
   wire        IMM_mode;
   wire        pre_RW;
   wire [15:0] INSTR_REG;
   wire [15:0] MAB_IMM;
   wire        IMM_done_test;
   wire        FAIL_COND1; // The one exception to the rule that if MAB = PC then it's an instruction
   wire        FAIL_COND2; // Just kidding there's another one
   
   
   assign FAIL_COND1 = (AdAs[1] && (Sout == reg_PC_out)) ? 1 : 0;
   assign FAIL_COND2 = (AdAs[1:0] == 2'b01);
   

   assign INSTR_REG = (IMM_mode && IMM_done) ? INSTR_LAST : INSTR_REG_sync;
      
   assign AdAs = (FORMAT == FMT_I)  ? {INSTR_REG[7],INSTR_REG[5:4]} :
                 (FORMAT == FMT_II) ? {1'bx,INSTR_REG[5:4]}           : 3'bx;

   assign IMM_mode = (&AdAs[1:0] && !reg_SA) ? 1 : 0;

   assign MAB_IMM = ((FAIL_COND1 || FAIL_COND2) && ~IMM_done) ? MAB_last : MAB_IMM_last;

   // Extract SA from instruction
   assign reg_SA = (FORMAT == FMT_I)  ? INSTR_REG[11:8] : 
                   (FORMAT == FMT_II) ? INSTR_REG[3:0]  : 4'bx;

   assign reg_DA = (FORMAT <= FMT_II) && (IMM_mode && ~IMM_done)  ? reg_SA         :
                   (FORMAT <= FMT_II)                             ? INSTR_REG[3:0] : 4'bx;

   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   // MUX SELECT BITS
   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   // MUX A determines what goes into the A side of the function unit
   assign MA = !AdAs[1:0]                       ? 2'h0 : // Register mode
               (AdAs[1:0] == 2'b10)             ? 2'h1 : // Indirect reg mode
               (AdAs == 3'b001) || (&AdAs[1:0]) ? 2'h2 : // Indexed src or Indirect autoinc
               (AdAs == 3'b101)                 ? 2'h3 : // Indexed src and dst
               2'h0;

   assign MB = ~AdAs[2]   ? 1'b0 :
               AdAs[2]    ? 1'b1 : 1'b0;

   assign MC = (AdAs[2] || (AdAs[1:0] == 2'b01)) ? 1 : 0;

   assign MD = (~AdAs[1]) || (AdAs[1:0] == 2'b10) ? 2'h0 :
               // Indirect auto and we're holding the PC
               (AdAs[1:0] == 2'b11) && !MD_done       ? 2'h2 : 2'h0;


   assign MAB_sel = (!AdAs)              ? MAB_PC   :
                    // (AdAs[1:0] == 2'b10) ? MAB_Sout :
                    // Indirect register/autoincrement mode
                    MC                   ? MAB_CALC : MAB_PC;

   assign MW = AdAs[2] ? 1 : 0;
   assign MDB_sel = MW ? 1 : 0;

   // How do we get it to pause for a cycle to do the increment on
   // indirect register/autoincrement modes? The instruction length
   // is just 1, so it wants to pass the next instruction right away.
   // We need to hold MPC until we're ready.

   // Does this need to be two bits? I can't remember why it has a shifter
   // ^^ Yes!! It's for branching. Deal with it later
   // assign MPC = 
   //              !AdAs || (AdAs[1:0] == 2'b01) ? 2'h1 : // Register/Indexed
   //              AdAs[1] && ~MD_done           ? 2'h0 : // Indirect reg/auto
   //              2'h1;
   assign MPC = (FORMAT == FMT_J)                ? 2'h3 :
                // If it's indexed (src or dst) or reg mode, keep incrementing
                (AdAs[2] || AdAs[1:0] <= 2'b01)  ? 2'h1 :
                (AdAs[1] && ~MD_done) ? 2'h0 : 2'h1;
   
                

   assign MSP = 0; // For now

   assign BW = (FORMAT <= FMT_II) ? INSTR_REG[6] : BW;

   assign pre_RW = (FORMAT == FMT_I) && (INSTR_REG[15:12] == `OP_CMP) ? 1'b0 :
                   (FORMAT == FMT_I) && (INSTR_REG[15:12] == `OP_BIT) ? 1'b0 :
                   (FORMAT == FMT_J)                                  ? 1'b0 : 1'b1;
   
                   
   assign FS = (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_MOV)  ? `FS_MOV  :
               (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_ADD)  ? `FS_ADD  :
               (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_ADDC) ? `FS_ADDC :
               (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_SUBC) ? `FS_SUBC :
               (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_SUB)  ? `FS_SUB  :
               (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_CMP)  ? `FS_CMP  :
               (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_DADD) ? `FS_DADD :
               (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_BIT)  ? `FS_BIT  :
               (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_BIC)  ? `FS_BIC  :
               (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_BIS)  ? `FS_BIS  :
               (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_XOR)  ? `FS_XOR  :
               (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_AND)  ? `FS_AND  :
               (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_RRC)  ? `FS_RRC  :
               (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_SWPB) ? `FS_SWPB :
               (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_RRA)  ? `FS_RRA  :
               (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_SXT)  ? `FS_SXT  :
               (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_PUSH) ? `FS_PUSH :
               (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_CALL) ? `FS_CALL :
               (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_RETI) ? `FS_RETI :
               (FORMAT == FMT_J)                     ? {4'b0,INSTR_REG[12:10]} : 'bx;
   
               

   assign FORMAT = (INSTR_REG[15:13] == `OP_JUMP) ? FMT_J  :
                   (INSTR_REG[15:12] == 4'b0001)  ? FMT_II :
                   (INSTR_REG[15:12] >= 4'b0100)  ? FMT_I  : 0;
   
   assign BW = (FORMAT <= FMT_II) ? INSTR_REG[6] : 0;

   assign RW = pre_RW && (~AdAs[2]) && ~((~CALC_done && MC) && (FAIL_COND1 || FAIL_COND2)) ? 1 : 0;

   assign IMM_done_test = (MAB_IMM != MAB_last) && AdAs[1] ? 1 : 0;
   

   always @ (negedge clk)
     begin
        INSTR_LAST <= INSTR_REG;
        reg_DA_last <= reg_DA;
        MAB_last <= MAB_in;
        MAB_IMM_last <= MAB_IMM;
        // If the PC is the MAB, then it's *probably* an instruction
        if (MAB_in == reg_PC_out)
          begin
             // If the last instruction was immediate mode, it's not an instruction
             // INSTR_REG_sync <= (FAIL_COND1 && IMM_done) ? INSTR_REG_sync : MDB_out;
             if ((FAIL_COND1 || FAIL_COND2) && ~IMM_done)
               INSTR_REG_sync <= INSTR_REG_sync;
             else
               INSTR_REG_sync <= MDB_out;
             
             if (FAIL_COND1 || FAIL_COND2)
               IMM_done <= (MAB_IMM == MAB_last);
          end // if (MAB_in == reg_PC_out)
        else
          begin
             INSTR_REG_sync <= INSTR_LAST;
             if (AdAs[1])
               IMM_done <= 1;
          end  
     end // always @ (negedge clk)

endmodule
