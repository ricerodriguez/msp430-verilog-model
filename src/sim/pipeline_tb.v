module pipeline_tb;

   /*AUTOWIRE*/
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [15:0]           RST_VEC;                // To uut of pipeline.v
   reg                  clk;                    // To uut of pipeline.v
   reg [15:0]           reg_SP_in;              // To uut of pipeline.v
   reg [15:0]           reg_SR_in;              // To uut of pipeline.v
   reg                  rst;                    // To uut of pipeline.v
   // End of automatics

   pipeline uut
     (/*AUTOINST*/
      // Inputs
      .RST_VEC                          (RST_VEC[15:0]),
      .clk                              (clk),
      .reg_SP_in                        (reg_SP_in[15:0]),
      .reg_SR_in                        (reg_SR_in[15:0]),
      .rst                              (rst));


   always #5 clk = ~clk;
   initial $monitor($time, "reset=%b, clk=%b",rst,clk);
   initial
     begin
        $dumpfile("dmp/pipeline_tb_01.vcd");
        $dumpvars(0,pipeline_tb);
        clk <= 0;
        rst <= 1;
        reg_SP_in <= 'h0400;
        reg_SR_in <= 0;
        RST_VEC <= 'hc000;        
        #5 rst <= 0;
        #1000 $dumpflush;
     end

endmodule
