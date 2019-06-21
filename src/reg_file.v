
// Register File
// Stores values of all 16 registers. All registers are addressible.
module reg_file
  (// INPUTS
   input         clk,
   input         RW,
   input [1:0]   As, // Select bit for MUX SR, controlled by control unit
   input [15:0]  PC_in, SR_in, SP_in,
   input [15:0]  Din,
   input [3:0]   SA, DA,
   // OUTPUTS
   output [15:0] PC_out, SR_out, SP_out,
   output [15:0] Dout, Sout);

   // R0 - PC
   // R1 - SP
   // R2 - SR / CG 1
   // R3 - CG 2

   // Initialize registers
   reg [15:0]    regs [15:0];
   reg [15:0]    SR_last;

   integer       i;
   
   initial
     begin
        for (i=0;i<15;i=i+1)
          regs[i] = 0;
        SR_last = 0;
     end  

   // Assign CPU registers
   assign PC_out      = regs[0];
   assign SP_out      = regs[1];
   assign SR_out      = regs[2];
   // Addressable registers
   assign {Sout,Dout} = {regs[SA],regs[DA]};
   
   // Write to registers
   always @ (posedge clk)
     if (RW)
       regs[DA] <= Din;
   
   // Increment PC happens inside of MUX PC
   always @ (posedge clk)
     begin
        // Latch the incoming PC and SP
        regs[0] <= {PC_in[15:1],1'b0};
        regs[1] <= SP_in;
     end

   // SR special cases
   always @ (*)
     case({As,SA})
       // CONSTANTS GENERATED FROM R2
       {2'b00,4'd2}: regs[SA] <= SR_in;
       {2'b01,4'd2}: regs[SA] <= 0;
       {2'b10,4'd2}: regs[SA] <= 'h00004;
       {2'b11,4'd2}: regs[SA] <= 'h00008;
       // CONSTANTS GENERATED FROM R3
       {2'b00,4'd3}: regs[SA] <= 0;
       {2'b01,4'd3}: regs[SA] <= 'h00001;
       {2'b10,4'd3}: regs[SA] <= 'h00002;
       {2'b11,4'd3}: regs[SA] <= 'h0FFFF;
       default: regs[SA] <= regs[SA];
     endcase  
   
endmodule
