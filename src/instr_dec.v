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
  (input            clk,
   input [15:0]     MDB_out,
   input [15:0]     MAB_in,
   input [15:0]     reg_PC_out,
   input            CALC_done,
   output [2:0]     MAB_sel,
   output           MDB_sel,
   output reg [1:0] FORMAT,
   output reg [5:0] FS,
   output reg       BW,
   output           RW,
   output           MW,
   output           MA, MB,
   output reg [3:0] reg_SA, reg_DA,
   output reg [2:0] AdAs, 
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
     MAB_PC   = 0, MAB_MDB  = 1, MAB_CALC = 2,
     MAB_Sout = 3, MAB_Dout = 4, MAB_SP   = 5;


   // Registers
   reg [15:0]       MDB_instruction;
   reg [15:0]       MDB_last;
   reg              pre_RW;
   
   
   // Initialize registers
   initial
     begin
        MDB_last    <= 0;
        FORMAT      <= 0;
        {reg_SA,
         reg_DA}    <= 0; 
        AdAs        <= 0;        
        BW         <= 0;
        FS         <= 0;
        MDB_instruction <= 0;
        pre_RW <= 0;
     end // initial begin
   

   // Wires
   // wire [15:0] INSTRUCTION;
   wire        USING_CONST_GEN;
   wire        PASSING_INSTR;
   
   wire [3:0]  reg_SA_prelatch, reg_DA_prelatch;

   assign PASSING_INSTR = (MAB_in == reg_PC_out) ? 1 : 0;
   // FORMAT: 1 = Format 1, 2 = Format 2, 3 = Jump, X = Unknown
   // assign FORMAT_ASYNC = (MDB_instruction[15:13] == `OP_JUMP) ? FMT_J  :
   //                       (MDB_instruction[15:12] == 4'b0001)  ? FMT_II :
   //                       (MDB_instruction[15:12] >= 4'b0100)  ? FMT_I  : 2'bx;

   assign USING_CONST_GEN = ((FORMAT == FMT_I)  && (MDB_instruction[11:8] == 3)) ||
                            ((FORMAT == FMT_II) && (MDB_instruction[3:0]  == 3)) ? 1'b1 : 0;

   // Extract SA from instruction
   assign reg_SA_prelatch = (FORMAT == FMT_I)  ? MDB_instruction[11:8] : 
                            (FORMAT == FMT_II) ? MDB_instruction[3:0]  : 4'bx;

   assign reg_DA_prelatch = (FORMAT <= FMT_II) ? MDB_instruction[3:0]  : 4'bx;

   // assign MAB_sel = 
   //                  (AdAs_KNOWN == 3'b001) && (count >= 1) ? 2 :
   //                  (AdAs_KNOWN == 3'b010) && (count == 1) ? 3 :
   //                  (AdAs_KNOWN == 3'b011) && (count == 1) ? 3 : 0;

   assign MC = AdAs[2] || (AdAs[1:0] == 2'b01) ? 1 : 0;

   // MUX sel for MAB
   assign MAB_sel = (AdAs == 3'b000) || (AdAs[2]) || (AdAs[1:0] == 2'b01) ? MAB_PC :
                    // Indirect register/autoincrement mode
                    MC ? MAB_CALC : MAB_PC;

   // assign MA = ((&AdAs_KNOWN[1:0])
   //              && ~PASS_INSTR 
   //              && (MDB_out != INSTRUCTION_KNOWN))? 1 : 0;
   // assign MB = (AdAs_KNOWN[2]) ? 2 : 0;

   // assign RW = (pre_RW && )

   assign MW = AdAs[2] ? 1 : 0;
   assign MDB_sel = MW && ~PASSING_INSTR ? 1 : 0;

   // MUX A determines what goes into the A side of the function unit
   assign MA = !AdAs[1:0] ? 2'h0 : // Register mode
               ~PASSING_INSTR && (AdAs == 3'b001) ? 2'h1 :
               ~PASSING_INSTR && (AdAs == 3'b101) ? 2'h2 :
               
               // Anything else uses MDB eventually
               // |AdAs[1:0] ? 1'b1 : 1'b0;

   assign MB = ~AdAs[2]   ? 1'b0 :
               AdAs[2]    ? 1'b1 : 1'b0;

   // How do we get it to pause for a cycle to do the increment on
   // indirect register/autoincrement modes? The instruction length
   // is just 1, so it wants to pass the next instruction right away.
   // We need to hold MPC until we're ready.

   // Does this need to be two bits? I can't remember why it has a shifter
   assign MPC = 
                !AdAs || (AdAs[1:0] == 2'b01) ? 2'h1 : // Register/Indexed
                AdAs[1]                       ? 2'h0 : // Indirect reg/auto
                2'h1;
   

   // How am I gonna get it to work for immediate?
   assign MD = (~AdAs[1]) || (AdAs[1:0] == 2'b10) ? 2'h0 :
               // Indirect auto and we're holding the PC
               (AdAs[1:0] == 2'b11) && !MPC       ? 2'h2 : 2'h0;
   
   
      // 0 = F_OUT, 1 = MDB, 2 = CALC
   // assign MD = (AdAs_KNOWN == 3'b001) ? 1 :
   //             (AdAs_KNOWN == 3'b000) && (count == 0) ? 0 :
   //             (&AdAs_KNOWN[1:0])     && (MDB_out != INSTRUCTION_KNOWN) ? 0 : 
   //             (AdAs_KNOWN == 3'b001) && (count == 2) ? 2 : 'bx;


   // Latch outputs
   always @ (negedge clk)
     begin
        // Latch MDB
        MDB_last <= MDB_out;

        // Latch the last instruction
        MDB_instruction <= (PASSING_INSTR) ? MDB_out : MDB_instruction;
        
        // Do the reg_SA latches
        reg_SA <= (PASSING_INSTR) ? reg_SA_prelatch : reg_SA;
        reg_DA <= (PASSING_INSTR) ? reg_DA_prelatch : reg_DA;
        
        // Latch format of instruction
        FORMAT <= (MDB_instruction[15:13] == `OP_JUMP) ? FMT_J  :
                  (MDB_instruction[15:12] == 4'b0001)  ? FMT_II :
                  (MDB_instruction[15:12] >= 4'b0100)  ? FMT_I  : 2'bx;

        // Latch Ad/As
        AdAs <= (PASSING_INSTR && (FORMAT == FMT_I))  ? {MDB_instruction[7],MDB_instruction[5:4]} :
                (PASSING_INSTR && (FORMAT == FMT_II)) ? {1'bx,MDB_instruction[5:4]}           : AdAs;
        
        
        // Latch BW
        BW <= (FORMAT <= FMT_II) ? INSTRUCTION[6] : BW;
        
        // And now to determine FS code... First, what format is this in?
        if (PASSING_INSTR)
          case (FORMAT)
            // For FMT I, check these bits
            FMT_I:
              case (INSTRUCTION[15:12])
                `OP_MOV:     {pre_RW,FS} <= {1'b1,`FS_MOV};
                `OP_ADD:     {pre_RW,FS} <= {1'b1,`FS_ADD};
                `OP_ADDC:    {pre_RW,FS} <= {1'b1,`FS_ADDC};
                `OP_SUBC:    {pre_RW,FS} <= {1'b1,`FS_SUBC};
                `OP_SUB:     {pre_RW,FS} <= {1'b1,`FS_SUB};
                `OP_CMP:     {pre_RW,FS} <= {1'b0,`FS_CMP};
                `OP_DADD:    {pre_RW,FS} <= {1'b1,`FS_DADD};
                `OP_BIT:     {pre_RW,FS} <= {1'b0,`FS_BIT};
                `OP_BIC:     {pre_RW,FS} <= {1'b1,`FS_BIC};
                `OP_BIS:     {pre_RW,FS} <= {1'b1,`FS_BIS};
                `OP_XOR:     {pre_RW,FS} <= {1'b1,`FS_XOR}; 
                `OP_AND:     {pre_RW,FS} <= {1'b1,`FS_AND};
                default:     {pre_RW,FS} <= {1'b0,FS}; // If it is not a valid op, just clear out
              endcase // case (INSTRUCTION[15:12])

            // For FMT II, check these bits
            FMT_II:
              case (INSTRUCTION[15:7])
                `OP_RRC:     {pre_RW,FS} <= {1'b1,`FS_RRC};//1
                `OP_SWPB:    {pre_RW,FS} <= {1'b1,`FS_SWPB};//0
                `OP_RRA:     {pre_RW,FS} <= {1'b1,`FS_RRA};//1
                `OP_SXT:     {pre_RW,FS} <= {1'b1,`FS_SXT};//1
                `OP_PUSH:    {pre_RW,FS} <= {1'b1,`FS_PUSH};//0
                `OP_CALL:    {pre_RW,FS} <= {1'b1,`FS_CALL};//0
                `OP_RETI:    {pre_RW,FS} <= {1'b1,`FS_RETI};//1
                default:     {pre_RW,FS} <= {1'b0,FS};
              endcase // case (INSTRUCTION[15:7])

            // For jumps, just pass the opcode + C through the FS port
            FMT_J:           {pre_RW,FS} <= {4'b0,MDB_instruction[12:10]};
            default:         {pre_RW,FS} <= {1'b0,FS};
          endcase // case (FORMAT)
        else // if NOT passing instruction
          {pre_RW,FS} <= {pre_RW,FS} // Latch pre_RW and FS

     end // always @ (negedge clk)

   // Determines instruction length
   // always @ (negedge clk)
   //   begin
   //      if (!count)
   //        begin
   //           PASS_INSTR <= 1;
   //           // Tell PC to go to next PC on the next clock tick
   //           MPC <= 1;
   //           // Is this a jump?
   //           if (FORMAT == FMT_J)
   //             // If so, set PC to shift the offset
   //             MPC <= 3;
   //           // Otherwise, is it one of the other two valid formats?
   //           else if (FORMAT_ASYNC == FMT_I || FORMAT_ASYNC == FMT_II)
   //             casex (INSTRUCTION[5:4])
   //               // REGISTER MODE (00)
   //               2'b00:
   //                 //  1 (for dst X)
   //                 // +1 (for mem access X+Rm)
   //                 // ---
   //                 //  2 total
   //                 if ((FORMAT_ASYNC == FMT_I) && INSTRUCTION[7])
   //                   begin
   //                      count <= 2;
   //                      PASS_INSTR <= 0;
   //                   end  
   //                 else
   //                   count <= 0;

   //               // INDEXED MODE (01)
   //               2'b01:
   //                 //  1 (for src X)
   //                 // +1 (for mem access X+Rn)
   //                 // +1 (for dst X)
   //                 // +1 (for mem access X+Rm)
   //                 // ---
   //                 // 4 total
   //                 if ((FORMAT_ASYNC == FMT_I) && INSTRUCTION[7])
   //                   begin
   //                      count <= (USING_CONST_GEN) ? 2 : 4;
   //                      PASS_INSTR <= 0;
   //                   end  
   //                 else
   //                   if (USING_CONST_GEN)
   //                     count <= 0;
   //                   else
   //                     begin
   //                        count <= 2;
   //                        PASS_INSTR <= 0;
   //                     end  
   
   //               // INDIRECT REGISTER MODE (10)
   //               2'b10:
   //                 // Check if dst is indexed
   //                 //  1 (for mem access Rn)
   //                 // +1 (for dst X)
   //                 // +1 (for mem access X+Rm)
   //                 // ---
   //                 //  3 total
   //                 if ((FORMAT_ASYNC == FMT_I) && INSTRUCTION[7])
   //                   begin
   //                      count <= (INSTRUCTION[7] & ~USING_CONST_GEN) ? 3 : 
   //                               (USING_CONST_GEN)                   ? 0 : 1;
   //                      PASS_INSTR <= (INSTRUCTION[7] & ~USING_CONST_GEN) ? 0 :
   //                                    (USING_CONST_GEN)                   ? 1 : 0;
   //                   end  
   //                 else
   //                   begin
   //                      count <= 1;
   //                      PASS_INSTR <= 0;
   //                   end  

   //               // INDIRECT AUTOINCREMENT MODE (11)
   //               2'b11:
   //                 // If As = 11, then it's either immediate or indirect
   //                 // autoincrement. The only difference is the source
   //                 // register. So check if there is anything there.
   //                 // We have to do this because immediate mode contains
   //                 // an extra word in ROM for the constant.
   //                 if ((FORMAT_ASYNC == FMT_I) && !INSTRUCTION[11:8])
   //                   // If the dst mode is indexed and it isn't using the constant
   //                   // generator, add an extra one to the count. Otherwise, if it's
   //                   // using the constant generator, keep it 0 and otherwise keep it 

   //                   //  1 for mem access Rn
   //                   // +1 for dst X
   //                   // +1 for mem access X+Rm
   //                   // ---
   //                   //  3 for total count
   //                   begin
   //                      count <= (INSTRUCTION[7] & ~USING_CONST_GEN) ? 3 : 
   //                               (USING_CONST_GEN)                   ? 0 : 1;
   //                      PASS_INSTR <= (INSTRUCTION[7] & ~USING_CONST_GEN) ? 0 :
   //                                    (USING_CONST_GEN)                   ? 1 : 0;
   //                   end  
   //               // Check if it's immediate in other format
   //                 else if ((FORMAT_ASYNC == FMT_II) && !INSTRUCTION[3:0])
   //                   begin
   //                      count <= 2;
   //                      PASS_INSTR <= 0;
   //                   end  
   //               // Otherwise, just add 1 for the memory access
   //                 else
   //                   begin
   //                      count <= 1;
   //                      PASS_INSTR <= 0;
   //                   end  
   
   //               default: count <= 0;
   //             endcase // casex (INSTRUCTION[5:4])
   //        end // if (~start)
   //      else
   //        begin
   //           // Set PC and SR to hold value
   //           // {MPC,MSR} <= 0;
   //           // Don't decrement if instruction hasn't changed
   //           if (MDB_out == MDB_last)
   //             count <= count;
   //           // Decrement counter of instruction length
   //           else if (count)
   //             // count <= count - 1;
   //             count <= count - 1;
   //        end  
   //   end // always @ (negedge clk)

endmodule
