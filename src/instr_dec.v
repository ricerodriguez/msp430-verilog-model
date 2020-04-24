/*
 Instruction Decoder
 ~~~~~~~~~~~~~~~~~~~
 Decodes the instructions coming off the MDB from ROM. First
 determines how many instructions to expect, then counts until that
 number of instructions has passed.

 */
`include "msp430_ops.vh"
module instr_dec
  (input            clk,
   input [15:0]     MDB_out,
   input [15:0]     MAB_in,
   input [15:0]     reg_PC_out,
   input [15:0]     reg_SP_out,
   input            CALC_done,
   input            MAB_done,
   input            MD_done,
   input [15:0]     Sout,
   input [15:0]     reg_Din,
   input            ram_write_done,
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
   output [1:0]     MSR);
   // MPC - Select bit for MUX PC
   // MSP - Select bit for MUX SP
   // MSR - Select bit for MUX SR
   // MC  - Select bit for MUX CALC
   // MD  - Select bit for MUX Din

   localparam 
     FMT_I    = 1, FMT_II   = 2, FMT_J    = 3,
     MAB_PC   = 0, MAB_Sout = 1, MAB_CALC = 2,
     MAB_SP   = 3, MAB_MDB  = 4;

   // Registers
   reg [15:0]       INSTR_REG;
   reg [15:0]       INSTR_LAST;
   reg [15:0]       reg_PC_last;
   
   reg [3:0]        reg_DA_last;
   reg [3:0]        reg_SA_last;
   reg [1:0]        MD_last;
   reg              FAIL_COND_done; // Immediate mode instruction is already in IR
   reg [15:0]       MAB_last;
   reg [15:0]       MAB_IMM_last;
   reg              RW_last;
   reg              IND_REG_done;
   reg              INCR_done;
   reg              ram_write_done_sync;
   reg              stack_updated;
   
   // Initialize registers
   initial
     begin
        reg_PC_last <= reg_PC_out;
        INSTR_REG <= 0;
        INSTR_LAST <= 0;
        reg_DA_last <= 0;
        reg_SA_last <= 0;
        MD_last <= 0;
        FAIL_COND_done <= 0;
        MAB_last <= 0;
        MAB_IMM_last <= 0;
        MAB_sel <= 0;
        RW_last <= 0;
        IND_REG_done <= 0;
        INCR_done <= 0;
        ram_write_done_sync <= 0;
        stack_updated <= 0;
     end // initial begin
   
   // Other half cycle latches, plus done bits for "state" machines
   always @ (posedge clk)
     begin
        RW_last <= RW;
        reg_DA_last <= reg_DA;
        reg_SA_last <= reg_SA;
        IND_REG_done <= (RW && (AdAs[1]) && (reg_Din == MDB_out)) ? 1 : 0;
        INCR_done <= (RW && (&AdAs[1:0]) && (reg_SA == reg_DA)) ? 1 : 0;
        stack_updated <= (MW && (MAB_in == reg_SP_out)) ? 1 : 0;
     end  

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
   wire        CONST_GEN;

   // For a memory write to happen, Ad must be 1 or instruction is PUSH or CALL.
   wire        MW_COND1;   // Condition 1 for Memory Write bit to be enabled:
                           // Ad bit is 1... AND MAB is lined up. 

   wire        MW_COND2;   // Condition 2 for Memory Write bit to be enabled:
                           // Instruction is either PUSH or CALL... AND MAB is lined
                           // up. 
   
   
   
   wire [2:0]  MAB_sel_w;
   
         
   assign FAIL_COND1 = (AdAs[1] && (Sout == reg_PC_out)) ? 1 : 0;
   assign FAIL_COND2 = (AdAs[2] || (AdAs[1:0] == 2'b01));

   assign HOLD_COND1 = (FAIL_COND1 && ~FAIL_COND_done) ? 1 : 0;
   assign HOLD_COND2 = (AdAs[1] && MAB_done) ? 1 : 0;
   
   assign CONST_GEN  = ((reg_SA == 4'h3) || (reg_SA == 4'h2)) && (AdAs>0) ? 1 : 0;
      
   assign AdAs = (FORMAT == FMT_I)  ? {INSTR_REG[7],INSTR_REG[5:4]} :
                 (FORMAT == FMT_II) ? {1'b0,INSTR_REG[5:4]}           : 3'bx;

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
               (AdAs[1])                        ? 2'h1 :
               (AdAs == 3'b001)                 ? 2'h2 : // Indexed src or Indirect autoinc               
               // // (AdAs == 3'b001) || (&AdAs[1:0]) ? 2'h2 : // Indexed src or Indirect autoinc
               (AdAs == 3'b101)                 ? 2'h3 : // Indexed src and dst
               2'h0;

   assign MB = (AdAs[2] && ~CONST_GEN) ? 1 : 0;
   
   assign MC = (AdAs[2] || (AdAs[1:0] == 2'b01)) && ~CONST_GEN ? 1 : 0;

   assign MD = (~AdAs[1]) ? 2'h0 :
               (AdAs[1:0] == 2'b10 && ~CONST_GEN) ? 2'h1 :
               // Indirect auto and we're holding the PC
               (&AdAs[1:0] && ~INCR_done)   ? 2'h2 : 2'h0;

   always @ (*)
     begin
        if ((!AdAs) && (FS != `FS_PUSH))
          MAB_sel <= MAB_PC;
        else if (AdAs[1] && ~CONST_GEN && ~IND_REG_done)
          MAB_sel <= MAB_Sout;
        else if (MC)
          MAB_sel <= MAB_CALC;
        // else if ((FS == `FS_PUSH) && ~ram_write_done_sync)
        else if (((FS == `FS_PUSH) || (FS == `FS_CALL)))
          MAB_sel <= MAB_SP;
        else
          MAB_sel <= MAB_PC;
     end // always @ (*)

   assign MAB_sel_w = (!AdAs) ? 3'h0 :
                      (AdAs[1] && ~CONST_GEN && ~IND_REG_done) ? 3'h1 :
                      (MC) ? 3'h2 : 3'h0;

   // Condition 1: Ad is 1 and calculator has finished calculating, so MAB should be lined up now.
   assign MW_COND1 = (AdAs[2] && CALC_done) ? 1 : 0;
   // Condition 2: Instruction is PUSH or CALL. Exit condition: MAB = SP and MW on posedge.
   assign MW_COND2 = ((FS == `FS_PUSH) || (FS == `FS_CALL)) ? 1 : 0;

   // Memory Write bit enabled when there is a write to RAM.
   assign MW = (MW_COND1 || MW_COND2) ? 1 : 0;
   // assign MW = ((FS == `FS_PUSH) && ~ram_write_done)       ? 1    :
               // (AdAs[2] && CALC_done) ? 1    : 0;
   

   assign MDB_sel = ((!AdAs[2]) && (FS != `FS_PUSH))      ? 2'h0 :
                    (AdAs == 3'b100) || (FS == `FS_PUSH) ? 2'h2 : 2'h1;
   
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
                (ram_write_done_sync)            ? 2'h0 :
                (HOLD_COND2)                     ? 2'h0 : 2'h1;

   // assign MSP = ((FS == `FS_PUSH) && ~ram_write_done) ? 2'h1 : 2'h0; // For now

   assign MSP = (((FS == `FS_PUSH) || (FS == `FS_CALL)) && ~stack_updated) ? 1 : 0;
   
   assign BW = (FORMAT <= FMT_II) ? INSTR_REG[6] : BW;
   assign pre_RW = (FORMAT == FMT_I) && (INSTR_REG[15:12] == `OP_CMP)  ? 1'b0 :
                   (FORMAT == FMT_I) && (INSTR_REG[15:12] == `OP_BIT)  ? 1'b0 :
                   (FORMAT == FMT_II) && (INSTR_REG[15:7] == `OP_PUSH) ? 1'b0 :                   
                   (FORMAT == FMT_J)                                   ? 1'b0 : 1'b1;
   
                   
   assign {MSR,FS} = (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_MOV)  ? {2'h0, `FS_MOV}  :
                     (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_ADD)  ? {2'h1, `FS_ADD}  :
                     (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_ADDC) ? {2'h1, `FS_ADDC} :
                     (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_SUBC) ? {2'h1, `FS_SUBC} :
                     (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_SUB)  ? {2'h1, `FS_SUB}  :
                     (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_CMP)  ? {2'h1, `FS_CMP}  :
                     (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_DADD) ? {2'h1, `FS_DADD} :
                     (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_BIT)  ? {2'h1, `FS_BIT}  :
                     (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_BIC)  ? {2'h0, `FS_BIC}  :
                     (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_BIS)  ? {2'h0, `FS_BIS}  :
                     (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_XOR)  ? {2'h1, `FS_XOR}  :
                     (FORMAT == FMT_I)  && (INSTR_REG[15:12] == `OP_AND)  ? {2'h1, `FS_AND}  :
                     (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_RRC)  ? {2'h1, `FS_RRC}  :
                     (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_SWPB) ? {2'h0, `FS_SWPB} :
                     (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_RRA)  ? {2'h1, `FS_RRA}  :
                     (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_SXT)  ? {2'h1, `FS_SXT}  :
                     (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_PUSH) ? {2'h0, `FS_PUSH} :
                     (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_CALL) ? {2'h0, `FS_CALL} :
                     (FORMAT == FMT_II) && (INSTR_REG[15:7]  == `OP_RETI) ? {2'h2, `FS_RETI} :
                     (FORMAT == FMT_J)                     ? {5'b0,INSTR_REG[12:10]} : 'bx;
   
               

   assign FORMAT = (INSTR_REG[15:13] == `OP_JUMP) ? FMT_J  :
                   (INSTR_REG[15:12] == 4'b0001)  ? FMT_II :
                   (INSTR_REG[15:12] >= 4'b0100)  ? FMT_I  : 0;
   
   assign BW = (FORMAT <= FMT_II) ? INSTR_REG[6] : 0;

   // assign RW = pre_RW && (~AdAs[2]) && ~((~CALC_done && MC) && (FAIL_COND1 || FAIL_COND2)) ? 1 : 0;
   assign RW = pre_RW && (~MW) && ~((~CALC_done && MC) && (FAIL_COND1 || FAIL_COND2)) ? 1 : 0;

   always @ (negedge clk)
     begin
        INSTR_LAST <= INSTR_REG;
        MAB_last <= MAB_in;
        MAB_IMM_last <= MAB_IMM;
        ram_write_done_sync <= ram_write_done;

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
             // If we are in indirect auto-increment mode, enter the state machine
             if (&AdAs[1:0])
               begin
                  // First check if the increment is finished
                  // INCR_done <= (RW && (&AdAs[1:0]) && (reg_SA == reg_DA)) ? 1 : 0;
                  if (RW_last && (reg_SA_last == reg_DA_last))
                    // Wait one more
                    INSTR_REG <= INSTR_REG;
                  else
                    INSTR_REG <= MDB_out;
               end
             // else INSTR_REG <= INSTR_REG;
             else if (AdAs[1])
               begin
                  FAIL_COND_done <= 1;
                  INSTR_REG <= INSTR_REG;
               end
             else
               INSTR_REG <= INSTR_REG;
          end  
     end // always @ (negedge clk)

endmodule
