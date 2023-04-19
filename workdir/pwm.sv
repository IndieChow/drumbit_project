
module pwm #(
    parameter int CTRVAL = 256,
    parameter int CTRLEN = $clog2(CTRVAL)
)
(
    input logic clk, rst, enable,
    input logic [CTRLEN-1:0] duty_cycle,
    output logic [CTRLEN-1:0] counter,
    output logic pwm_out
);
  logic [CTRLEN-1:0] next_count;
  always_ff @(posedge clk, posedge rst)
    begin
      if(rst)
        counter <= 0;
      else
        counter <= next_count;
    end  

   always_ff @(posedge clk, posedge rst)
    begin
      if(rst)
        counter <= 0;
      else
        counter <= next_count;
    end  
      
  always_comb
    begin
      if(duty_cycle == 0)
        pwm_out = 1'b0;
      else if(counter <= duty_cycle)
        pwm_out = 1'b1; 
      else 
        pwm_out = 1'b0;
        
      if(enable)
        begin
          if(counter == CTRLEN'(CTRVAL - 1))
            next_count = 0;
          else
            next_count = counter + 1;
        end
      else
        next_count = counter;
    end
endmodule

