module top (
  // I/O ports
  input  logic hz2m, hz100, reset,
  input  logic [20:0] pb,
  /* verilator lint_off UNOPTFLAT */
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
 // *** FPGA MODE SECTION ***
 // EDIT MODE IMPLEMENTATION BEGIN
  logic [4:0] keycode;
  logic strobe;
  scankey sk (.clk(hz2m), .rst(reset), .in(pb[19:0]), .out(keycode), .strobe(strobe));
  
  logic [1:0] mode;
  controller ctrl(.clk(strobe), .rst(reset), .set_edit(pb[19]), .set_play(pb[18]), .set_raw(pb[16]), .mode(mode));
  
  always_comb begin
    case(mode)
      2'd2: {red, green, blue} = 3'b100;
      2'd1: {red, green, blue} = 3'b010;
      2'd0: {red, green, blue} = 3'b001;
      default: {red, green, blue} = 3'b000;
    endcase
  end
  
  logic [7:0] edit_seq_out;
  logic srst;
  assign srst = (mode != 2'd0) ? 1 : 0; 
  sequencer sql(.clk(strobe), .rst(reset), .srst(srst), .go_left(pb[11]), .go_right(pb[8]), .seq_out(edit_seq_out));

  logic [2:0] encoded_out;
  prienc8to3 encd (.in(edit_seq_out), .out(encoded_out));
  
  logic [3:0] edit_play_smpl [7:0];
  sequence_editor sq_edit(.clk(strobe), .rst(reset), .mode(mode), .set_time_idx(encoded_out), .tgl_play_smpl(pb[3:0]), 
                  .seq_smpl_1(edit_play_smpl[0]), .seq_smpl_2(edit_play_smpl[1]), .seq_smpl_3(edit_play_smpl[2]),
                  .seq_smpl_4(edit_play_smpl[3]), .seq_smpl_5(edit_play_smpl[4]), .seq_smpl_6(edit_play_smpl[5]),
                  .seq_smpl_7(edit_play_smpl[6]), .seq_smpl_8(edit_play_smpl[7]));
  
  assign {ss7[5], ss7[1], ss7[4], ss7[2]} = edit_play_smpl[7];
  assign {ss6[5], ss6[1], ss6[4], ss6[2]} = edit_play_smpl[6];
  assign {ss5[5], ss5[1], ss5[4], ss5[2]} = edit_play_smpl[5];
  assign {ss4[5], ss4[1], ss4[4], ss4[2]} = edit_play_smpl[4];
  assign {ss3[5], ss3[1], ss3[4], ss3[2]} = edit_play_smpl[3];
  assign {ss2[5], ss2[1], ss2[4], ss2[2]} = edit_play_smpl[2];
  assign {ss1[5], ss1[1], ss1[4], ss1[2]} = edit_play_smpl[1];
  assign {ss0[5], ss0[1], ss0[4], ss0[2]} = edit_play_smpl[0];
  // PLAY MODE IMPLEMENTATION BEGIN
  logic bpm_clk;
  clkdiv #(20) ck2 (.clk(hz2m), .rst(reset), .lim(20'd499999), .hzX(bpm_clk));
  
  logic [7:0] play_seq_out;
  logic srst_two;
  assign srst_two =  (mode != 2'd1) ? 1 : 0; 
  sequencer sql_play(.clk(bpm_clk), .rst(reset), .srst(srst_two), .go_right(1'b1), .go_left(1'b0), .seq_out(play_seq_out));
  
  logic [7:0] seq_out;
  logic [7:0] seq_in;
  logic [2:0] seq_sel;
  logic[15:0] delay;
  always_ff @(posedge hz2m, posedge reset) begin
     if (reset)
      delay <= 16'd0;
    else begin
      delay <= {8'd0, seq_in} | (delay << 8);
    end
  end
 
  always_comb begin
    case(mode) 
      2'd0: seq_in = edit_seq_out;
      2'd1: seq_in = play_seq_out;
      default: seq_in = 0;
    endcase
    seq_out = delay[15:8];
  end

  prienc8to3 sel_encd (.in(seq_out), .out(seq_sel));
  assign {left[7], left[5], left[3], left[1], right[7], right[5], right[3], right[1]} = seq_out;

  // RAW MODE IMPLEMENTATION BEGIN
  logic [3:0] raw_play_smpl;
  assign raw_play_smpl = pb[3:0];

  logic [3:0] play_smpl;
  always_ff @(posedge hz2m, posedge reset) begin
    if(reset)
      play_smpl <= 0;
    else if(mode == 2'd0)
      play_smpl <= 0;
    else if(mode == 2'd1) 
      // in the portion of code where you assign play_smpl on a clock edge, add this:
      play_smpl <= ((enable_ctr <= 900000) ? edit_play_smpl[seq_sel] : 4'b0) | raw_play_smpl;
    else if(mode == 2'd2)
      play_smpl <= raw_play_smpl;
  end
  // assign {left[6], left[4], left[2], left[0]} = play_smpl;
  //*************************************************************************************************

  // *** AUDIO SECTION ***
  // SETTING-UP AUDIO IMPLEMENTATION BEGIN
  logic sample_clk;
  clkdiv clk16 (.clk(hz2m), .rst(reset), .lim(8'd124), .hzX(sample_clk));
  logic [7:0] sample_data [3:0];

  sample #(
    .SAMPLE_FILE("../audio/kick.mem"),
    .SAMPLE_LEN(4000)
  ) sample_kick (
      .clk(sample_clk),
      .rst(reset),
      .enable(play_smpl[3]),
      .out(sample_data[0])
  );

  sample #(
    .SAMPLE_FILE("../audio/clap.mem"),
    .SAMPLE_LEN(4000)
  ) sample_clap (
      .clk(sample_clk),
      .rst(reset),
      .enable(play_smpl[2]),
      .out(sample_data[1])
  );

  sample #(
    .SAMPLE_FILE("../audio/hihat.mem"),
    .SAMPLE_LEN(4000)
  ) sample_hihat (
      .clk(sample_clk),
      .rst(reset),
      .enable(play_smpl[1]),
      .out(sample_data[2])
  );
sample #(
    .SAMPLE_FILE("../audio/snare.mem"),
    .SAMPLE_LEN(4000)
) sample_snare (
      .clk(sample_clk),
      .rst(reset),
      .enable(play_smpl[0]),
      .out(sample_data[3])
);

// MIXING MULTIPLE AUDIO SIGNALS IMPLEMENTATIONS BEGINS
logic [7:0] temp_sum_one, temp_sum_two; 


always_comb begin
  temp_sum_one = sample_data[0] + sample_data[1];
  temp_sum_two = sample_data[2] + sample_data[3];
  if(sample_data[0][7] == 1 && sample_data[1][7] == 1 && temp_sum_one[7] == 0)
    temp_sum_one = 8'd128; // underflow
  else if(sample_data[0][7] == 0 && sample_data[1][7] == 0 && temp_sum_one[7] == 1)
    temp_sum_one = 8'd127; // overflow

  
  if(sample_data[2][7] == 1 && sample_data[3][7] == 1 && temp_sum_two[7] == 0)
    temp_sum_two = 8'd128; // underflow
  else if(sample_data[2][7] == 0 && sample_data[3][7] == 0 && temp_sum_two[7] == 1)
    temp_sum_two = 8'd127; // overflow

  
  total_temp_sum = temp_sum_one + temp_sum_two;
  if(temp_sum_one[7] == 1 && temp_sum_two[7] == 1 && total_temp_sum[7] == 0)
      total_temp_sum = 8'd128; // underflow
  else if(temp_sum_one[7] == 0 && temp_sum_two[7] == 0 && total_temp_sum[7] == 1)
      total_temp_sum = 8'd127; // overflow

end
assign total_FINAL_sum = total_temp_sum ^ 8'd128;
logic [7:0] total_temp_sum, total_FINAL_sum;


// SETTING UP PWM IMPLEMENTATION BEGIN
pwm #(64) pwm_inst (.clk(hz2m), .rst(reset), .enable(1'b1), .duty_cycle(total_FINAL_sum[7:2]), 
.counter({ss7[7], ss6[7], ss5[7], ss4[7], ss3[7], ss2[7]}), .pwm_out(right[0]));

// SETTING UP ERRATA
logic prev_bpm_clk;
logic [31:0] enable_ctr;
always_ff @(posedge hz2m, posedge reset)
  if (reset) begin
    prev_bpm_clk <= 0;
    enable_ctr <= 0;
  end
  // otherwise, if we're in PLAY mode
  else if (mode == 2'd1) begin
    // if we're on a rising edge of bpm_clk, indicating 
    // the beginning of the beat, reset the counter.
    if (~prev_bpm_clk && bpm_clk) begin
      enable_ctr <= 0;
      prev_bpm_clk <= 1;
    end
    // if we're on a falling edge of bpm_clk, indicating 
    // the middle of the beat, set the counter to half its value
    // to correct for drift.
    else if (prev_bpm_clk && ~bpm_clk) begin
      enable_ctr <= 499999;
      prev_bpm_clk <= 0;
    end
    // otherwise count to 1 million, and reset to 0 when that value is reached.
    else begin
      enable_ctr <= (enable_ctr == 999999) ? 0 : enable_ctr + 1;
    end
  end
  // reset the counter so we start on time again.
  else begin
    prev_bpm_clk <= 0;
    enable_ctr <= 0;
  end     
//*************************************************************************************************
endmodule
