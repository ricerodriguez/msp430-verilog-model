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
   input [15:0]  reg_Din,
   input [3:0]   reg_SA, reg_DA,
   // OUTPUTS
   output [15:0] reg_PC_out, reg_SR_out, reg_SP_out,
   output [15:0] Dout, Sout);

   // Initialize registers (for debugging)
   reg [15:0]    regs [15:0];
   reg [15:0]    reg_Din_last;
   reg [3:0]     reg_SA_last, reg_DA_last;
   // Create reg for constant generators
   reg [15:0]    reg_CG1_out, reg_CG2_out;   

   // Conditional bits
   wire          valid_reg_Din_PC = (reg_Din > 16'h01FF)    ? 1 : 0;
   wire          write_to_PC = (!reg_DA && RW)              ? 1 : 0;
   wire          write_to_SP = ((reg_DA == 4'd1) && RW)     ? 1 : 0;
   wire          write_to_SR = ((reg_DA == 4'd2) && RW)     ? 1 : 0;
   wire [2:0]    write_to_CPUREG = {write_to_SR,write_to_SP,write_to_PC};
   
   // Conditional bit for CG1 (CG2 is always active)
   wire          CG1_active = ((As > 0) && (reg_SA == 2))   ? 1 : 0;
   
   // Assign CPU registers
   assign reg_PC_out      = regs[0];
   assign reg_SP_out      = regs[1];
   assign reg_SR_out      = CG1_active ? reg_CG1_out : regs[2];

   // R0 - PC
   // R1 - SP
   // R2 - SR / CR 1
   // R3 - CR 2
   
   integer       i;

   initial
     begin
        reg_Din_last <= 0;
        reg_SA_last <= 0;
        reg_DA_last <= 0;
        reg_CG1_out <= 0;
        reg_CG2_out <= 0;
        // regs[0] = RST_VEC;
        for (i=0;i<16;i=i+1)
          regs[i] = 'hc000 + i;
     end

   // Addressable registers
   assign {Sout,Dout} = {regs[reg_SA],regs[reg_DA]};

   always @ (posedge clk)
     begin
        if (rst)
          begin
             regs[2] <= 16'h0;   // Forces GIE low and CPU on
             regs[0] <= RST_VEC; // ROM[FFFE]
          end
        else
          begin
             if (RW && (reg_DA != 3))
               // Write to the register
               regs[reg_DA] <= (!reg_DA && ~valid_reg_Din_PC) ? RST_VEC : reg_Din;

             if (~write_to_PC)
               regs[0] <= reg_PC_in;

             if (~write_to_SP)
               regs[1] <= reg_SP_in;

             if (~write_to_SR)
               regs[2] <= reg_SR_in;
          end  
        
        reg_SA_last <= reg_SA;
        reg_DA_last <= reg_DA;
        reg_Din_last <= reg_Din;
        regs[3] <= reg_CG2_out;
     end // always @ (posedge clk)
   
   // SR special cases
   always @ (*)
     case({As,reg_SA})
       // CONSTANTS GENERATED FROM R2
       {2'b00,4'd2}: reg_CG1_out <= reg_SR_in;
       {2'b01,4'd2}: reg_CG1_out <= 0;
       {2'b10,4'd2}: reg_CG1_out <= 16'h0004;
       {2'b11,4'd2}: reg_CG1_out <= 16'h0008;
       // CONSTANTS GENERATED FROM R3
       {2'b00,4'd3}: reg_CG2_out <= 0;
       {2'b01,4'd3}: reg_CG2_out <= 16'h0001;
       {2'b10,4'd3}: reg_CG2_out <= 16'h0002;
       {2'b11,4'd3}: reg_CG2_out <= 16'hFFFF;
       default: {reg_CG1_out, reg_CG2_out} <= 32'bx;       
     endcase  
   
endmodule
