module sequencer(
input logic clk, rst, srst, go_left, go_right,
output logic [7:0] seq_out
);
  logic [7:0] next_seq;
  always_ff @(posedge clk, posedge rst)
    begin
      if(rst) 
        seq_out <= 8'h80;
      else 
        seq_out <= next_seq;
    end
  
    always_comb 
      begin
        if(srst)
          next_seq = 8'h80;
        else if(go_right)
          begin 
            next_seq[0] = seq_out[1];
            next_seq[1] = seq_out[2];
            next_seq[2] = seq_out[3];
            next_seq[3] = seq_out[4];
            next_seq[4] = seq_out[5];
            next_seq[5] = seq_out[6];
            next_seq[6] = seq_out[7];
            next_seq[7] = seq_out[0];
          end
        else if(go_left)
          begin
            next_seq[0] = seq_out[7];
            next_seq[1] = seq_out[0];
            next_seq[2] = seq_out[1];
            next_seq[3] = seq_out[2];
            next_seq[4] = seq_out[3];
            next_seq[5] = seq_out[4];
            next_seq[6] = seq_out[5];
            next_seq[7] = seq_out[6];
          end
        else 
          next_seq = seq_out;
      end
endmodule
