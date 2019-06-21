module reg_file_tb;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]          Dout;                   // From uut of reg_file.v
   wire [15:0]          PC_out;                 // From uut of reg_file.v
   wire [15:0]          SP_out;                 // From uut of reg_file.v
   wire [15:0]          SR_out;                 // From uut of reg_file.v
   wire [15:0]          Sout;                   // From uut of reg_file.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [1:0]            As;                     // To uut of reg_file.v
   reg [3:0]            DA;                     // To uut of reg_file.v
   reg [15:0]           Din;                    // To uut of reg_file.v
   reg [15:0]           PC_in;                  // To uut of reg_file.v
   reg                  RW;                     // To uut of reg_file.v
   reg [3:0]            SA;                     // To uut of reg_file.v
   reg [15:0]           SP_in;                  // To uut of reg_file.v
   reg [15:0]           SR_in;                  // To uut of reg_file.v
   reg                  clk;                    // To uut of reg_file.v
   // End of automatics

   reg_file uut
     (/*AUTOINST*/
      // Outputs
      .Dout                             (Dout[15:0]),
      .PC_out                           (PC_out[15:0]),
      .SP_out                           (SP_out[15:0]),
      .SR_out                           (SR_out[15:0]),
      .Sout                             (Sout[15:0]),
      // Inputs
      .As                               (As[1:0]),
      .DA                               (DA[3:0]),
      .Din                              (Din[15:0]),
      .PC_in                            (PC_in[15:0]),
      .RW                               (RW),
      .SA                               (SA[3:0]),
      .SP_in                            (SP_in[15:0]),
      .SR_in                            (SR_in[15:0]),
      .clk                              (clk));


   initial
     begin
        clk <= 0;
        RW  <= 0;
        {DA, SA, As} <= 0;
        PC_in <= 16'h0;
        SP_in <= 16'hFFFF;
        SR_in <= 16'hFFFF;
        Din <= 16'hFFFF;
     end

   always #5 clk = ~clk;
   always #10 {DA, SA, As} = {DA, SA, As} + 1;
   always #5 PC_in = PC_in + 1;
   always #30 RW <= ~RW;
   
   

endmodule
