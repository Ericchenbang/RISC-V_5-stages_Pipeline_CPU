module EX_M_Reg(
    input   logic           clk,
    input   logic           rst,
    input   logic           stall,
    input   logic           flush,
    
    input   logic   [1:0]   EX_Wr_Back_Sel,
    input   logic           EX_Rs2_Data_Sel,
    input   logic   [1:0]   EX_MemRW,
    input   logic   [2:0]   EX_LDFilter_Sel,
    input   logic   [1:0]   EX_Wr_Data_Sel,
    input   logic           EX_RegWEn,
    input   logic           EX_FPU_RegWEn,
    input   logic           EX_Is_CSR,
    input   logic           EX_Is_WFI,
    input   logic           EX_Is_MRET,
    input   logic           EX_valid,

    input   logic   [31:0]  EX_PC,
    input   logic   [31:0]  EX_ALU_out,
    input   logic   [31:0]  EX_rs2_data,
    input   logic   [31:0]  EX_FPU_out,
    input   logic   [31:0]  EX_fp_rs2_data,
    input   logic   [31:0]  EX_inst,

    output  logic   [1:0]   M_Wr_Back_Sel,
    output  logic           M_Rs2_Data_Sel,
    output  logic   [1:0]   M_MemRW,
    output  logic   [2:0]   M_LDFilter_Sel,
    output  logic   [1:0]   M_Wr_Data_Sel,
    output  logic           M_RegWEn,
    output  logic           M_FPU_RegWEn,
    output  logic           M_Is_CSR,
    output  logic           M_Is_WFI,
    output  logic           M_Is_MRET,
    output  logic           M_valid,

    output  logic   [31:0]  M_PC,
    output  logic   [31:0]  M_ALU_out,
    output  logic   [31:0]  M_rs2_data,
    output  logic   [31:0]  M_FPU_out,
    output  logic   [31:0]  M_fp_rs2_data,
    output  logic   [31:0]  M_inst
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        M_Wr_Back_Sel   <= 2'd0;
        M_Rs2_Data_Sel  <= 1'b0;
        M_MemRW         <= 2'd0;
        M_LDFilter_Sel  <= 3'd0;
        M_Wr_Data_Sel   <= 2'd0;
        M_RegWEn        <= 1'b0; 
        M_FPU_RegWEn    <= 1'b0; 
        M_Is_CSR        <= 1'b0;
        M_Is_WFI        <= 1'b0;
        M_Is_MRET       <= 1'b0;
        M_valid         <= 1'b0; 

        M_PC            <= 32'd0;
        M_ALU_out       <= 32'd0;
        M_rs2_data      <= 32'd0;
        M_FPU_out       <= 32'd0;
        M_fp_rs2_data   <= 32'd0;
        M_inst          <= 32'd0;
    end
    else if (flush) begin
        M_Wr_Back_Sel   <= 2'd0;
        M_Rs2_Data_Sel  <= 1'b0;
        M_MemRW         <= 2'd0;
        M_LDFilter_Sel  <= 3'd0;
        M_Wr_Data_Sel   <= 2'd0;
        M_RegWEn        <= 1'b0; 
        M_FPU_RegWEn    <= 1'b0; 
        M_Is_CSR        <= 1'b0;
        M_Is_WFI        <= 1'b0;
        M_Is_MRET       <= 1'b0;
        M_valid         <= 1'b0; 

        M_PC            <= 32'd0;
        M_ALU_out       <= 32'd0;
        M_rs2_data      <= 32'd0;
        M_FPU_out       <= 32'd0;
        M_fp_rs2_data   <= 32'd0;
        M_inst          <= 32'd0;
    end
    else if (!stall) begin
        M_Wr_Back_Sel   <= EX_Wr_Back_Sel;
        M_Rs2_Data_Sel  <= EX_Rs2_Data_Sel;
        M_MemRW         <= EX_MemRW;
        M_LDFilter_Sel  <= EX_LDFilter_Sel;
        M_Wr_Data_Sel   <= EX_Wr_Data_Sel;
        M_RegWEn        <= EX_RegWEn; 
        M_FPU_RegWEn    <= EX_FPU_RegWEn;
        M_Is_CSR        <= EX_Is_CSR;
        M_Is_WFI        <= EX_Is_WFI;
        M_Is_MRET       <= EX_Is_MRET;
        M_valid         <= EX_valid; 

        M_PC            <= EX_PC;
        M_ALU_out       <= EX_ALU_out;
        M_rs2_data      <= EX_rs2_data;
        M_FPU_out       <= EX_FPU_out;
        M_fp_rs2_data   <= EX_fp_rs2_data;
        M_inst          <= EX_inst;
    end
end

endmodule