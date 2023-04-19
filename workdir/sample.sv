module sample #(
  parameter SAMPLE_FILE = "../audio/kick.mem",
  parameter SAMPLE_LEN = 4000
)
(
  input clk, rst, enable,
  output logic [7:0] out
);
  logic [7:0] audio_mem [4095:0];
  initial $readmemh(SAMPLE_FILE, audio_mem, 0, SAMPLE_LEN);
  
  logic [11:0] curr_count;
  logic [11:0] next_count;
  reg prev_en;
  
  always_ff @(posedge clk, posedge rst)
    begin
      if(rst)
        curr_count <= 0;
      else
        begin
          curr_count <= next_count;
          prev_en <= enable;
          out <= audio_mem[curr_count];
        end
    end
   
  always_comb
    begin
      if(prev_en && enable)
        begin
          if(curr_count == SAMPLE_LEN)
              next_count = 12'd0;
            else
              begin
                next_count[0] = ~curr_count[0];
                next_count[1] = curr_count[1] ^ curr_count[0];
                next_count[2] = curr_count[2] ^ (curr_count[1] & curr_count[0]);
                next_count[3] = curr_count[3] ^ (curr_count[2] & curr_count[1] & curr_count[0]);
                next_count[4] = curr_count[4] ^ (curr_count[3] & curr_count[2] & curr_count[1] & curr_count[0]);
                next_count[5] = curr_count[5] ^ (curr_count[4] & curr_count[3] & curr_count[2] & curr_count[1] & curr_count[0]);
                next_count[6] = curr_count[6] ^ (curr_count[5] & curr_count[4] & curr_count[3] & curr_count[2] & curr_count[1] & curr_count[0]);
                next_count[7] = curr_count[7] ^ (curr_count[6] & curr_count[5] & curr_count[4] & curr_count[3] & curr_count[2] & curr_count[1] & curr_count[0]);
                next_count[8] = curr_count[8] ^ (curr_count[7] & curr_count[6] & curr_count[5] & curr_count[4] & curr_count[3] & curr_count[2] & curr_count[1] & curr_count[0]);
                next_count[9] = curr_count[9] ^ (curr_count[8] & curr_count[7] & curr_count[6] & curr_count[5] & curr_count[4] & curr_count[3] & curr_count[2] & curr_count[1] & curr_count[0]);
                next_count[10] = curr_count[10] ^ (curr_count[9] & curr_count[8] & curr_count[7] & curr_count[6] & curr_count[5] & curr_count[4] & curr_count[3] & curr_count[2] & curr_count[1] & curr_count[0]);
                next_count[11] = curr_count[11] ^ (curr_count[10] & curr_count[9] & curr_count[8] & curr_count[7] & curr_count[6] & curr_count[5] & curr_count[4] & curr_count[3] & curr_count[2] & curr_count[1] & curr_count[0]);
              end 
        end
      else if(prev_en && ~enable)
        next_count = 12'd0;
      else
        next_count = curr_count;
    end
endmodule
