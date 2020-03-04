module shifter #(parameter SIZE_BYTE=8, SIZE_WORD=16)
  (input [1:0]       FS,
   input             BW,
   input [SIZE_WORD-1:0]  DST,
   output [3:0]  CVNZ_shift,
   output reg [SIZE_WORD-1:0] SHIFT_OUT);

   wire [2*SIZE_BYTE-1:0] padded_byte_msb = {{SIZE_BYTE{DST[SIZE_BYTE-1]}},
                                             DST[SIZE_BYTE-1:0]};
   wire [2*SIZE_BYTE-1:0] padded_byte_lsb = {{SIZE_BYTE{DST[0]}},
                                             DST[SIZE_BYTE-1:0]};

   wire [2*SIZE_WORD-1:0] padded_word_msb = {{SIZE_WORD{DST[SIZE_WORD-1]}},DST};
   wire [2*SIZE_WORD-1:0] padded_word_lsb = {{SIZE_WORD{DST[0]}},DST};
   
   reg                    C_shift;

   // Assign status bits
   assign CVNZ_shift[3] = (&FS) ? (~CVNZ_shift[0]) : C_shift;
   assign CVNZ_shift[2] = 0;
   assign CVNZ_shift[1] =  (BW && SHIFT_OUT[SIZE_BYTE-1]) ? 1'b1 :
                          (~BW && SHIFT_OUT[SIZE_WORD-1]) ? 1'b1 : 0;
   assign CVNZ_shift[0] = (!SHIFT_OUT) ? 1'b1 : 1'b0;
   
   initial
     begin
        C_shift <= 0;
        SHIFT_OUT <= 0;
     end  
   
   always @ (*)
     case(FS)
       // RRC
       2'b00: {SHIFT_OUT,C_shift} = (~BW) ? padded_word_lsb >> 0 : padded_byte_lsb >> 0;
       // RRA
       2'b01: {SHIFT_OUT,C_shift} = (~BW) ? padded_word_msb >> 0 : padded_byte_msb >> 0;
       // SWPB (Can only be word)
       2'b10: SHIFT_OUT = (~BW) ? {DST[SIZE_BYTE-1:0], DST[SIZE_WORD-1:SIZE_BYTE]} : 'bx;
       // SXT (Can only be word)
       2'b11: SHIFT_OUT = (~BW) ? {{SIZE_BYTE{DST[SIZE_BYTE-1]}},DST[SIZE_BYTE-1:0]} : 'bx;
       default: {SHIFT_OUT,C_shift} <= 'bx;
     endcase // case (FS)
   
endmodule
