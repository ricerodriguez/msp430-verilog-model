/*
 Instruction Decoder
 ~~~~~~~~~~~~~~~~~~~
 Decodes the instructions coming off the MDB from ROM. First
 determines how many instructions to expect, then counts until that
 number of instructions has passed.
 TODO:
   - LATCH ALL THE OUTPUTS
   - DECODE OP CODES TO FS CODES
*/
`include "msp430_ops.vh"
module instr_dec
  (input             clk,
   input [15:0]      MDB_out,
   input             CTL_SEL,
   output reg [1:0]  FORMAT,
   output reg [3:0]  reg_SA, reg_DA,
   output reg [2:0]  AdAs, 
   output reg [15:0] reg_Din,
   output reg [2:0]  MPC, 
   output reg [1:0]  MSP, 
   output reg        MSR);
   // MPC - Select bit for MUX PC
   // MSP - Select bit for MUX SP
   // MSR - Select bit for MUX SR

   localparam FMT_I = 1, FMT_II = 2, FMT_J = 3;

   // Registers
   reg              start;   // Start counting instructions
   // reg              advance; // Instruction has finished
   reg [2:0]        count;   // Counts instructions

   // Initialize registers
   initial
     begin
        FORMAT <= 0;
        reg_SA <= 0;
        reg_DA <= 0; 
        AdAs <= 0;        
        reg_Din <= 0;
        MPC <= 0;
        MSP <= 0;
        MSR <= 0;        
        count <= 0;
        start <= 0;
        // advance <= 0;
     end

   // Wires
   wire [15:0]      INSTRUCTION;
   wire [1:0]       FORMAT_ASYNC;
   

   // Assign wires
   assign INSTRUCTION = (start) ? (16'bx) : MDB_out;
   // FORMAT: 1 = Format 1, 2 = Format 2, 3 = Jump, X = Unknown
   assign FORMAT_ASYNC = (INSTRUCTION[15:13] == `OP_JUMP) ? FMT_J  :
                         (INSTRUCTION[15:12] == 4'b0001)  ? FMT_II :
                         (INSTRUCTION[15:12] >= 4'b0100)  ? FMT_I  : 2'bx;
   
   // Latch outputs
   always @ (negedge clk)
     begin
        // Latch format of instruction
        FORMAT <= (INSTRUCTION[15:13] == `OP_JUMP) ? FMT_J  :
                  (INSTRUCTION[15:12] == 4'b0001)  ? FMT_II :
                  (INSTRUCTION[15:12] >= 4'b0100)  ? FMT_I  : 2'bx;

        // Latch SA/DA
        reg_SA <= (FORMAT_ASYNC == FMT_I) ? INSTRUCTION[11:8] : 4'bx;
        reg_DA <= (FORMAT_ASYNC == FMT_I) || (FORMAT_ASYNC == FMT_II) ? INSTRUCTION[3:0] : 4'bx;

        // Latch Ad/As
        AdAs[2]   <= (FORMAT_ASYNC == FMT_I)  ? INSTRUCTION[7]   : 1'bx;
        AdAs[1:0] <= (FORMAT_ASYNC <= FMT_II) ? INSTRUCTION[5:4] : 2'bx;
     end  

   // Determines instruction length
   always @ (negedge clk)
     begin
        if (~start)
          begin
             MPC <= 1;
             MSR <= 1;          
             reg_Din <= reg_Din;             
             if (FORMAT == FMT_J)
               MPC <= 3;
             else if (FORMAT == FMT_I || FORMAT == FMT_II)
               begin
                  if (INSTRUCTION[5] || !INSTRUCTION[5:4])
                    begin
                       count <= 1;
                       start <= 1;
                       if ((FORMAT == FMT_I) && ~INSTRUCTION[7])
                         count <= count + 1;                       
                    end
               end
          end // if (~start)
        else
          begin
             // Set PC and SR to hold value
             {MPC,MSR} <= 0;
             // reg_Din <= (INSTRUCTION === 16'bx) ? MDB_out : reg_Din;
             // Decrement counter of instruction length
             if (count)
               begin
                  count <= count - 1;
                  // Put the whole instruction in reg_Din because it's not
                  // actually an instruction
                  reg_Din <= MDB_out;                  
               end
             // If we hit 0 then this is the last non-instruction
             else
               start <= 0;
          end  
     end // always @ (negedge clk)


   

endmodule
