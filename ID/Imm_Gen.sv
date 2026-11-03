`include "opcode_def.sv"

module Imm_Gen (
    input   logic   [31:0]  inst,
    output  logic   [31:0]  imm
);

logic [6:0] opcode;
assign opcode = inst[6:0];

always_comb begin
    case(opcode)
        I_TYPE, LOAD, JALR, FP_LOAD: begin
            imm = {{20{inst[31]}}, inst[31:20]};
        end
        STORE, FP_STORE: begin
            imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        end
        B_TYPE: begin
            imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        end
        AUIPC, LUI_OP: begin
            imm = {inst[31:12], 12'h000};
        end
        JAL: begin
            imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
        end
        default: begin
            imm = 32'hxxxx_xxxx;
        end
    endcase
end

endmodule