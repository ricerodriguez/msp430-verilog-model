module instr_dec_tb;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [2:0]           AdAs;                   // From uut of instr_dec.v
   wire                 BW;                     // From uut of instr_dec.v
   wire [1:0]           FORMAT;                 // From uut of instr_dec.v
   wire [5:0]           FS;                     // From uut of instr_dec.v
   wire [2:0]           MPC;                    // From uut of instr_dec.v
   wire [1:0]           MSP;                    // From uut of instr_dec.v
   wire                 MSR;                    // From uut of instr_dec.v
   wire                 RW;                     // From uut of instr_dec.v
   wire [3:0]           reg_DA;                 // From uut of instr_dec.v
   wire [15:0]          reg_Din;                // From uut of instr_dec.v
   wire [3:0]           reg_SA;                 // From uut of instr_dec.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg                  CTL_SEL;                // To uut of instr_dec.v
   reg [15:0]           MDB_out;                // To uut of instr_dec.v
   reg                  clk;                    // To uut of instr_dec.v
   // End of automatics

   instr_dec uut
     (/*AUTOINST*/
      // Outputs
      .AdAs                             (AdAs[2:0]),
      .BW                               (BW),
      .FORMAT                           (FORMAT[1:0]),
      .FS                               (FS[5:0]),
      .MPC                              (MPC[2:0]),
      .MSP                              (MSP[1:0]),
      .MSR                              (MSR),
      .RW                               (RW),
      .reg_DA                           (reg_DA[3:0]),
      .reg_Din                          (reg_Din[15:0]),
      .reg_SA                           (reg_SA[3:0]),
      // Inputs
      .CTL_SEL                          (CTL_SEL),
      .MDB_out                          (MDB_out[15:0]),
      .clk                              (clk));

   reg [15:0] mem [28:0];
   integer i;

   initial
     begin
        $readmemh("tester.mem",mem);
        {clk,CTL_SEL} <= 0;
        MDB_out <= mem[i];        
        i <= 0;
        #5 i <= i + 1; 
           MDB_out <= mem[i];
        forever
          begin
             #10 i <= i + 1;
                 MDB_out <= mem[i];
          end

     end

   
   always #5 clk = ~clk;

endmodule
