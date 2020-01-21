module ram
  (input clk,
   input [15:0]  ram_addr,
   input [15:0]  ram_Din,
   input         ram_RW,
   input         BW,
   output [15:0] ram_out);

   parameter  BOUND_U = 16'h0400,
              BOUND_L = 16'h0200;
   localparam SIZE    = BOUND_U - BOUND_L;

   // 512 bytes of RAM
   reg [7:0]     mem_ram [SIZE-1:0];
   initial 
     begin
        $readmemh("mems/tester.mem",mem_ram,0,28);
        // $readmemh("mems/clear.mem",mem_ram,59);
     end  

   // Double fetch for 16-bits
   assign ram_out = {mem_ram[ram_addr+1],mem_ram[ram_addr]};

   always @ (posedge clk)
     begin
        if (ram_RW)
          begin
             if (~BW)
               {mem_ram[ram_addr+1],mem_ram[ram_addr]} <= ram_Din;
             else
               mem_ram[ram_addr] <= ram_Din;
          end
     end  
   
       
       
   

endmodule
