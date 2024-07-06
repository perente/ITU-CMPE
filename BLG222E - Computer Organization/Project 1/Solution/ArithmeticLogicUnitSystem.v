`timescale 1ns / 1ps

module MUX_A(
    input wire [1:0] MuxASel,
    input wire [15:0] O1,
    input wire [15:0] O2,
    input wire [7:0] O3,
    input wire [15:0] O4,
    output reg [15:0] OutMuxA
);
    always@(*) begin
        case (MuxASel)
            2'b00: OutMuxA = O1;
            2'b01: OutMuxA = O2;
            2'b10: begin
                OutMuxA[7:0] = O3;
                OutMuxA[15:8] = 8'd0;
            end
            2'b11: begin
                OutMuxA[7:0] = O4[7:0];
                OutMuxA[15:8] = 8'd0;
            end
        endcase
    end
endmodule

module MUX_B(
    input wire [1:0] MuxBSel,
    input wire [15:0] O1,
    input wire [15:0] O2,
    input wire [7:0] O3,
    input wire [15:0] O4,
    output reg [15:0] OutMuxB
);
    always@(*) begin
        case (MuxBSel)
            2'b00: OutMuxB = O1;
            2'b01: OutMuxB = O2;
            2'b10: begin
                OutMuxB[7:0] = O3;
                OutMuxB[15:8] = 8'd0;
            end
            2'b11: begin
                OutMuxB[7:0] = O4[7:0];
                OutMuxB[15:8] = 8'd0;
            end
        endcase
    end
endmodule

module MUX_C(
    input wire MuxCSel,
    input wire [15:0] O1,
    output reg [7:0] OutMuxC
);
    always@(*) begin
        case (MuxCSel)
            1'b0: OutMuxC = O1[7:0];
            1'b1: OutMuxC = O1[15:8];
        endcase
    end
endmodule

module ArithmeticLogicUnitSystem (
    input wire [2:0] RF_FunSel,
    input wire [2:0] ARF_FunSel,
    input wire [4:0] ALU_FunSel,
    input wire [2:0] RF_OutASel,
    input wire [2:0] RF_OutBSel,
    input wire [3:0] RF_RegSel,
    input wire [3:0] RF_ScrSel,
    input wire [1:0] ARF_OutCSel,
    input wire [1:0] ARF_OutDSel,
    input wire [2:0] ARF_RegSel,
    input wire [1:0] MuxASel,
    input wire [1:0] MuxBSel,
    input wire MuxCSel,
    input wire ALU_WF,
    input wire IR_LH,
    input wire IR_Write,
    input wire Clock,
    input wire Mem_WR,
    input wire Mem_CS
); 
    wire [3:0] FlagsOut;
    wire [15:0] ALUOut;
    wire [15:0] OutC;
    wire [15:0] OutD;
    wire [15:0] OutA;
    wire [15:0] OutB;
    wire [15:0] IROut;
    wire [15:0] MuxAOut;
    wire [15:0] MuxBOut;
    wire [7:0] MuxCOut;
    wire [7:0] MemOut;
    wire [15:0] Address;
    wire [7:0] Data;

    ArithmeticLogicUnit ALU(.FunSel(ALU_FunSel), .A(OutA), .B(OutB), .WF(ALU_WF), .ALUOut(ALUOut), .Clock(Clock), .FlagsOut(FlagsOut));
    AddressRegisterFile ARF(.FunSel(ARF_FunSel), .OutCSel(ARF_OutCSel), .OutDSel(ARF_OutDSel), .OutC(OutC), .OutD(OutD), .RegSel(ARF_RegSel), .I(MuxBOut), .Clock(Clock));
    RegisterFile RF(.OutASel(RF_OutASel), .OutBSel(RF_OutBSel), .RegSel(RF_RegSel), .ScrSel(RF_ScrSel), .FunSel(RF_FunSel), .I(MuxAOut), .Clock(Clock), .OutA(OutA), .OutB(OutB));
    InstructionRegister IR(.I(MemOut), .LH(IR_LH), .Write(IR_Write), .IROut(IROut), .Clock(Clock));
    Memory MEM(.Address(OutD), .Data(MuxCOut), .WR(Mem_WR), .MemOut(MemOut), .CS(Mem_CS), .Clock(Clock));
    MUX_A MUXA(.MuxASel(MuxASel), .O1(ALUOut), .O2(OutC), .O3(MemOut), .O4(IROut), .OutMuxA(MuxAOut));
    MUX_B MUXB(.MuxBSel(MuxBSel), .O1(ALUOut), .O2(OutC), .O3(MemOut), .O4(IROut), .OutMuxB(MuxBOut));
    MUX_C MUXC(.MuxCSel(MuxCSel), .O1(ALUOut), .OutMuxC(MuxCOut));
    assign Address = OutD;
    assign Data = MuxCOut;

endmodule


