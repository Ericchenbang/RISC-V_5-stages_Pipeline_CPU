module Forwarding(
    input   logic   [6:0]   EX_opcode,
    input   logic   [4:0]   EX_rs1,
    input   logic   [4:0]   EX_rs2,
    input   logic   [1:0]   EX_ALU_ASel,
    input   logic   [1:0]   EX_ALU_BSel,

    input   logic   [4:0]   M_rd,
    input   logic           M_RegWEn,
    input   logic           M_FPU_RegWEn,
    input   logic           M_Is_CSR,
    input   logic           M_Forward_Result_Ready,

    input   logic   [4:0]   WB_rd,
    input   logic           WB_RegWEn,
    input   logic           WB_FPU_RegWEn,

    // 00: use the value read from the register file
    // 01: forward the M-stage write-back value
    // 10: forward the WB-stage final write-back value
    // 11: M-stage producer matches, but its result is not ready; stall required
    output  logic   [1:0]   FW_ALU_ASel,
    output  logic   [1:0]   FW_ALU_BSel,
    output  logic   [1:0]   FW_FPU_ASel,
    output  logic   [1:0]   FW_FPU_BSel,
    output  logic   [1:0]   FW_Store_Data_Sel,
    output  logic   [1:0]   FW_FP_Store_Data_Sel,
    output  logic           FW_Stall
);
`include "opcode_def.sv"

logic uses_int_rs1;
logic uses_int_rs2;
logic uses_fp_rs1;
logic uses_fp_rs2;
logic uses_int_store_data;
logic uses_fp_store_data;

logic M_int_rs1_match;
logic WB_int_rs1_match;
logic M_int_rs2_match;
logic WB_int_rs2_match;
logic M_fp_rs1_match;
logic WB_fp_rs1_match;
logic M_fp_rs2_match;
logic WB_fp_rs2_match;
logic M_result_available;

// Decode source usage from the instruction. Do not infer register-file type
// from a whole-instruction FP flag: FLW/FSW use integer rs1 for the address.
always_comb begin
    uses_int_rs1       = 1'b0;
    uses_int_rs2       = 1'b0;
    uses_fp_rs1        = 1'b0;
    uses_fp_rs2        = 1'b0;
    uses_int_store_data= 1'b0;
    uses_fp_store_data = 1'b0;
    
    case (EX_opcode)
        R_TYPE, DSP: begin
            uses_int_rs1 = 1'b1;
            uses_int_rs2 = 1'b1;
        end
        I_TYPE, LOAD, FP_LOAD: begin
            uses_int_rs1 = 1'b1;
        end
        STORE: begin
            uses_int_rs1        = 1'b1;  // base address
            uses_int_store_data = 1'b1;  // store payload (rs2)
        end
        FP_STORE: begin
            uses_int_rs1       = 1'b1;   // base address is an integer register
            uses_fp_store_data = 1'b1;   // store payload is an FP register
        end
        FPR_TYPE: begin
            uses_fp_rs1 = 1'b1;
            uses_fp_rs2 = 1'b1;
        end
    endcase
end

// Integer x0 is hardwired to zero and is never a producer. FP register f0 is
// writable, so it must remain eligible for FP forwarding.
assign M_int_rs1_match  = M_RegWEn && (M_rd != 5'd0) && (M_rd == EX_rs1);
assign WB_int_rs1_match = WB_RegWEn && (WB_rd != 5'd0) && (WB_rd == EX_rs1);
assign M_int_rs2_match  = M_RegWEn && (M_rd != 5'd0) && (M_rd == EX_rs2);
assign WB_int_rs2_match = WB_RegWEn && (WB_rd != 5'd0) && (WB_rd == EX_rs2);
assign M_fp_rs1_match   = M_FPU_RegWEn && (M_rd == EX_rs1);
assign WB_fp_rs1_match  = WB_FPU_RegWEn && (WB_rd == EX_rs1);
assign M_fp_rs2_match   = M_FPU_RegWEn && (M_rd == EX_rs2);
assign WB_fp_rs2_match  = WB_FPU_RegWEn && (WB_rd == EX_rs2);

// A CSR read result is produced in WB in this design. A load is available
// from M only when the memory interface asserts dm_valid.
assign M_result_available = M_Forward_Result_Ready && !M_Is_CSR;

function automatic logic [1:0] pick_forward(
    input logic source_used,
    input logic m_match,
    input logic wb_match,
    input logic m_ready
);
    begin
        if (!source_used)
            pick_forward = 2'b00;
        else if (m_match)
            pick_forward = m_ready ? 2'b01 : 2'b11;
        else if (wb_match)
            pick_forward = 2'b10;
        else
            pick_forward = 2'b00;
    end
endfunction

always_comb begin
    // The ALU operand muxes select register data only when their original
    // control chooses rs1/rs2. PC and immediate operands must not be forwarded.
    FW_ALU_ASel = pick_forward(
        uses_int_rs1 && (EX_ALU_ASel == 2'b00),
        M_int_rs1_match, WB_int_rs1_match, M_result_available
    );
    FW_ALU_BSel = pick_forward(
        uses_int_rs2 && (EX_ALU_BSel == 2'b00),
        M_int_rs2_match, WB_int_rs2_match, M_result_available
    );

    FW_FPU_ASel = pick_forward(
        uses_fp_rs1, M_fp_rs1_match, WB_fp_rs1_match, M_result_available
    );
    FW_FPU_BSel = pick_forward(
        uses_fp_rs2, M_fp_rs2_match, WB_fp_rs2_match, M_result_available
    );

    FW_Store_Data_Sel = pick_forward(
        uses_int_store_data, M_int_rs2_match, WB_int_rs2_match, M_result_available
    );
    FW_FP_Store_Data_Sel = pick_forward(
        uses_fp_store_data, M_fp_rs2_match, WB_fp_rs2_match, M_result_available
    );

    // Never fall through to an older WB producer when a younger matching M
    // producer is pending; the consumer must wait for the M result.
    FW_Stall = 1'b0;
    if (M_int_rs1_match && uses_int_rs1)
        FW_Stall = !M_result_available;
    if (M_int_rs2_match && uses_int_rs2)
        FW_Stall = !M_result_available;
    if (M_fp_rs1_match && uses_fp_rs1)
        FW_Stall = !M_result_available;
    if (M_fp_rs2_match && uses_fp_rs2)
        FW_Stall = !M_result_available;
    if (M_int_rs2_match && uses_int_store_data)
        FW_Stall = !M_result_available;
    if (M_fp_rs2_match && uses_fp_store_data)
        FW_Stall = !M_result_available;
end

endmodule
