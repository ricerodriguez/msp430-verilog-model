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
   // R2 - SR / CG 1
   // R3 - CG 2

   // Initialize registers
   reg [15:0]    regs [15:0];   
   integer       i;
   
   initial
     begin
        for (i=0;i<16;i=i+1)
          regs[i] = 0;
     end  

   // Assign CPU registers
   assign reg_PC_out      = regs[0];
   assign reg_SP_out      = regs[1];
   assign reg_SR_out      = regs[2];
   // Addressable registers
   assign {Sout,Dout} = {regs[SA],regs[DA]};
   
   always @ (posedge clk)
     begin
        if (rst)
          begin
             for (i=0;i<16;i=i+1)
               regs[i] <= 0;
             regs[0] <= RST_VEC; // ROM[FFFE]
          end
        // Write to registers
        else if (RW)
          regs[DA] <= Din;
     end // always @ (posedge clk)

   // Conditional bits
   wire          valid_Din_ROM = (Din > 16'hC000) ? 1 : 0;
   wire          valid_Din_RAM = ((Din > 16'h0200) && (Din < 16'h03FF)) ? 1 : 0;
   wire          write_to_PC = (!DA && RW) ? 1 : 0;
   wire          write_to_SP = ((DA == 4'd1) && RW) ? 1 : 0;
   
   
   // Increment PC happens inside of MUX PC
   always @ (posedge clk)
     begin
        // Latch the incoming PC and SP
        regs[0] <= (write_to_PC && valid_Din_ROM)  ? Din :
                   (write_to_PC && ~valid_Din_ROM) ? RST_VEC : reg_PC_in;
        regs[1] <= (write_to_SP && valid_Din_RAM)  ? Din : 
                   (write_to_SP && ~valid_Din_RAM) ? RST_VEC : reg_SP_in;
     end

   // SR special cases
   always @ (*)
     case({As,SA})
       // CONSTANTS GENERATED FROM R2
       {2'b00,4'd2}: regs[SA] <= reg_SR_in;
       {2'b01,4'd2}: regs[SA] <= 0;
       {2'b10,4'd2}: regs[SA] <= 'h00004;
       {2'b11,4'd2}: regs[SA] <= 'h00008;
       // CONSTANTS GENERATED FROM R3
       {2'b00,4'd3}: regs[SA] <= 0;
       {2'b01,4'd3}: regs[SA] <= 'h00001;
       {2'b10,4'd3}: regs[SA] <= 'h00002;
       {2'b11,4'd3}: regs[SA] <= 'h0FFFF;
       default: regs[2] <= reg_SR_in;
     endcase  
   
endmodule
