/*
 Instruction Decoder
 ~~~~~~~~~~~~~~~~~~~
 Decodes the instructions coming off the MDB from ROM. First
 determines how many instructions to expect, then counts until that
 number of instructions has passed.
 TODO:
   x LATCH ALL THE OUTPUTS
   x DECODE OP CODES TO FS CODES
   x MAKE SURE STATUS BITS ARE ONLY AFFECTED WHEN THEY SHOULD BE
 
 Notes:
   - Right now it sets PC to hold when instruction is not an 
     instruction, so that it way it doesn't pass over the 
     instruction before the register file receives it on the Din. 
     When is it supposed to tell PC to continue? How?
*/
`include "msp430_ops.vh"
module instr_dec
  (input            clk,
   input [15:0]     MDB_out,
   output [2:0]     MAB_SEL,
   output reg [1:0] FORMAT,
   output reg [5:0] FS,
   output reg       BW,
   output           RW,
   output [1:0]     MA, MB,
   output [3:0]     reg_SA, reg_DA,
   output reg [2:0] AdAs, 
   output [1:0]     MD,
   output reg [2:0] MC,
   output reg [2:0] MPC, 
   output reg [1:0] MSP, 
   output reg       MSR);
   // MPC - Select bit for MUX PC
   // MSP - Select bit for MUX SP
   // MSR - Select bit for MUX SR

   localparam FMT_I = 1, FMT_II = 2, FMT_J = 3;

   // Registers
   reg              RW_prelatch;
   reg              RW_latch1, 
                    RW_latch2, 
                    RW_latch3,
                    RW_latch4,
                    RW_latch5,
                    RW_latch6;
   reg [3:0]        reg_SA_prelatch;
   reg [3:0]        reg_SA_latch1, 
                    reg_SA_latch2, 
                    reg_SA_latch3,
                    reg_SA_latch4,
                    reg_SA_latch5,
                    reg_SA_latch6;
   reg [3:0]        reg_DA_prelatch;
   reg [3:0]        reg_DA_latch1, 
                    reg_DA_latch2, 
                    reg_DA_latch3,
                    reg_DA_latch4,
                    reg_DA_latch5,
                    reg_DA_latch6;
   reg [15:0]       MDB_last;
   // reg [15:0]       INSTRUCTION_LAST_KNOWN;
   reg [2:0]        MMC;        // Selector for MC
   reg              PASSING_INSTR;
   
   reg [2:0]        count;      // Counter for words in instruction
                                // +1 for each memory access using
                                // that word

   // Initialize registers
   initial
     begin
        {RW_prelatch,
         RW_latch1,
         RW_latch2,
         RW_latch3,
         RW_latch4,
         RW_latch5,
         RW_latch6} <= 0;
        {reg_SA_prelatch,
         reg_SA_latch1,
         reg_SA_latch2,
         reg_SA_latch3,
         reg_SA_latch4,
         reg_SA_latch5,
         reg_SA_latch6} <= 0;
        {reg_DA_prelatch,
         reg_DA_latch1,
         reg_DA_latch2,
         reg_DA_latch3,
         reg_DA_latch4,
         reg_DA_latch5,
         reg_DA_latch6} <= 0;
        MDB_last    <= 0;
        FORMAT      <= 0;
        // {reg_SA,
        //  reg_DA}    <= 0; 
        AdAs        <= 0;        
        MPC         <= 1;
        {MSP,
         MSR,
         MMC,
         MC}       <= 0;
        BW         <= 0;
        FS         <= 0;
        count      <= 0;
        PASSING_INSTR
                   <= 0;
        // INSTRUCTION_LAST_KNOWN
                   // <= 0;
        
     end

   // Wires
   wire [15:0]      INSTRUCTION, INSTRUCTION_LAST_KNOWN;
   wire [1:0]       FORMAT_ASYNC, FORMAT_KNOWN;
   wire [2:0]       AdAs_ASYNC, AdAs_KNOWN;
   wire             USING_CONST_GEN;
   
   assign INSTRUCTION = (PASSING_INSTR) ? MDB_out : 16'bx;
   // FORMAT: 1 = Format 1, 2 = Format 2, 3 = Jump, X = Unknown
   assign FORMAT_ASYNC = (INSTRUCTION[15:13] == `OP_JUMP) ? FMT_J  :
                         (INSTRUCTION[15:12] == 4'b0001)  ? FMT_II :
                         (INSTRUCTION[15:12] >= 4'b0100)  ? FMT_I  : 2'bx;

   assign FORMAT_KNOWN = (INSTRUCTION_LAST_KNOWN[15:13] == `OP_JUMP) ? FMT_J  :
                              (INSTRUCTION_LAST_KNOWN[15:12] == 4'b0001)  ? FMT_II :
                              (INSTRUCTION_LAST_KNOWN[15:12] >= 4'b0100)  ? FMT_I  : 2'bx;

   assign AdAs_ASYNC[2]   = (FORMAT_ASYNC == FMT_I)  ? INSTRUCTION[7]   : 1'bx;
   assign AdAs_ASYNC[1:0] = (FORMAT_ASYNC <= FMT_II) ? INSTRUCTION[5:4] : 4'bx;

   assign AdAs_KNOWN = (AdAs_ASYNC === 3'bx) ? AdAs : AdAs_ASYNC;
   assign INSTRUCTION_LAST_KNOWN = (INSTRUCTION === 16'bx) ? INSTRUCTION_LAST_KNOWN : INSTRUCTION;
   

   assign USING_CONST_GEN = ((FORMAT_ASYNC == FMT_I)  && (INSTRUCTION[11:8] == 3)) ||
                            ((FORMAT_ASYNC == FMT_II) && (INSTRUCTION[3:0]  == 3)) ? 1'b1 : 0;

   // assign INDEXED_DST = (FORMAT_KNOWN == FMT_I) && (INSTRUCTION_LAST_KNOWN[7]) ? 1 : 0;
   
   assign RW = (AdAs_KNOWN == 3'b000) ? RW_prelatch :
               (AdAs_KNOWN == 3'b001) ? RW_latch3   :
               (AdAs_KNOWN == 3'b010) ? RW_latch2   :
               (AdAs_KNOWN == 3'b011) ? RW_latch2   :
               (AdAs_KNOWN == 3'b100) ? RW_latch4   :
               (AdAs_KNOWN == 3'b101) ? RW_latch6   :
               (AdAs_KNOWN == 3'b110) ? RW_latch5   :
               (AdAs_KNOWN == 3'b111) ? RW_latch5   : RW_prelatch;
   
   assign reg_SA = (AdAs_KNOWN == 3'b000) ? reg_SA_prelatch :
                   (AdAs_KNOWN == 3'b001) ? reg_SA_latch3   :
                   (AdAs_KNOWN == 3'b010) ? reg_SA_latch2   :
                   (AdAs_KNOWN == 3'b011)
                     && (FORMAT_KNOWN == FMT_I)
                       && (!INSTRUCTION_LAST_KNOWN[11:8]) 
                                          ? reg_SA_latch3   :
                   (AdAs_KNOWN == 3'b011) ? reg_SA_latch2   :
                   (AdAs_KNOWN == 3'b100) ? reg_SA_latch4   :
                   (AdAs_KNOWN == 3'b101) ? reg_SA_latch6   :
                   (AdAs_KNOWN == 3'b110) ? reg_SA_latch5   :
                   (AdAs_KNOWN == 3'b111) ? reg_SA_latch5   : reg_SA_prelatch;
   
   assign reg_DA = (AdAs_KNOWN == 3'b000) ? reg_DA_prelatch :
                   (AdAs_KNOWN == 3'b001) ? reg_DA_latch3   :
                   (AdAs_KNOWN == 3'b010) ? reg_DA_latch2   :
                   (AdAs_KNOWN == 3'b011) ? reg_DA_latch1   :
                   (AdAs_KNOWN == 3'b100) ? reg_DA_latch4   :
                   (AdAs_KNOWN == 3'b101) ? reg_DA_latch6   :
                   (AdAs_KNOWN == 3'b110) ? reg_DA_latch5   :
                   (AdAs_KNOWN == 3'b111) ? reg_DA_latch5   : reg_DA_prelatch;
   
   assign MAB_SEL = (count == 0)                           ? 0 :
                    (AdAs_KNOWN == 3'b001) && (count == 2) ? 2 :
                    (AdAs_KNOWN == 3'b010) && (count == 1) ? 3 :
                    (AdAs_KNOWN == 3'b011) && (count == 1) ? 3 : 'bx;

   assign MA = ((&AdAs_KNOWN[1:0])
                && ~PASSING_INSTR 
                && (MDB_out != INSTRUCTION_LAST_KNOWN))? 1 : 0;
   assign MB = (AdAs_KNOWN[2]) ? 2 : 0;
   

   // 0 = F_OUT, 1 = MDB, 2 = CALC
   assign MD = (AdAs_KNOWN == 3'b000) && (count == 0) ? 0 :
               (&AdAs_KNOWN[1:0])     && (MDB_out != INSTRUCTION_LAST_KNOWN) ? 0 : 
               (AdAs_KNOWN == 3'b001) && (count == 2) ? 2 : 'bx;

   // Latch outputs
   always @ (negedge clk)
     begin
        // Latch MDB
        MDB_last <= MDB_out;
        
        // Do the RW latches
        RW_latch1 <= (RW_prelatch === 1'bx) ? 0 : RW_prelatch;
        RW_latch2 <= RW_latch1;
        RW_latch3 <= RW_latch2;
        RW_latch4 <= RW_latch3;
        RW_latch5 <= RW_latch4;
        RW_latch6 <= RW_latch5;

        // Do the reg_SA latches
        reg_SA_latch1 <= reg_SA_prelatch;
        reg_SA_latch2 <= reg_SA_latch1;
        reg_SA_latch3 <= reg_SA_latch2;
        reg_SA_latch4 <= reg_SA_latch3;
        reg_SA_latch5 <= reg_SA_latch4;
        reg_SA_latch6 <= reg_SA_latch5;

        // Do the reg_DA latches
        reg_DA_latch1 <= reg_DA_prelatch;
        reg_DA_latch2 <= reg_DA_latch1;
        reg_DA_latch3 <= reg_DA_latch2;
        reg_DA_latch4 <= reg_DA_latch3;
        reg_DA_latch5 <= reg_DA_latch4;
        reg_DA_latch6 <= reg_DA_latch5;

        // Latch last known instruction
        // INSTRUCTION_LAST_KNOWN <= (INSTRUCTION === 'bx) ? INSTRUCTION_LAST_KNOWN : INSTRUCTION;
        
        // Latch format of instruction
        FORMAT <= (count > 0)                      ? FORMAT :
                  (INSTRUCTION[15:13] == `OP_JUMP) ? FMT_J  :
                  (INSTRUCTION[15:12] == 4'b0001)  ? FMT_II :
                  (INSTRUCTION[15:12] >= 4'b0100)  ? FMT_I  : 2'bx;

        // Latch SA/DA
        // reg_SA_prelatch <= (count > 0)                      ? reg_SA_prelatch :
        //                    (FORMAT_ASYNC == FMT_I)          ? INSTRUCTION[11:8] : 4'bx;
        reg_DA_prelatch <= (FORMAT_ASYNC <= FMT_II)         ? INSTRUCTION[3:0]  :
                           (count == 3) && (&AdAs)          ? reg_SA_prelatch            :
                           (&AdAs_KNOWN[1:0])               ? reg_DA_prelatch            :
                           (count > 0)                      ? reg_DA_prelatch            : 4'bx;

        reg_SA_prelatch <= ~(PASSING_INSTR)                    ? reg_SA_prelatch   :
                           (FORMAT_ASYNC == FMT_I)             ? INSTRUCTION[11:8] : 4'bx;

        // Latch Ad/As
        AdAs    <= (count)                  ? AdAs                              :
                   (FORMAT_ASYNC == FMT_I)  ? {INSTRUCTION[7],INSTRUCTION[5:4]} :
                   (FORMAT_ASYNC == FMT_II) ? {1'bx,INSTRUCTION[5:4]}           : 3'bx;
        
        // Latch BW
        BW <= (FORMAT_ASYNC <= FMT_II) ? INSTRUCTION[6] : 1'bx;        

        // And now to determine FS code... First, what format is this in?
        case (FORMAT_ASYNC)
          // For FMT I, check these bits
          FMT_I:
            case (INSTRUCTION[15:12])
              `OP_MOV:     {RW_prelatch,MSR,FS} <= {1'b1,1'b0,`FS_MOV};
              `OP_ADD:     {RW_prelatch,MSR,FS} <= {1'b1,1'b1,`FS_ADD};
              `OP_ADDC:    {RW_prelatch,MSR,FS} <= {1'b1,1'b1,`FS_ADDC};
              `OP_SUBC:    {RW_prelatch,MSR,FS} <= {1'b1,1'b1,`FS_SUBC};
              `OP_SUB:     {RW_prelatch,MSR,FS} <= {1'b1,1'b1,`FS_SUB};
              `OP_CMP:     {RW_prelatch,MSR,FS} <= {1'b0,1'b1,`FS_CMP};
              `OP_DADD:    {RW_prelatch,MSR,FS} <= {1'b1,1'b1,`FS_DADD};
              `OP_BIT:     {RW_prelatch,MSR,FS} <= {1'b0,1'b1,`FS_BIT};
              `OP_BIC:     {RW_prelatch,MSR,FS} <= {1'b1,1'b0,`FS_BIC};
              `OP_BIS:     {RW_prelatch,MSR,FS} <= {1'b1,1'b0,`FS_BIS};
              `OP_XOR:     {RW_prelatch,MSR,FS} <= {1'b1,1'b1,`FS_XOR}; 
              `OP_AND:     {RW_prelatch,MSR,FS} <= {1'b1,1'b1,`FS_AND};
              default:     {RW_prelatch,MSR,FS} <= {RW_prelatch,MSR,FS}; // If it is not a valid op, just clear out
            endcase // case (INSTRUCTION[15:12])

          // For FMT II, check these bits
          FMT_II:
            case (INSTRUCTION[15:7])
              `OP_RRC:     {RW_prelatch,MSR,FS} <= {1'b1,1'b1,`FS_RRC};
              `OP_SWPB:    {RW_prelatch,MSR,FS} <= {1'b1,1'b0,`FS_SWPB};
              `OP_RRA:     {RW_prelatch,MSR,FS} <= {1'b1,1'b1,`FS_RRA};
              `OP_SXT:     {RW_prelatch,MSR,FS} <= {1'b1,1'b1,`FS_SXT};
              `OP_PUSH:    {RW_prelatch,MSR,FS} <= {1'b1,1'b0,`FS_PUSH};
              `OP_CALL:    {RW_prelatch,MSR,FS} <= {1'b1,1'b0,`FS_CALL};
              `OP_RETI:    {RW_prelatch,MSR,FS} <= {1'b1,1'b1,`FS_RETI};
              default:     {RW_prelatch,MSR,FS} <= {RW_prelatch,MSR,FS};
            endcase // case (INSTRUCTION[15:7])

          // For jumps, just pass the opcode + C through the FS port
          FMT_J:           {RW_prelatch,MSR,FS} <= {4'b0,1'b0,INSTRUCTION[12:10]};
          default:         {RW_prelatch,MSR,FS} <= {RW_prelatch,MSR,FS};
        endcase
     end  


   // Determines instruction length
   always @ (negedge clk)
     begin
        if (!count)
          begin
             PASSING_INSTR <= 1;
             // Tell PC to go to next PC on the next clock tick
             MPC <= 1;
             // Is this a jump?
             if (FORMAT == FMT_J)
               // If so, set PC to shift the offset
               MPC <= 3;
             // Otherwise, is it one of the other two valid formats?
             else if (FORMAT_ASYNC == FMT_I || FORMAT_ASYNC == FMT_II)
                casex (INSTRUCTION[5:4])
                  // REGISTER MODE (00)
                  2'b00:
                    //  1 (for dst X)
                    // +1 (for mem access X+Rm)
                    // ---
                    //  2 total
                    if ((FORMAT_ASYNC == FMT_I) && INSTRUCTION[7])
                      begin
                         count <= 2;
                         PASSING_INSTR <= 0;
                      end  
                    else
                      count <= 0;

                  // INDEXED MODE (01)
                  2'b01:
                    //  1 (for src X)
                    // +1 (for mem access X+Rn)
                    // +1 (for dst X)
                    // +1 (for mem access X+Rm)
                    // ---
                    // 4 total
                    if ((FORMAT_ASYNC == FMT_I) && INSTRUCTION[7])
                      begin
                         count <= (USING_CONST_GEN) ? 2 : 4;
                         PASSING_INSTR <= 0;
                      end  
                    else
                      if (USING_CONST_GEN)
                        count <= 0;
                      else
                        begin
                           count <= 2;
                           PASSING_INSTR <= 0;
                        end  
                    
                  // INDIRECT REGISTER MODE (10)
                  2'b10:
                    // Check if dst is indexed
                    //  1 (for mem access Rn)
                    // +1 (for dst X)
                    // +1 (for mem access X+Rm)
                    // ---
                    //  3 total
                    if ((FORMAT_ASYNC == FMT_I) && INSTRUCTION[7])
                      begin
                         count <= (INSTRUCTION[7] & ~USING_CONST_GEN) ? 3 : 
                                  (USING_CONST_GEN)                   ? 0 : 1;
                         PASSING_INSTR <= (INSTRUCTION[7] & ~USING_CONST_GEN) ? 0 :
                                          (USING_CONST_GEN)                   ? 1 : 0;
                      end  
                    else
                      begin
                         count <= 1;
                         PASSING_INSTR <= 0;
                      end  

                  // INDIRECT AUTOINCREMENT MODE (11)
                  2'b11:
                    // If As = 11, then it's either immediate or indirect
                    // autoincrement. The only difference is the source
                    // register. So check if there is anything there.
                    // We have to do this because immediate mode contains
                    // an extra word in ROM for the constant.
                    if ((FORMAT_ASYNC == FMT_I) && !INSTRUCTION[11:8])
                      // If the dst mode is indexed and it isn't using the constant
                      // generator, add an extra one to the count. Otherwise, if it's
                      // using the constant generator, keep it 0 and otherwise keep it 

                      //  1 for mem access Rn
                      // +1 for dst X
                      // +1 for mem access X+Rm
                      // ---
                      //  3 for total count
                      begin
                         count <= (INSTRUCTION[7] & ~USING_CONST_GEN) ? 3 : 
                                  (USING_CONST_GEN)                   ? 0 : 1;
                         PASSING_INSTR <= (INSTRUCTION[7] & ~USING_CONST_GEN) ? 0 :
                                          (USING_CONST_GEN)                   ? 1 : 0;
                      end  
                    // Check if it's immediate in other format
                    else if ((FORMAT_ASYNC == FMT_II) && !INSTRUCTION[3:0])
                      begin
                         count <= 2;
                         PASSING_INSTR <= 0;
                      end  
                    // Otherwise, just add 1 for the memory access
                    else
                      begin
                         count <= 1;
                         PASSING_INSTR <= 0;
                      end  
                  
                  default: count <= 0;
                endcase // casex (INSTRUCTION[5:4])
          end // if (~start)
        else
          begin
             // Set PC and SR to hold value
             // {MPC,MSR} <= 0;
             case(AdAs)
               3'b001: MC <= 2;
               3'b011: MC <= 1;
               3'b100: MC <= 3;
               3'b101:
                 // Sout_last + MDB_out
                 if (count == 4)
                   MC <= 2;
                 // Dout_last2 + MDB_out
                 else if (count == 2)
                   MC <= 4;
                 else
                   MC <= 0;
               3'b111:
                 if (count == 3)
                   MC <= 1;
                 // Dout_last2 + MDB_out
                 else if (count == 2)
                   MC <= 4;
                 else
                   MC <= 0;
               default: MC <= 0;
             endcase // case (AdAs)

             
             // Don't decrement if instruction hasn't changed
             if (MDB_out == MDB_last)
               count <= count;
             // Decrement counter of instruction length
             else if (count)
               count <= count - 1;
          end  
     end // always @ (negedge clk)

endmodule
