`timescale 1ns / 1ps
module ArithmeticLogicUnit (
input wire [15:0] A,
input wire [15:0] B,
input wire Clock,
input wire WF,
input wire [4:0] FunSel,
output reg [15:0] ALUOut,
output reg [3:0] FlagsOut
);
reg Z=0;
reg C=0;
reg N=0;
reg O=0;
reg inversed=0;

always @(posedge Clock) begin
  if (WF) FlagsOut = {Z, C, N, O};
end


always @(*) begin
    Z=FlagsOut[3];
    C=FlagsOut[2];
    N=FlagsOut[1];
    O=FlagsOut[0];
    case (FunSel) 
        5'b00000: begin
          ALUOut[15:8] = 0;
          ALUOut[7:0] = A[7:0];
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
          N = ALUOut[7];
        end
        5'b00001: begin
          ALUOut[15:8] = 0;
          ALUOut[7:0] = B[7:0];
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
          N = ALUOut[7];
        end
        5'b00010: begin
          ALUOut[15:8] = 0;
          ALUOut[7:0] = ~A[7:0];
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
          N = ALUOut[7];
        end
        5'b00011: begin
          ALUOut[15:8] = 0;
          ALUOut[7:0] = ~B[7:0];
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
          N = ALUOut[7];
        end
        5'b00100: begin
          O = 0;
            {C, ALUOut[7:0]} = {1'b0, A[7:0]} + {1'b0, B[7:0]};
            ALUOut[15:8] = 0;
            if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
        N = ALUOut[7];
        if (A[7] == B[7] && ALUOut[7] != A[7]) O = 1;
        end
        5'b00101: begin
          O = 0;
          ALUOut[15:8] = 0;
          {C, ALUOut[7:0]} = {1'b0, A[7:0]} + {1'b0, B[7:0]} + {8'b0, FlagsOut[2]};
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
        N = ALUOut[7];
        if (A[7] == B[7] && ALUOut[7] != A[7]) O = 1;

        end
        5'b00110: begin
          O = 0;
          {inversed, ALUOut[7:0]} = {1'b0, A[7:0]} + {1'b0, (~B[7:0]) + 8'd1};
          C = ~inversed;
          ALUOut[15:8] = 0;
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
        N = ALUOut[7];
        if (A[7] != B[7] && ALUOut[7] != A[7]) O = 1;
        end
        5'b00111: begin
          ALUOut[7:0] = A[7:0] & B[7:0];
          ALUOut[15:8] = 0;
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
          N = ALUOut[7];
        end
        5'b01000: begin
          ALUOut[7:0] = A[7:0] | B[7:0];
          ALUOut[15:8] = 0;
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
          N = ALUOut[7];
        end
        5'b01001: begin
          ALUOut[7:0] = A[7:0] ^ B[7:0];
          ALUOut[15:8] = 0;
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
          N = ALUOut[7];
        end
        5'b01010: begin
          ALUOut[7:0] = ~(A[7:0] & B[7:0]);
          ALUOut[15:8] = 0;
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
          N = ALUOut[7];
        end
        5'b01011: begin
          {C, ALUOut[7:0]} = {1'b0, A[7:0]} << 1;
          ALUOut[15:8] = 0;
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
        N = ALUOut[7];
        end
        5'b01100: begin
          {ALUOut[7:0], C} = {A[7:0], 1'b0} >> 1;
          ALUOut[15:8] = 0;
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
        N = ALUOut[7];
        end
        5'b01101: begin
          {ALUOut[7:0], C} = {A[7:0], 1'b0} >> 1;
          ALUOut[15:8] = 0;
          ALUOut[7] = ALUOut[6];
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
        end
        5'b01110: begin
          ALUOut[7:0] = {A[6:0], FlagsOut[2]}; 
          C = A[7];
          ALUOut[15:8] = 0;
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
        N = ALUOut[7];
        end
        5'b01111: begin
          ALUOut[7:0] = {FlagsOut[2], A[7:1]}; 
          C = A[0];
          ALUOut[15:8] = 0;
          if (ALUOut[7:0] == 8'd0) Z = 1;
          else Z = 0;
        N = ALUOut[7];
        end
        5'b10000: begin
            ALUOut = A;
            if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end
        5'b10001: begin 
          ALUOut = B; 
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end
        5'b10010: begin 
          ALUOut = ~A;
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end
        5'b10011: begin 
          ALUOut = ~B;
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end

        5'b10100: begin 
          O = 0;
          {C, ALUOut} = {1'b0, A} + {1'b0, B};
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        if (A[15] == B[15] && ALUOut[15] != A[15]) O = 1;
        end

        5'b10101: begin 
          O = 0;
          {C, ALUOut[15:0]} <= {1'b0, A[15:0]} + {1'b0, B[15:0]} + {16'b0, FlagsOut[2]};
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        if (A[15] == B[15] && ALUOut[15] != A[15]) O = 1;
        end

        5'b10110: begin 
          O = 0;
          {C, ALUOut} = {1'b0, A} + {1'b0, (~B+ 16'd1)};
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        if (A[15] != B[15] && ALUOut[15] != A[15]) O = 1;
        end

        5'b10111: begin 
          ALUOut = A & B;
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end
        5'b11000: begin 
          ALUOut = A | B;
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end
        5'b11001: begin 
          ALUOut = A ^ B;
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end
        5'b11010: begin 
          ALUOut = ~(A & B);
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end

        5'b11011: begin 
          {C, ALUOut} = {1'b0, A} << 1;
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end

        5'b11100: begin 
          {ALUOut, C} = {A, 1'b0} >> 1;
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end

        5'b11101: begin 
          {ALUOut, C} = {A, 1'b0} >> 1;
          ALUOut[15] = ALUOut[14];
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        end

        5'b11110: begin 
          ALUOut = {A[14:0], FlagsOut[2]};
          C = A[15];
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end

        5'b11111: begin 
          ALUOut = {FlagsOut[2], A[15:1]};
          C = A[0];
          if (ALUOut == 16'd0) Z = 1;
          else Z = 0;
        N = ALUOut[15];
        end
    endcase
end
endmodule