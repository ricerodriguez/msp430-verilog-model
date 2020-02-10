/*
 Instruction Decoder
 ~~~~~~~~~~~~~~~~~~~
 Decodes the instructions coming off the MDB from ROM. First
 determines how many instructions to expect, then counts until that
 number of instructions has passed.
 TODO:
   - FIX MAB_sel, for some reason it breaks when it uses AdAs==2'b10

 */
`include "msp430_ops.vh"
module instr_dec
  (input            clk,
   input [15:0]     MDB_out,
   input [15:0]     MAB_in,
   input [15:0]     reg_PC_out,
   input            CALC_done,
   input            MAB_done,
   input            MD_done,
   input [15:0]     Sout,
   output reg [2:0] MAB_sel,
   output [1:0]     MDB_sel,
   output [5:0]     FS,
   output           BW,
   output           RW,
   output           MW,
   output [1:0]     MA, MB,
   output [3:0]     reg_SA, reg_DA,
   output [2:0]     AdAs, 
   output [1:0]     MD,
   output           MC,
   output [2:0]     MPC, 
   output [1:0]     MSP, 
   output           MSR);
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
   reg [15:0]       INSTR_REG;
   reg [15:0]       INSTR_LAST;
   reg [15:0]       reg_PC_last;
   
   reg [3:0]        reg_DA_last;
   reg [1:0]        MD_last;
   reg              FAIL_COND_done; // Immediate mode instruction is already in IR
   reg [15:0]       MAB_last;
   reg [15:0]       MAB_IMM_last;
   
   // Initialize registers
   initial
     begin
        reg_PC_last <= reg_PC_out;
        INSTR_REG <= 0;
        INSTR_LAST <= 0;
        reg_DA_last <= 0;
        MD_last <= 0;
        FAIL_COND_done <= 0;
        MAB_last <= 0;
        MAB_IMM_last <= 0;
        MAB_sel <= 0;
     end // initial begin
   

   // Wires
   wire [1:0]  FORMAT;
   wire        pre_RW;


   wire [15:0] MAB_IMM;
   // Two conditions for when there is a word in ROM not an instruction
   wire        FAIL_COND1; // Immediate Mode
   wire        FAIL_COND2; // Indexed mode
   // Two conditions for when to have DA = SA before DA = DA
   wire        HOLD_COND1; // Immediate mode
   wire        HOLD_COND2; // Indirect register autoincrement mode
      
   
   assign FAIL_COND1 = (AdAs[1] && (Sout == reg_PC_out)) ? 1 : 0;
   assign FAIL_COND2 = (AdAs[2] || (AdAs[1:0] == 2'b01));

   assign HOLD_COND1 = (FAIL_COND1 && ~FAIL_COND_done) ? 1 : 0;
   assign HOLD_COND2 = (AdAs[1] && MAB_done) ? 1 : 0;
   
   assign CONST_GEN  = ((reg_SA == 4'h3) || (reg_SA == 4'h2)) && (AdAs>0) ? 1 : 0;
      
   assign AdAs = (FORMAT == FMT_I)  ? {INSTR_REG[7],INSTR_REG[5:4]} :
                 (FORMAT == FMT_II) ? {1'bx,INSTR_REG[5:4]}           : 3'bx;

   assign MAB_IMM = ((FAIL_COND1 || FAIL_COND2) && ~FAIL_COND_done) ? MAB_last : MAB_IMM_last;

   // Extract SA from instruction
   assign reg_SA = (FORMAT == FMT_I)  ? INSTR_REG[11:8] : 
                   (FORMAT == FMT_II) ? INSTR_REG[3:0]  : 4'bx;

   assign reg_DA = (FORMAT <= FMT_II) && (HOLD_COND1 || HOLD_COND2)  ? reg_SA         :
                   (FORMAT <= FMT_II)                                ? INSTR_REG[3:0] : 4'bx;

   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   // MUX SELECT BITS
   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   // MUX A determines what goes into the A side of the function unit
   assign MA = ((!AdAs[1:0]) || CONST_GEN)      ? 2'h0 : // Register mode
               (AdAs[1:0] == 2'b10)             ? 2'h1 : // Indirect reg mode
               (AdAs == 3'b001) || (&AdAs[1:0]) ? 2'h2 : // Indexed src or Indirect autoinc
               (AdAs == 3'b101)                 ? 2'h3 : // Indexed src and dst
               2'h0;

   assign MB = ~AdAs[2]   ? 1'b0 :
               AdAs[2]    ? 1'b1 : 1'b0;

   assign MC = (AdAs[2] || (AdAs[1:0] == 2'b01)) && ~CONST_GEN ? 1 : 0;

   assign MD = (~AdAs[1]) || (AdAs[1:0] == 2'b10) ? 2'h0 :
               // Indirect auto and we're holding the PC
               (AdAs[1:0] == 2'b11) && !MD_done       ? 2'h2 : 2'h0;

   always @ (*)
     begin
        if (!AdAs)
          MAB_sel <= MAB_PC;
        else if (AdAs[1] && ~CONST_GEN && ~MAB_done)
          MAB_sel <= MAB_Sout;
        else if (MC)
          MAB_sel <= MAB_CALC;
        else
          MAB_sel <= MAB_PC;
     end  

   assign MW = (AdAs[2] && CALC_done) ? 1    : 0;
   assign MDB_sel = (!AdAs[2])        ? 2'h0 :
                    (AdAs == 3'b100)  ? 2'h2 : 2'h1;
   
   // How do we get it to pause for a cycle to do the increment on
   // indirect register/autoincrement modes? The instruction length
   // is just 1, so it wants to pass the next instruction right away.
   // We need to hold MPC until we're ready.

   // Does this need to be two bits? I can't remember why it has a shifter
   // ^^ Yes!! It's for branching. Deal with it later
   assign MPC = (FORMAT == FMT_J)                ? 2'h3 :
                // If it's indexed (src or dst) or reg mode, keep incrementing
                (FAIL_COND2 && CALC_done)        ? 2'h1 :
                // Indexed and we haven't finished calculating but
                // we already finished looking at the instruction
                (FAIL_COND2) && FAIL_COND_done   ? 2'h0 :
                // Indirect auto and we aren't done looking at the
                // instruction
                (FAIL_COND1) && ~FAIL_COND_done  ? 2'h0 : 
                (HOLD_COND2)                     ? 2'h0 : 2'h1;

   assign MSP = 0; // For now
   assign MSR = 0;

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

   always @ (negedge clk)
     begin
        INSTR_LAST <= INSTR_REG;
        reg_DA_last <= reg_DA;
        MAB_last <= MAB_in;
        MAB_IMM_last <= MAB_IMM;

        // If the PC is the MAB, then it's *probably* an instruction
        if (MAB_in == reg_PC_out)
          begin
             // If one of the fail conditions is true, and we haven't moved on
             // from the instruction yet, latch it
             if ((FAIL_COND1 || FAIL_COND2) && ~FAIL_COND_done)
               INSTR_REG <= INSTR_REG;
             else
               // Otherwise put the MDB into the IR
               INSTR_REG <= MDB_out;

             // If one of the fail conditions is true, eval FAIL_COND_done
             if (FAIL_COND1 || FAIL_COND2)
               // If the MAB from the instruction was the last address
               // that was used, then we're done looking at the instruction
               FAIL_COND_done <= (MAB_IMM == MAB_last);
          end // if (MAB_in == reg_PC_out)
        else
          begin
             INSTR_REG <= INSTR_REG;
             if (AdAs[1])
               FAIL_COND_done <= 1;
          end  
     end // always @ (negedge clk)

endmodule
