`include "msp430_ops.vh"
/*
 Instruction Decoder
 ~~~~~~~~~~~~~~~~~~~
 Decodes the instructions coming off the MDB from ROM. First
 determines how many instructions to expect, then counts until that
 number of instructions has passed.
 
 TODO: 
  - OUTPUTS NEED TO BE LATCHED
  - DECODE OPCODES TO FS CODES
*/
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

   // Wires
   wire [3:0]       MSB_half; // Most Significant Half Byte
   wire [15:0]      INSTRUCTION;
   wire [8:0]       OPCODE;

   // Assign wires
   assign INSTRUCTION = (advance && start) ? (16'bx) : MDB_out;
   assign MSB_half = INSTRUCTION[15:12];
   // FORMAT: 1 = Format 1, 2 = Format 2, 3 = Jump, X = Unknown
   assign FORMAT   = (MSB_half  > 4'h3)                       ? FMT_I  :
                     (MSB_half == 4'h1)                       ? FMT_II :
                     ((MSB_half > 4'h1) && (MSB_half < 4'h4)) ? FMT_J  : 2'bx;

   assign OPCODE   = (FORMAT == FMT_I)  ? {INSTRUCTION[15:12],5'b0} :
                     (FORMAT == FMT_II) ?  INSTRUCTION[15:7]        :
                     (FORMAT == FMT_J)  ? {INSTRUCTION[15:13],6'b0} : 9'bx;

   // If this is an instruction and it's in jump format, PC = MDB << 1.
   // If this is not an instruction, PC needs to hold. Otherwise, PC + 2
   assign MPC = ((INSTRUCTION == MDB_out) && (FORMAT == FMT_J)) ? 3'h3 :
                (INSTRUCTION === 16'bx)                         ? 3'h0 : 3'h1;

   // How do I control the SP and PC for push/call?
   // assign MSP = ((FORMAT == FMT_II) && (OPCODE == `OP_PUSH)) ? 2'h1 : 
   
   // Find SA/DA from format
   assign reg_SA = (FORMAT == FMT_I)  ? INSTRUCTION[11:8] : 4'bx;
   assign reg_DA = (FORMAT == FMT_J)  ? 4'bx              :
                   (FORMAT <= FMT_II) ? INSTRUCTION[3:0]  : 4'bx;
   // Find Ad/As from format
   assign AdAs[1:0] = (FORMAT <= FMT_II) ? INSTRUCTION[5:4] : 4'bx;
   assign AdAs[2]   = (FORMAT == FMT_I)  ? INSTRUCTION[7]   : 4'bx;
   

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
     end // initial begin

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
             {MPC,MSR} <= 0;
             reg_Din <= (INSTRUCTION === 16'bx) ? MDB_out : reg_Din;
             if (count)
               count <= count - 1;
             else
               start <= 0;
          end  
     end // always @ (posedge clk)


   

endmodule
