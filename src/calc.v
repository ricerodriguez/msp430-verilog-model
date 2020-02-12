module calc
  (input             clk,
   input [2:0]       AdAs,
   input             MC,
   input [15:0]      MDB_out,
   input [15:0]      Sout, Dout,
   output reg [15:0] CALC_out,
   output reg        CALC_done);

   reg [1:0]         state;
   reg [15:0]        Sout_last, Dout_last, MDB_last;
   reg               ignore;
   

   localparam
     state_IDLE = 0, state_WAIT = 1, state_CALC = 2;

   initial
     begin
        CALC_out   <= 0;
        CALC_done <= 0;
        MDB_last <= 0;
        Sout_last  <= 0;
        Dout_last  <= 0;
        state      <= 0;
        ignore <= 0;
     end  

   // Latches
   always @ (posedge clk)
     begin
        if (~MC)
          begin
             state <= state_IDLE;
             CALC_out <= CALC_out;
             CALC_done <= 0;
          end

        else
          begin
             case (state)
               state_IDLE:
                 begin
                    // Latch until ready
                    CALC_out <= CALC_out;
                    CALC_done <= 0;
                    if (MC)
                      begin
                         state <= state_CALC;
                         Sout_last <= Sout;
                         Dout_last <= Dout;
                         MDB_last  <= MDB_out;
                      end  
                 end  
               state_WAIT:
                 begin
                    CALC_out <= CALC_out;
                    CALC_done <= 0;
                    state <= state_CALC;
                 end
               state_CALC:
                 begin
                    case (AdAs)
                      // Indexed/Symbolic/Absolute (SA)
                      3'b001:
                        begin
                           CALC_out <= Sout_last + MDB_out;
                           CALC_done <= 1;
                           state <= state_IDLE;               
                        end

                      // Indexed (SA and DA)
                      3'b101:
                        begin
                           if (~ignore)
                             begin
                                CALC_out <= Sout_last + MDB_out;
                                CALC_done <= 1;
                                ignore <= 1;
                                state <= state_WAIT;
                             end
                           else
                             begin
                                CALC_out <= Dout_last + MDB_out;
                                CALC_done <= 1;
                                ignore <= 0;
                                state <= state_IDLE;
                             end  
                        end  

                      // Inpdexed (DA)
                      3'b100:
                        begin
                           CALC_out <= Dout_last + MDB_out;
                           CALC_done <= 1;
                           state <= state_IDLE;
                        end
                      
                      // Latch otherwise
                      default:
                        begin
                           CALC_out <= CALC_out;
                           state <= state_IDLE;
                        end  

                    endcase // casex (AdAs)
                 end // case: state_CALC
               
               default: CALC_out <= CALC_out;
             endcase // case (state)
          end // else: !if(~MC)
     end // always @ (posedge clk)
   

endmodule
