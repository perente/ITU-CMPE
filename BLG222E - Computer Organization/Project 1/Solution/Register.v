`timescale 1ns / 1ps
module Register(
    input wire E,
    input wire [2:0] FunSel,
    input wire [15:0] I,
    input wire Clock,
    output reg [15:0] Q
);
    always @(posedge Clock) begin
        case (E)
            1'b0: Q = Q;
            1'b1: begin
              case (FunSel)
                3'b000: Q = Q - 1;
                3'b001: Q = Q + 1;
                3'b010: Q = I;
                3'b011: Q = 0;
                3'b100: begin
                    Q [15:8] = 0;
                    Q [7:0] = I [7:0];
                end
                3'b101: Q[7:0] = I[7:0];
                3'b110: Q[15:8] = I[7:0];
                3'b111: begin
                  case (I[7])
                    1'b0: Q[15:8] = 0;
                    1'b1: Q[15:8] = 8'b11111111;
                  endcase
                  Q[7:0] = I[7:0];
                end
              endcase
            end
        endcase
    end
endmodule