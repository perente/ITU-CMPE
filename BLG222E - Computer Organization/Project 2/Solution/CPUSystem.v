`timescale 1ns / 1ps

module Counter(
    input wire Clock,
    input wire CInc,
    input wire CReset,
    output reg [7:0] SC
);


always @(posedge Clock) begin
    if (CReset == 1'b1) SC <= 8'b00000001;
    else if (CInc) begin
        if (SC == 8'b10000000) SC <= 8'b00000001;
        else SC <= SC << 1;
    end
end

endmodule

module CPUSystem(
    input wire Clock,
    input wire Reset,
    output reg [7:0] T
);
  reg [2:0] RF_FunSel;
    reg [2:0] ARF_FunSel;
    reg [4:0] ALU_FunSel;
    reg [2:0] RF_OutASel;
    reg [2:0] RF_OutBSel;
    reg [3:0] RF_RegSel;
    reg [3:0] RF_ScrSel;
    reg [1:0] ARF_OutCSel;
    reg [1:0] ARF_OutDSel;
    reg [2:0] ARF_RegSel;
    reg [1:0] MuxASel;
    reg [1:0] MuxBSel;
    reg MuxCSel;
    reg ALU_WF;
    reg IR_LH;
    reg IR_Write;
    reg Mem_WR;
    reg Mem_CS;
    reg [15:0] OutC;
    reg [15:0] OutD;
    reg [15:0] OutA;
    reg [15:0] OutB;
    reg [15:0] IROut;
    reg CInc;
    reg CReset;
    wire [7:0] SC;
  reg [7:0] ADDRESS;
  reg [5:0] OPCODE;
  reg [1:0] RSEL;
  reg S;
  reg [2:0] DSTREG;
  reg [2:0] SREG1;
  reg [2:0] SREG2;

  Counter Ct(.CInc(CInc), .CReset(CReset), .SC(SC), .Clock(Clock));

  ArithmeticLogicUnitSystem _ALUSystem(.RF_FunSel(RF_FunSel), 
  .ARF_FunSel(ARF_FunSel), 
  .ALU_FunSel(ALU_FunSel),
  .RF_OutASel(RF_OutASel),
  .RF_RegSel(RF_RegSel),
  .Clock(Clock),
  .RF_OutBSel(RF_OutBSel),
  .RF_ScrSel(RF_ScrSel),
  .ARF_OutCSel(ARF_OutCSel),
  .ARF_OutDSel(ARF_OutDSel),
  .ARF_RegSel(ARF_RegSel),
  .MuxASel(MuxASel),
  .MuxBSel(MuxBSel),
  .MuxCSel(MuxCSel),
  .ALU_WF(ALU_WF),
  .IR_LH(IR_LH),
  .IR_Write(IR_Write),
  .Mem_WR(Mem_WR),
  .Mem_CS(Mem_CS)
  );

  always @(*) begin
    if (Reset == 0) begin
      CReset = 1'b1;
      T = 1;
      ARF_RegSel = 3'b000;
      RF_RegSel = 4'b0000;
      RF_ScrSel = 4'b0000;
      RF_FunSel = 3'b011;
      ARF_FunSel = 3'b011;
    end
  end

  always @(*) begin
    T = SC;
    case (SC)
        8'b00000001: begin
            ARF_RegSel = 3'b111;
            RF_RegSel = 4'b1111;
            RF_ScrSel = 4'b1111;
            CReset = 1'b0;
            ARF_OutDSel = 2'b00;
            Mem_WR = 1'b0;
            Mem_CS = 1'b0;
            IR_LH = 0;
            IR_Write = 1;
            CInc = 1'b1;
        end

        8'b00000010: begin
            CInc = 1'b1;
            ARF_RegSel = 3'b011;
            ARF_FunSel = 3'b001;
            ARF_OutDSel = 2'b00;
            Mem_WR = 1'b0;
            Mem_CS = 1'b0;
            IR_LH = 1;
            IR_Write = 1;
        end 

        default: begin
            DSTREG = _ALUSystem.IROut[8:6];
            SREG1 = _ALUSystem.IROut[5:3];
            SREG2 = _ALUSystem.IROut[2:0];
            S = _ALUSystem.IROut[9];
            RSEL = _ALUSystem.IROut[10:8];
            ADDRESS = _ALUSystem.IROut[7:0];
            OPCODE = _ALUSystem.IROut[15:10];
            case (OPCODE)
            6'b000000: begin
            if (SC[2]) begin
              Mem_CS = 1'b1;
              ARF_RegSel = 3'b111;
              ARF_OutCSel = 2'b00;
              MuxASel = 2'b01;
              RF_RegSel = 4'b0111;
              RF_FunSel = 3'b010;
              CInc = 1'b1;
            end
            if (SC[3]) begin
              MuxASel = 2'b11;
              RF_RegSel = 4'b1011;
              RF_FunSel = 3'b010;
              CInc = 1'b1;
            end
            if (SC[4]) begin
              RF_RegSel = 4'b1111;
              RF_OutASel = 3'b000;
              RF_OutBSel = 3'b001;
              ALU_FunSel = 5'b10100;
              MuxBSel = 2'b00;
              ARF_RegSel = 3'b011;
              ARF_FunSel = 3'b010;
              CReset = 1'b1;
            end
            end

            6'b000001: begin
              if (_ALUSystem.FlagsOut[0] == 0) begin
                if (SC[2]) begin
                  Mem_CS = 1'b1;
                  ARF_RegSel = 3'b111;
                  ARF_OutCSel = 2'b00;
                  MuxASel = 2'b01;
                  RF_RegSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  CInc = 1'b1;
                end
                if (SC[3]) begin
                  MuxASel = 2'b11;
                  RF_RegSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  CInc = 1'b1;
                end
                if (SC[4]) begin
                  RF_RegSel = 4'b1111;
                  RF_OutASel = 3'b000;
                  RF_OutBSel = 3'b001;
                  ALU_FunSel = 5'b10100;
                  MuxBSel = 2'b00;
                  ARF_RegSel = 3'b011;
                  ARF_FunSel = 3'b010;
                  CReset = 1'b1;
                end
              end
            else CReset = 1'b1;
            end

            6'b000010: begin
              if (_ALUSystem.FlagsOut[0] == 1) begin
                if (SC[2]) begin
                  // RSEL = _ALUSystem.IROut[10:8];
                  // ADDRESS = _ALUSystem.IROut[7:0];
                  Mem_CS = 1'b1;
                  ARF_RegSel = 3'b111;
                  ARF_OutCSel = 2'b00;
                  MuxASel = 2'b01;
                  RF_RegSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  CInc = 1'b1;
                end
                if (SC[3]) begin
                  MuxASel = 2'b11;
                  RF_RegSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  CInc = 1'b1;
                end
                if (SC[4]) begin
                  RF_RegSel = 4'b1111;
                  RF_OutASel = 3'b000;
                  RF_OutBSel = 3'b001;
                  ALU_FunSel = 5'b10100;
                  MuxBSel = 2'b00;
                  ARF_RegSel = 3'b011;
                  ARF_FunSel = 3'b010;
                  CReset = 1'b1;
                end
            else CReset = 1'b1;
              end
            end

            6'b000011: begin
              if (SC[2]) begin
                // RSEL = _ALUSystem.IROut[10:8];
                // ADDRESS = _ALUSystem.IROut[7:0];
                ARF_RegSel = 3'b110;
                ARF_FunSel = 3'b001;
                ARF_OutDSel = 2'b11;
                Mem_WR = 1'b0;
                Mem_CS = 1'b0;
                MuxASel = 2'b10;
                case (RSEL)
                    2'b00: RF_RegSel = 4'b0111;
                    2'b01: RF_RegSel = 4'b1011;
                    2'b10: RF_RegSel = 4'b1101;
                    2'b11: RF_RegSel = 4'b1110;
                endcase
                RF_FunSel = 3'b010;
                CReset = 1'b1;
                Mem_CS = 1'b1;
                end
            end

            6'b000100: begin
                //   RF_FunSel = 3'b010;
                //   ARF_RegSel = 3'b110;
                //   ARF_FunSel = 3'b000;
                if (SC[2]) begin
                  // RSEL = _ALUSystem.IROut[10:8];
                  // ADDRESS = _ALUSystem.IROut[7:0];
                    case (RSEL)
                        2'b00: RF_OutASel = 3'b000;
                        2'b01: RF_OutASel = 3'b001;
                        2'b10: RF_OutASel = 3'b010;
                        2'b11: RF_OutASel = 3'b011;
                    endcase
                    ALU_FunSel = 5'b10000;
                    MuxCSel = 1'b0;
                    ARF_OutDSel = 2'b11;
                    Mem_WR = 1'b1;
                    Mem_CS = 1'b0;
                    CInc = 1;
                    end
                if (SC[3]) begin
                    ARF_RegSel = 3'b110;
                    ARF_FunSel = 3'b001;
                    Mem_WR = 1'b0;
                    Mem_CS = 1'b1;
                    CReset = 1;
                    end
                end

            6'b000101: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 1) begin
                  ALU_FunSel = 5'b10000;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
              endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                  MuxBSel = 2'b01;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                if (DSTREG[2] == 0) begin
                  ARF_FunSel = 3'b000;
                end
                if (DSTREG[2] == 1) begin
                  RF_FunSel = 3'b000;
                end
                CReset = 1'b1;
            end
            end

            6'b000110: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 1) begin
                  ALU_FunSel = 5'b10000;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
              endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                  MuxBSel = 2'b01;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                if (DSTREG[2] == 0) begin
                  ARF_FunSel = 3'b001;
                  ARF_RegSel = 3'b111;
                end
                if (DSTREG[2] == 1) begin
                  RF_FunSel = 3'b001;
                  RF_RegSel = 4'b1111;
                end
                CReset = 1'b1;
            end
            end

            6'b000111: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 1) begin
                  ALU_FunSel = 5'b11011;
                end
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b11011;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b11011;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
            end
            if (SC[4]) begin
                if (DSTREG[2] == 0) begin
                  ARF_RegSel = 3'b111;
                end
                if (DSTREG[2] == 1) begin
                  RF_RegSel = 4'b1111;
                end
                CReset = 1'b1;
            end
            end

            6'b001000: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 1) begin
                  ALU_FunSel = 5'b11100;
                end
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b11100;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b11100;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
            end
            if (SC[4]) begin
                if (DSTREG[2] == 0) begin
                  ARF_RegSel = 3'b111;
                end
                if (DSTREG[2] == 1) begin
                  RF_RegSel = 4'b1111;
                end
                CReset = 1'b1;
            end
            end

            6'b001001: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 1) begin
                  ALU_FunSel = 5'b11101;
                end
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b11101;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b11101;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
            end
            if (SC[4]) begin
                if (DSTREG[2] == 0) begin
                  ARF_RegSel = 3'b111;
                end
                if (DSTREG[2] == 1) begin
                  RF_RegSel = 4'b1111;
                end
                CReset = 1'b1;
            end
            end

            6'b001010: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 1) begin
                  ALU_FunSel = 5'b11110;
                end
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b11110;
                    MuxBSel = 2'b00;
                    ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b11110;
                    MuxASel = 2'b00;
                    RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
            end
            if (SC[4]) begin
                if (DSTREG[2] == 0) begin
                  ARF_RegSel = 3'b111;
                end
                if (DSTREG[2] == 1) begin
                  RF_RegSel = 4'b1111;
                end
                CReset = 1'b1;
            end
            end

            6'b001011: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 1) begin
                  ALU_FunSel = 5'b11111;
                end
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b11111;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b11111;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
            end
            if (SC[4]) begin
                if (DSTREG[2] == 0) begin
                  ARF_RegSel = 3'b111;
                end
                if (DSTREG[2] == 1) begin
                  RF_RegSel = 4'b1111;
                end
                CReset = 1'b1;
            end
            end

            6'b001100: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10111;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10111;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10111;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10111;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
            end
            end

            6'b001101: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b11000;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b11000;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b11000;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b11000;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
            end
            end

            6'b001110: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 1) begin
                  ALU_FunSel = 5'b10010;
                end
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b10010;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b10010;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CInc = 1'b1;
            end
            if (SC[4]) begin
                if (DSTREG[2] == 0) begin
                  ARF_RegSel = 3'b111;
                end
                if (DSTREG[2] == 1) begin
                  RF_RegSel = 4'b1111;
                end
                CReset = 1'b1;
            end
            end

            6'b001111: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b11001;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b11001;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b11001;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b11001;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
            end
            end

            6'b010000: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b11001;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b11001;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b11001;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b11001;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
            end
            end

            6'b010001: begin
              if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (DSTREG)
                  3'b000: begin ARF_RegSel = 3'b011; MuxBSel = 2'b11; end
                  3'b001: begin ARF_RegSel = 3'b011; MuxBSel = 2'b11; end
                  3'b010: begin ARF_RegSel = 3'b110; MuxBSel = 2'b11; end
                  3'b011: begin ARF_RegSel = 3'b101; MuxBSel = 2'b11; end
                  3'b100: begin RF_RegSel = 4'b0111; MuxASel = 2'b11; end
                  3'b101: begin RF_RegSel = 4'b1011; MuxASel = 2'b11; end
                  3'b110: begin RF_RegSel = 4'b1101; MuxASel = 2'b11; end
                  3'b111: begin RF_RegSel = 4'b1110; MuxASel = 2'b11; end
                endcase
                if (DSTREG[2] == 0) begin
                  ARF_FunSel = 3'b110;
                end
                if (DSTREG[2] == 1) begin
                  RF_FunSel = 3'b110;
                end
                CReset = 1'b1;
              end
            end

            6'b010010: begin
                if (SC[2]) begin
                    // RSEL = _ALUSystem.IROut[10:8];
                    // ADDRESS = _ALUSystem.IROut[7:0];
                    ARF_OutDSel = 2'b10;
                    Mem_WR = 1'b0;
                    Mem_CS = 1'b0;
                    MuxASel = 2'b10;
                    case (RSEL)
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    RF_FunSel = 3'b010;
                    CReset = 1'b1;
                    // Mem_CS = 1'b1;
                end
            end

            6'b010011: begin
                if (SC[2]) begin
                    // RSEL = _ALUSystem.IROut[10:8];
                    // ADDRESS = _ALUSystem.IROut[7:0];
                    case (RSEL)
                        2'b00: RF_OutASel = 3'b000;
                        2'b01: RF_OutASel = 3'b001;
                        2'b10: RF_OutASel = 3'b010;
                        2'b11: RF_OutASel = 3'b011;
                    endcase
                    ALU_FunSel = 5'b10000;
                    MuxCSel = 1'b0;
                    Mem_WR = 1'b1;
                    Mem_CS = 1'b0;
                    ARF_OutDSel = 2'b10;
                    CReset = 1'b1;
                    // Mem_CS = 1'b1;
                end
            end

            6'b010100: begin
              if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (DSTREG)
                  3'b000: begin ARF_RegSel = 3'b011; MuxBSel = 2'b11; end
                  3'b001: begin ARF_RegSel = 3'b011; MuxBSel = 2'b11; end
                  3'b010: begin ARF_RegSel = 3'b110; MuxBSel = 2'b11; end
                  3'b011: begin ARF_RegSel = 3'b101; MuxBSel = 2'b11; end
                  3'b100: begin RF_RegSel = 4'b0111; MuxASel = 2'b11; end
                  3'b101: begin RF_RegSel = 4'b1011; MuxASel = 2'b11; end
                  3'b110: begin RF_RegSel = 4'b1101; MuxASel = 2'b11; end
                  3'b111: begin RF_RegSel = 4'b1110; MuxASel = 2'b11; end
                endcase
                if (DSTREG[2] == 0) begin
                  ARF_FunSel = 3'b101;
                end
                if (DSTREG[2] == 1) begin
                  RF_FunSel = 3'b101;
                end
                CReset = 1'b1;
              end
            end

            6'b010101: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10100;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10100;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10100;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10100;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
            end
            end

            6'b010110: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10101;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10101;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10101;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10101;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
            end
            end
            6'b010111: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10110;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10110;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10110;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10110;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
            end
            end

            6'b011000: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                if (S == 1'b1) ALU_WF = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 1) begin
                  ALU_FunSel = 5'b10000;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                if (S == 1'b1) ALU_WF = 1'b1;
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
              endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                  MuxBSel = 2'b01;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
                end
            end

            6'b011001: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                if (S == 1'b1) ALU_WF = 1'b1;
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10100;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10100;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10100;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10100;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
              end
            end

            6'b011010: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                if (S == 1'b1) ALU_WF = 1'b1;
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10110;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10110;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10110;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10110;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
            end
            end

            6'b011011: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                if (S == 1'b1) ALU_WF = 1'b1;
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10111;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b10111;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10111;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b10111;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
            end
            end

            6'b011100: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                if (S == 1'b1) ALU_WF = 1'b1;
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b11000;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b11000;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b11000;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b11000;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
            end
            end

            6'b011101: begin
            if (SC[2]) begin
                // DSTREG = _ALUSystem.IROut[8:6];
                // SREG1 = _ALUSystem.IROut[5:3];
                // SREG2 = _ALUSystem.IROut[2:0];
                // S = _ALUSystem.IROut[9];
                Mem_CS = 1'b1;
                case (SREG1)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutASel = 3'b000;
                    3'b101: RF_OutASel = 3'b001;
                    3'b110: RF_OutASel = 3'b010;
                    3'b111: RF_OutASel = 3'b011;
                endcase
                if (SREG1[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b100;
                end
                CInc = 1'b1;
                end
            if (SC[3]) begin
                case (SREG2)
                    3'b000: ARF_OutCSel = 2'b00;
                    3'b001: ARF_OutCSel = 2'b01;
                    3'b010: ARF_OutCSel = 2'b11;
                    3'b011: ARF_OutCSel = 2'b10;
                    3'b100: RF_OutBSel = 3'b000;
                    3'b101: RF_OutBSel = 3'b001;
                    3'b110: RF_OutBSel = 3'b010;
                    3'b111: RF_OutBSel = 3'b011;
                endcase
                if (SREG2[2] == 0) begin
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b1011;
                  RF_FunSel = 3'b010;
                  RF_OutBSel = 3'b101;
                end
                CInc = 1'b1;
                end
            if (SC[4]) begin
                if (S == 1'b1) ALU_WF = 1'b1;
                case (DSTREG)
                  3'b000: ARF_RegSel = 3'b011;
                  3'b001: ARF_RegSel = 3'b011;
                  3'b010: ARF_RegSel = 3'b110;
                  3'b011: ARF_RegSel = 3'b101;
                  3'b100: RF_RegSel = 4'b0111;
                  3'b101: RF_RegSel = 4'b1011;
                  3'b110: RF_RegSel = 4'b1101;
                  3'b111: RF_RegSel = 4'b1110;
                endcase
                if (DSTREG[2] == 0 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b11001;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 0) begin
                    ALU_FunSel = 5'b11001;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 0 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b11001;
                  MuxBSel = 2'b00;
                  ARF_FunSel = 3'b010;
                end
                if (DSTREG[2] == 1 & SREG1[2] == 1) begin
                    ALU_FunSel = 5'b11001;
                  MuxASel = 2'b00;
                  RF_FunSel = 3'b010;
                end
                CReset = 1'b1;
              end
            end

            6'b011110: begin
              if (SC[2]) begin
                  // RSEL = _ALUSystem.IROut[10:8];
                  // ADDRESS = _ALUSystem.IROut[7:0];
                  ARF_OutCSel = 2'b00;
                  MuxASel = 2'b01;
                  RF_ScrSel = 4'b0111;
                  RF_FunSel = 3'b010;
                  RF_OutASel = 3'b100;
                  ALU_FunSel = 5'b10000;
                  MuxCSel = 1'b0;
                  Mem_CS = 1'b1;
                  CInc = 1'b1;
              end
              if (SC[3]) begin
                  ARF_OutDSel = 2'b11;
                  Mem_WR = 1'b1;
                  Mem_CS = 1'b0;
                  CInc = 1'b1;
              end
              if (SC[4]) begin
                Mem_CS = 1'b1;
                Mem_WR = 1'b0;
                case (RSEL)
                    2'b00: RF_OutASel = 3'b000;
                    2'b01: RF_OutASel = 3'b001;
                    2'b10: RF_OutASel = 3'b010;
                    2'b11: RF_OutASel = 3'b011;
                endcase
                ALU_FunSel = 5'b10000;
                MuxBSel = 2'b00;
                ARF_RegSel = 3'b011;
                ARF_FunSel = 3'b010;
                CReset = 1'b1;
              end
            end
            6'b011111: begin
              if (SC[2]) begin
                  // RSEL = _ALUSystem.IROut[10:8];
                  // ADDRESS = _ALUSystem.IROut[7:0];
                  ARF_OutDSel = 2'b11;
                  Mem_WR = 1'b0;
                  Mem_CS = 1'b0;
                  MuxBSel = 2'b10;
                  CInc = 1'b1;
              end
              if (SC[3]) begin
                  Mem_CS = 1'b1;
                  ARF_RegSel = 3'b011;
                  ARF_FunSel = 3'b010;
                  CReset = 1'b1;
              end
              end   

            6'b100000: begin                                   
              // RSEL = _ALUSystem.IROut[10:8];
              // ADDRESS = _ALUSystem.IROut[7:0];
              if (SC[2]) begin
                MuxASel = 2'b11;
                Mem_CS = 1'b1;
                case (RSEL)
                    2'b00: RF_RegSel = 4'b0111;
                    2'b01: RF_RegSel = 4'b1011;
                    2'b10: RF_RegSel = 4'b1101;
                    2'b11: RF_RegSel = 4'b1110;
                endcase
                RF_FunSel = 3'b010;
                CReset = 1'b1;
              end
            end
            
            6'b100001: begin                                   
              // RSEL = _ALUSystem.IROut[10:8];
              // ADDRESS = _ALUSystem.IROut[7:0];
              CReset = 1'b1;
            end
            endcase
        end
    endcase
  end
  endmodule