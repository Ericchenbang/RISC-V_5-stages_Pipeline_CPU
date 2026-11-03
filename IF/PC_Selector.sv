`include "opcode_def.sv"

module PC_Selector (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic       BrEq,
    input  logic       BrLt,
    output logic       PC_Sel
);

always_comb begin
    case(opcode)
        JAL, JALR: PC_Sel = 1'b1;
        B_TYPE: begin
            case(funct3)
                3'b000: PC_Sel = BrEq;      // BEQ
                3'b001: PC_Sel = ~BrEq;     // BNE
                3'b100, 3'b110: PC_Sel = BrLt;   // BLT, BLTU
                3'b101, 3'b111: PC_Sel = ~BrLt;  // BGE, BGEU
                default: PC_Sel = 1'b0;
            endcase
        end
        default: PC_Sel = 1'b0;
    endcase
end
endmodule