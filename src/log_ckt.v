module log_ckt #(parameter SIZE=16)
  (input [SIZE-1:0] SRC,
   input [SIZE-1:0] DST,
   input [3:0] FS,
   output [SIZE-1:0] LOG_OUT);

   wire [SIZE-1:0]   A, B;
   assign A = FS[3] ? ~SRC : SRC;
   assign B = DST;
   assign LOG_OUT = (FS[1:0] == 2'b00) ? (A & B) :
                    (FS[1:0] == 2'b01) ? (A | B) :
                    (FS[1:0] == 2'b10) ? (A ^ B) :
                    (FS[1:0] == 2'b11) ? (A)     : 'bx;

endmodule
