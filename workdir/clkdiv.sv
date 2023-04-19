module clkdiv #(
    parameter BITLEN = 8
) (
    input logic clk, rst,
    input logic [BITLEN-1:0] lim,
    output logic hzX
);
  logic [BITLEN-1:0] Q;
  logic [BITLEN-1:0] next_Q;

  always_ff @(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          Q <= 0;
          hzX <= 1'b0;
        end
      else
        begin
          Q <= next_Q;
          if(Q == lim) 
            hzX <= ~hzX;
        end
    end
    
  always_comb 
    begin 
      if(Q == lim) 
        next_Q = 0;
      else 
        begin
          next_Q = Q + 1;
        end
    end
endmodule
