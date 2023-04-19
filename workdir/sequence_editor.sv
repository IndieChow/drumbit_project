module sequence_editor (
 input logic clk, rst,
 input logic [1:0] mode,
 input logic [2:0] set_time_idx,
 input logic [3:0] tgl_play_smpl,
 output logic [3:0] seq_smpl_1, seq_smpl_2, seq_smpl_3, seq_smpl_4, seq_smpl_5, seq_smpl_6, seq_smpl_7, seq_smpl_8
);
  logic [3:0] smpl [7:0];
  assign {seq_smpl_1, seq_smpl_2, seq_smpl_3, seq_smpl_4, seq_smpl_5, seq_smpl_6, seq_smpl_7, seq_smpl_8} = {smpl[0], smpl[1], smpl[2], smpl[3], smpl[4], smpl[5], smpl[6], smpl[7]};
  
  always_ff @ (posedge clk, posedge rst) begin
    if(rst)
      {smpl[0], smpl[1], smpl[2], smpl[3], smpl[4], smpl[5], smpl[6], smpl[7]} <= 0;
    else if(mode == 2'd0)
      smpl[set_time_idx] <= smpl[set_time_idx] ^ tgl_play_smpl;
  end
endmodule