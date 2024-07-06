`timescale 1ns / 1ps
module RegisterFile(
  input wire [2:0] OutASel,
  input wire [2:0] OutBSel,
  input wire [3:0] RegSel,
  input wire [3:0] ScrSel,
  input wire [2:0] FunSel,
  input wire [15:0] I,
  input wire Clock,
  output reg [15:0] OutA,
  output reg [15:0] OutB
);

  wire [15:0] Out1, Out2, Out3, Out4;
  wire [15:0] Out5, Out6, Out7, Out8;

  Register R1(.FunSel(FunSel), .E(~RegSel[3]), .I(I), .Q(Out1), .Clock(Clock));
  Register R2(.FunSel(FunSel), .E(~RegSel[2]), .I(I), .Q(Out2), .Clock(Clock));
  Register R3(.FunSel(FunSel), .E(~RegSel[1]), .I(I), .Q(Out3), .Clock(Clock));
  Register R4(.FunSel(FunSel), .E(~RegSel[0]), .I(I), .Q(Out4), .Clock(Clock));

  Register S1(.FunSel(FunSel), .E(~ScrSel[3]), .I(I), .Q(Out5), .Clock(Clock));
  Register S2(.FunSel(FunSel), .E(~ScrSel[2]), .I(I), .Q(Out6), .Clock(Clock));
  Register S3(.FunSel(FunSel), .E(~ScrSel[1]), .I(I), .Q(Out7), .Clock(Clock));
  Register S4(.FunSel(FunSel), .E(~ScrSel[0]), .I(I), .Q(Out8), .Clock(Clock));

  always @(*) begin
    case (OutASel)
      3'b000: OutA = Out1;
      3'b001: OutA = Out2;
      3'b010: OutA = Out3;
      3'b011: OutA = Out4;
      3'b100: OutA = Out5;
      3'b101: OutA = Out6;
      3'b110: OutA = Out7;
      3'b111: OutA = Out8;
    endcase

    case (OutBSel)
      3'b000: OutB = Out1;
      3'b001: OutB = Out2;
      3'b010: OutB = Out3;
      3'b011: OutB = Out4;
      3'b100: OutB = Out5;
      3'b101: OutB = Out6;
      3'b110: OutB = Out7;
      3'b111: OutB = Out8;
    endcase
  end
endmodule