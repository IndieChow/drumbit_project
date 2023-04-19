module scankey(
  input logic clk, rst,
  input [19:0]in,
  output logic [4:0]out, 
  output logic strobe
);
 logic[1:0] delay;
 always_ff @(posedge clk, posedge rst)
  begin
    if (rst)
      delay <= 2'b00;
    else
      delay <= {1'b0, |in[19:0]} | (delay << 1);
  end
  
  always_comb 
    begin
      out[0] = in[1] | in[3] | in[5] | in[7] | in[9] | in[11] | in[13] | in[15] | in[17] | in[19];
      out[1] = in[2] | in[3] | in[6] | in[7] | in[10] | in[11] | in[14] | in[15] | in[18] | in[19];
      out[2] = in[4] | in[5] | in[6] | in[7] | in[12] | in[13] | in[14] | in[15];
      out[3] = (|in[15:8]);
      out[4] = (|in[19:16]);
      strobe = delay[1];
    end
endmodule