`timescale 1ns / 1ps
module AddressRegisterFile(
  input wire [1:0] OutCSel,
  input wire [1:0] OutDSel,
  input wire [2:0] RegSel,
  input wire [2:0] FunSel,
  input wire [15:0] I,
  input wire Clock,
  output reg [15:0] OutC,
  output reg [15:0] OutD
);
  wire [15:0] PC1, AR1, SP1;

  Register PC (.E(~RegSel[2]), .FunSel(FunSel), .I(I), .Clock(Clock), .Q(PC1));
  Register AR (.E(~RegSel[1]), .FunSel(FunSel), .I(I), .Clock(Clock), .Q(AR1));
  Register SP (.E(~RegSel[0]), .FunSel(FunSel), .I(I), .Clock(Clock), .Q(SP1));

  always @(*) begin
    case (OutCSel) 
      2'b00: OutC = PC1;
      2'b01: OutC = PC1;
      2'b10: OutC = AR1;
      2'b11: OutC = SP1;
    endcase

    case (OutDSel)
      2'b00: OutD = PC1;
      2'b01: OutD = PC1;
      2'b10: OutD = AR1;
      2'b11: OutD = SP1;
    endcase
  end
endmodule