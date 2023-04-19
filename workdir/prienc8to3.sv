module prienc8to3( 
  input logic [7:0] in,
  output logic [2:0] out
);
assign out =  in[7] == 1 ? 3'b111:
              in[6] == 1 ? 3'b110:
              in[5] == 1 ? 3'b101:
              in[4] == 1 ? 3'b100:
              in[3] == 1 ? 3'b011:
              in[2] == 1 ? 3'b010:
              in[1] == 1 ? 3'b001:
              in[0] == 1 ? 3'b000:
                           3'b000;
endmodule