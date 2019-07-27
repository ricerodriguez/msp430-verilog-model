module pipeline_tb;

   /*AUTOWIRE*/
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [15:0]           CALC_OUT;               // To uut of pipeline.v
   reg [2:0]            MAB_SEL;                // To uut of pipeline.v
   reg [15:0]           MDB_in;                 // To uut of pipeline.v
   reg [15:0]           RST_VEC;                // To uut of pipeline.v
   reg                  clk;                    // To uut of pipeline.v
   reg [15:0]           reg_Din;                // To uut of pipeline.v
   reg [15:0]           reg_SP_in;              // To uut of pipeline.v
   reg [15:0]           reg_SR_in;              // To uut of pipeline.v
   reg                  rst;                    // To uut of pipeline.v
   // End of automatics

   pipeline uut
     (/*AUTOINST*/
      // Inputs
      .CALC_OUT                         (CALC_OUT[15:0]),
      .MAB_SEL                          (MAB_SEL[2:0]),
      .MDB_in                           (MDB_in[15:0]),
      .RST_VEC                          (RST_VEC[15:0]),
      .clk                              (clk),
      .reg_Din                          (reg_Din[15:0]),
      .reg_SP_in                        (reg_SP_in[15:0]),
      .reg_SR_in                        (reg_SR_in[15:0]),
      .rst                              (rst));

   always #5 clk = ~clk;

   initial
     begin
        {clk,CALC_OUT,MAB_SEL,MDB_in} <= 0;
        rst <= 1;
        reg_SP_in <= 'h0400;
        reg_SR_in <= 0;
        RST_VEC <= 'hc000;        
        #7 rst <= 0;
        
     end

endmodule
