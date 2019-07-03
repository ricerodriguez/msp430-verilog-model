module ram
  (input clk,
   // input rst,
   input [15:0]  ram_addr,
   input [15:0]  ram_Din,
   input         ram_RW,
   input         BW, // Ask Nutter if necessary? From what I can tell, 
   // upper byte is unaffected if it's a byte op, not cleared out
   output [15:0] ram_out);

   // 512 bytes of RAM
   reg [7:0]     mem_ram [511:0];
   
   // Double fetch for 16-bits
   assign ram_out = {mem_ram[ram_addr+1],mem_ram[ram_addr]};

   always @ (posedge clk)
     if (ram_RW)
       mem_ram[ram_addr] <= ram_Din;
   
       
       
   

endmodule
