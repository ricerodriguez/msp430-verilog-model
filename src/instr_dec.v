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
   output [1:0]      FORMAT,
   output [3:0]      reg_SA, reg_DA,
   output [2:0]      AdAs, 
   output reg [15:0] reg_Din,
   output reg [2:0]  MPC, 
   output reg [1:0]  MSP, 
   output reg        MSR);
   // MPC - Select bit for MUX PC
   // MSP - Select bit for MUX SP
   // MSR - Select bit for MUX SR

   localparam FMT_I = 1, FMT_II = 2, FMT_J = 3;

   // Wires
   wire [3:0]       MSB_half; // Most Significant Half Byte
   wire [15:0]      instruction;
   

   // Assign wires
   assign instruction = (advance && start) ? (16'bx) : MDB_out;
   assign MSB_half = instruction[15:12];
   // FORMAT: 1 = Format 1, 2 = Format 2, 3 = Jump, X = Unknown
   assign FORMAT   = (MSB_half  > 4'h3)                       ? FMT_I  :
                     (MSB_half == 4'h1)                       ? FMT_II :
                     ((MSB_half > 4'h1) && (MSB_half < 4'h4)) ? FMT_J  : 2'bx;
   
   // Find SA/DA from format
   assign reg_SA = (FORMAT == FMT_I)  ? instruction[11:8] : 4'bx;
   assign reg_DA = (FORMAT == FMT_J)  ? 4'bx              :
                   (FORMAT <= FMT_II) ? instruction[3:0]  : 4'bx;
   // Find Ad/As from format
   assign AdAs[1:0] = (FORMAT <= FMT_II) ? instruction[5:4] : 4'bx;
   assign AdAs[2]   = (FORMAT == FMT_I)  ? instruction[7]   : 4'bx;
   

   // Registers
   reg              start;   // Start counting instructions
   reg              advance; // Instruction has finished
   reg [2:0]        count;   // Counts instructions

   // Initialize registers
   initial
     begin
        reg_Din <= 0;
        MPC <= 0;
        MSP <= 0;
        MSR <= 0;        
        count <= 0;
        start <= 0;
        advance <= 0;
     end

   // D latch keeps counting until it's been reset
   always @ (posedge clk)
     begin
        if (~start)
          advance <= 0;
        else
          advance <= start;
     end

   // Determines instruction length
   always @ (posedge clk)
     begin
        if (~start)
          begin
             if (FORMAT == FMT_J)
               MPC <= 3;
             else if (FORMAT == FMT_I || FORMAT == FMT_II)
               begin
                  if (instruction[5] || !instruction[5:4])
                    begin
                       count <= 1;
                       start <= 1;
                       if ((FORMAT == FMT_I) && ~instruction[7])
                         count <= count + 1;                       
                    end
               end
          end // if (~start)
        else
          begin
             {MPC,MSR} <= 0;
             reg_Din <= (instruction === 16'bx) ? MDB_out : reg_Din;
             if (count)
               count <= count - 1;
             else
               start <= 0;
          end  
     end // always @ (posedge clk)


   

endmodule
