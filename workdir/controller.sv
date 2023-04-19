module controller(
  input logic clk, rst, set_edit, set_play, set_raw,
  output logic [1:0] mode
);
  typedef enum logic [1:0] { EDIT=2'd0, PLAY=2'd1, RAW=2'd2 } sysmode_t;
  logic [1:0] next_mode;
  
  always_ff @(posedge clk, posedge rst)
    begin 
      if(rst)
        mode <= EDIT;
      else 
        mode <= next_mode;
    end
  
  always_comb
    begin
      if(set_play)
        next_mode = PLAY;
      else if(set_raw)
        next_mode = RAW;
      else if(set_edit)
        next_mode = EDIT;
      else
        next_mode = mode;
    end
endmodule