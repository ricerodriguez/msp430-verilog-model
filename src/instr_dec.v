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
   output [1:0]     MAB_SEL,
   output reg [1:0] FORMAT,
   output reg [5:0] FS,
   output reg       BW,
   output reg       RW,
   output reg [3:0] reg_SA, reg_DA,
   output reg [2:0] AdAs, 
   output [1:0]     MD,
   output reg [2:0] MPC, 
   output reg [1:0] MSP, 
   output reg       MSR);
   // MPC - Select bit for MUX PC
   // MSP - Select bit for MUX SP
   // MSR - Select bit for MUX SR

   localparam FMT_I = 1, FMT_II = 2, FMT_J = 3;

   // Registers
   reg [2:0]        count;   // Counts words in instructions
   reg [2:0]        count_cycles;
   // reg              RW_prelatch;
   
   // Initialize registers
   initial
     begin
        RW <= 0;
        // RW_prelatch <= 0;
        BW <= 0;
        FS <= 0;
        FORMAT <= 0;
        reg_SA <= 0;
        reg_DA <= 0; 
        AdAs <= 0;        
        MPC <= 1;
        MSP <= 0;
        MSR <= 0;        
        count <= 0;
        count_cycles <= 0;
     end

   // Wires
   wire [15:0]      INSTRUCTION;
   wire [1:0]       FORMAT_ASYNC;
   wire [2:0]       AdAs_ASYNC;
   wire             USING_CONST_GEN;
   // wire             INDIRECT_AUTOINC;   

   // Assign wires
   assign INSTRUCTION = (!count) ? MDB_out : 16'bx;
   // FORMAT: 1 = Format 1, 2 = Format 2, 3 = Jump, X = Unknown
   assign FORMAT_ASYNC = (INSTRUCTION[15:13] == `OP_JUMP) ? FMT_J  :
                         (INSTRUCTION[15:12] == 4'b0001)  ? FMT_II :
                         (INSTRUCTION[15:12] >= 4'b0100)  ? FMT_I  : 2'bx;

   assign AdAs_ASYNC[2]   = (FORMAT_ASYNC == FMT_I)  ? INSTRUCTION[7]   : 1'bx;
   assign AdAs_ASYNC[1:0] = (FORMAT_ASYNC <= FMT_II) ? INSTRUCTION[5:4] : 4'bx;

   assign USING_CONST_GEN = ((FORMAT_ASYNC == FMT_I)  && (INSTRUCTION[11:8] == 3)) ||
                            ((FORMAT_ASYNC == FMT_II) && (INSTRUCTION[3:0]  == 3)) ? 1'b1 : 0;

   // Indirect autoincrement mode is only valid for source operand. If it's using the single 
   // operand instruction, it's only valid if the single operand is the source operand. This is 
   // only true for PUSH
   // assign INDIRECT_AUTOINC = (FORMAT_ASYNC == FMT_I)  && (&AdAs[1:0])                  ? 1 :
   //                           (FORMAT_ASYNC == FMT_II) && (&AdAs[1:0])
   //                                                    && INSTRUCTION[15:7] == `OP_PUSH ? 1 : 0;

   // If we're not counting, proceed as normal and use PC.
   // If one of the operands is using indexed, use output of CALC
   // If the source operand is using indirect register mode, use Sout
   assign MAB_SEL = !count && !AdAs_ASYNC            ? 0 :
                    AdAs[2] || AdAs[1:0]             ? 1 :
                    AdAs[1:0] == 2'b10               ? 2 : 0;
   // assign MAB_SEL = 0;
   

   // If this is an instruction and it's register mode, use F_OUT
   // If this is 
   // If this is an instruction and it's indirect autoincrement mode, use Sout+1
   assign MD = (!count && !AdAs_ASYNC)               ? 0 :
               (count > 0) && (AdAs[1:0] == 2'b10)   ? 1 :
               (count > 0) && (&AdAs[1:0])           ? 2 : 'bx;
   // assign MD = (!count) ? 0 : 'bx;
   
   

   // Latch outputs
   always @ (negedge clk)
     begin
        // RW <= (AdAs_ASYNC > 0) ? 
        // Latch format of instruction
        FORMAT <= (count > 0)                      ? FORMAT :
                  (INSTRUCTION[15:13] == `OP_JUMP) ? FMT_J  :
                  (INSTRUCTION[15:12] == 4'b0001)  ? FMT_II :
                  (INSTRUCTION[15:12] >= 4'b0100)  ? FMT_I  : 2'bx;

        // Latch SA/DA
        // reg_SA <= (FORMAT_ASYNC == FMT_I) ? INSTRUCTION[11:8] : 4'bx;
        // reg_DA <= (FORMAT_ASYNC == FMT_I) || (FORMAT_ASYNC == FMT_II) ? INSTRUCTION[3:0] : 4'bx;
        reg_SA <= (count > 0)                      ? reg_SA :
                  (FORMAT_ASYNC == FMT_I)          ? INSTRUCTION[11:8] : 4'bx;
        reg_DA <= (FORMAT_ASYNC <= FMT_II)         ? INSTRUCTION[3:0]  : 
                  (count > 0) && (&AdAs[1:0])      ? reg_SA            :
                  (count > 0)                      ? reg_DA            : 4'bx;

        // Latch Ad/As
        AdAs    <= (count)                  ? AdAs                              :
                   (FORMAT_ASYNC == FMT_I)  ? {INSTRUCTION[7],INSTRUCTION[5:4]} :
                   (FORMAT_ASYNC == FMT_II) ? {1'bx,INSTRUCTION[5:4]}           : 3'bx;
        
        // AdAs[2]   <= (FORMAT_ASYNC == FMT_I)  ? INSTRUCTION[7]   : 1'bx;
        // AdAs[1:0] <= (FORMAT_ASYNC <= FMT_II) ? INSTRUCTION[5:4] : 2'bx;

        // Latch BW
        BW <= (FORMAT_ASYNC <= FMT_II) ? INSTRUCTION[6] : 1'bx;

        // And now to determine FS code... First, what format is this in?
        case (FORMAT_ASYNC)
          FMT_I:
            case (INSTRUCTION[15:12])
              `OP_MOV:     {RW,MSR,FS} <= {1'b1,1'b0,`FS_MOV};
              `OP_ADD:     {RW,MSR,FS} <= {1'b1,1'b1,`FS_ADD};
              `OP_ADDC:    {RW,MSR,FS} <= {1'b1,1'b1,`FS_ADDC};
              `OP_SUBC:    {RW,MSR,FS} <= {1'b1,1'b1,`FS_SUBC};
              `OP_SUB:     {RW,MSR,FS} <= {1'b1,1'b1,`FS_SUB};
              `OP_CMP:     {RW,MSR,FS} <= {1'b0,1'b1,`FS_CMP};
              `OP_DADD:    {RW,MSR,FS} <= {1'b1,1'b1,`FS_DADD};
              `OP_BIT:     {RW,MSR,FS} <= {1'b0,1'b1,`FS_BIT};
              `OP_BIC:     {RW,MSR,FS} <= {1'b1,1'b0,`FS_BIC};
              `OP_BIS:     {RW,MSR,FS} <= {1'b1,1'b0,`FS_BIS};
              `OP_XOR:     {RW,MSR,FS} <= {1'b1,1'b1,`FS_XOR}; 
              `OP_AND:     {RW,MSR,FS} <= {1'b1,1'b1,`FS_AND};
              default:     {RW,MSR,FS} <= 'bx; // If it is not a valid op, just clear out
            endcase // case (INSTRUCTION[15:12])

          FMT_II:
            case (INSTRUCTION[15:7])
              `OP_RRC:     {RW,MSR,FS} <= {1'b1,1'b1,`FS_RRC};
              `OP_SWPB:    {RW,MSR,FS} <= {1'b1,1'b0,`FS_SWPB};
              `OP_RRA:     {RW,MSR,FS} <= {1'b1,1'b1,`FS_RRA};
              `OP_SXT:     {RW,MSR,FS} <= {1'b1,1'b1,`FS_SXT};
              `OP_PUSH:    {RW,MSR,FS} <= {1'b1,1'b0,`FS_PUSH};
              `OP_CALL:    {RW,MSR,FS} <= {1'b1,1'b0,`FS_CALL};
              `OP_RETI:    {RW,MSR,FS} <= {1'b1,1'b1,`FS_RETI};
              default:     {RW,MSR,FS} <= 'bx;
            endcase // case (INSTRUCTION[15:7])

          FMT_J:           {RW,MSR,FS} <= {4'b0,1'b0,INSTRUCTION[12:10]};
          default:         {RW,MSR,FS} <= 'bx;
        endcase
     end  


   // Determines instruction length
   always @ (negedge clk)
     begin
        if (!count)
          begin
             // Tell PC to go to next PC on the next clock tick
             MPC <= 1;
             // Set Din to be output of function unit
             // MD <= 0;
             // Is this a jump?
             if (FORMAT == FMT_J)
               // If so, set PC to shift the offset
               MPC <= 3;
             // Otherwise, is it one of the other two valid formats?
             else if (FORMAT_ASYNC == FMT_I || FORMAT_ASYNC == FMT_II)
                casex (INSTRUCTION[5:4])
                  2'bx0:
                    // If As = 00 or 10, then the next word should be an instruction,
                    // unless the destination addressing mode is indexed
                    if ((FORMAT_ASYNC == FMT_I) && INSTRUCTION[7])
                      count <= 1;
                  2'b11:
                    // If As = 11, then it's either immediate or indirect
                    // autoincrement. The only difference is the source
                    // register. So check if there is anything there.
                    if ((FORMAT_ASYNC == FMT_I) && !INSTRUCTION[11:8])
                      // If the dst mode is indexed and it isn't using the constant
                      // generator, add an extra one to the count. Otherwise, if it's
                      // using the constant generator, keep it 0 and otherwise keep it 1
                      count <= (INSTRUCTION[7] & ~USING_CONST_GEN) ? 2 : 
                                     (USING_CONST_GEN)                   ? 0 : 1;
                    else if ((FORMAT_ASYNC == FMT_II) && !INSTRUCTION[3:0])
                      count <= 1;                  
                  
                  2'b01:
                    if ((FORMAT_ASYNC == FMT_I) && INSTRUCTION[7])
                      count <= (USING_CONST_GEN) ? 1 : 2;
                    else
                      count <= (USING_CONST_GEN) ? 0 : 1;
                  default: count <= 0;
                endcase // casex (INSTRUCTION[5:4])
          end // if (~start)
        else
          begin
             // Set PC and SR to hold value
             {MPC,MSR} <= 0;
             // Decrement counter of instruction length
             if (count)
               begin
                  count <= count - 1;
                  // Put the whole instruction in reg_Din because it's not
                  // actually an instruction
                  // reg_Din <= MDB_out;
                  // MD <= 1;
               end
          end  
     end // always @ (negedge clk)


   

endmodule
