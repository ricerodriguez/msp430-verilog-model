// Register File
// Stores values of all 16 registers. All registers are addressible.
module reg_file
  (// INPUTS
   input         clk,
   input         rst,
   input         RW,
   input [1:0]   As, // Select bit for MUX SR, controlled by control unit
   input [15:0]  reg_PC_in, reg_SR_in, reg_SP_in,
   input [15:0]  RST_VEC,
   input [15:0]  Din,
   input [3:0]   SA, DA,
   // OUTPUTS
   output [15:0] reg_PC_out, reg_SR_out, reg_SP_out,
   output [15:0] Dout, Sout);

   // R0 - PC
   // R1 - SP
   // R2 - SR / CR 1
   // R3 - CR 2

   // Initialize registers (for debugging)
   reg [15:0]    regs [15:0];      
   integer       i;
   initial
     begin
        for (i=0;i<16;i=i+1)
          regs[i] = 0;
     end

   // Addressable registers
   assign {Sout,Dout} = {regs[SA],regs[DA]};
   
   always @ (posedge clk)
     begin
        if (rst)
          begin
             // for (i=2;i<16;i=i+1)
             //   regs[i] <= 0;
             regs[2] <= 16'h0;   // Forces GIE low and CPU on
             regs[0] <= RST_VEC; // ROM[FFFE]
          end
        // Write to registers
        else if (RW)
          regs[DA] <= Din;
     end // always @ (posedge clk)

   // Conditional bits
   wire          valid_Din_PC = (Din > 16'h01FF)    ? 1 : 0;
   wire          write_to_PC = (!DA && RW)          ? 1 : 0;
   wire          write_to_SP = ((DA == 4'd1) && RW) ? 1 : 0;
   // Conditional bit for CR2 (CR3 is always active)
   wire          CR2_active = ((As > 0) && (SA == 2)) ? 1 : 0;
   
   // Create reg for constant generators
   reg [15:0] reg_CR2_out, reg_CR3_out;   
   
   // Assign CPU registers
   assign reg_PC_out      = regs[0];
   assign reg_SP_out      = regs[1];
   assign reg_SR_out      = CR2_active ? reg_CR2_out : regs[2];
   
   // Increment PC happens inside of MUX PC
   always @ (posedge clk)
     begin
        // Latch the incoming PC and SP
        regs[0] <= (write_to_PC && valid_Din_PC)  ? Din     :
                   (write_to_PC && ~valid_Din_PC) ? RST_VEC : reg_PC_in;
        regs[1] <= (write_to_SP)                  ? Din     : reg_SP_in;
        regs[2] <= reg_SR_in;
        regs[3] <= reg_CR3_out;        
     end
   
   // SR special cases
   always @ (*)
     case({As,SA})
       // CONSTANTS GENERATED FROM R2
       {2'b00,4'd2}: reg_CR2_out <= reg_SR_in;
       {2'b01,4'd2}: reg_CR2_out <= 0;
       {2'b10,4'd2}: reg_CR2_out <= 16'h0004;
       {2'b11,4'd2}: reg_CR2_out <= 16'h0008;
       // CONSTANTS GENERATED FROM R3
       {2'b00,4'd3}: reg_CR3_out <= 0;
       {2'b01,4'd3}: reg_CR3_out <= 16'h0001;
       {2'b10,4'd3}: reg_CR3_out <= 16'h0002;
       {2'b11,4'd3}: reg_CR3_out <= 16'hFFFF;
       default: {reg_CR2_out, reg_CR3_out} <= 0;       
     endcase  
   
endmodule
