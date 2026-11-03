module ID_EX_Reg(
    input   logic           clk,
    input   logic           rst,
    input   logic           stall,
    input   logic           flush,

    input   logic           ID_BrAdder_Sel,
    input   logic           ID_BrUn,
    input   logic   [1:0]   ID_ALU_ASel,
    input   logic   [1:0]   ID_ALU_BSel,
    input   logic   [4:0]   ID_ALU_Sel,
    input   logic   [1:0]   ID_FPU_ASel,
    input   logic   [1:0]   ID_FPU_BSel,
    input   logic   [1:0]   ID_FPU_Sel,
    input   logic   [1:0]   ID_Wr_Back_Sel,
    input   logic           ID_Rs2_Data_Sel,
    input   logic   [1:0]   ID_MemRW,
    input   logic   [2:0]   ID_LDFilter_Sel,
    input   logic   [1:0]   ID_Wr_Data_Sel,
    input   logic           ID_RegWEn,
    input   logic           ID_FPU_RegWEn,
    input   logic           ID_Is_CSR,
    input   logic           ID_valid,

    input   logic   [31:0]  ID_PC,
    input   logic   [31:0]  ID_imm,
    input   logic   [31:0]  ID_inst,


    output  logic           EX_BrAdder_Sel,
    output  logic           EX_BrUn,
    output  logic   [1:0]   EX_ALU_ASel,
    output  logic   [1:0]   EX_ALU_BSel,
    output  logic   [4:0]   EX_ALU_Sel,
    output  logic   [1:0]   EX_FPU_ASel,
    output  logic   [1:0]   EX_FPU_BSel,
    output  logic   [1:0]   EX_FPU_Sel,
    output  logic   [1:0]   EX_Wr_Back_Sel,
    output  logic           EX_Rs2_Data_Sel,
    output  logic   [1:0]   EX_MemRW,
    output  logic   [2:0]   EX_LDFilter_Sel,
    output  logic   [1:0]   EX_Wr_Data_Sel,
    output  logic           EX_RegWEn,
    output  logic           EX_FPU_RegWEn,
    output  logic           EX_Is_CSR,
    output  logic           EX_valid,

    output  logic   [31:0]  EX_PC,
    output  logic   [31:0]  EX_imm,
    output  logic   [31:0]  EX_inst
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        EX_BrAdder_Sel  <= 1'b0;
        EX_BrUn         <= 1'b0;
        EX_ALU_ASel     <= 2'd0;
        EX_ALU_BSel     <= 2'd0;
        EX_ALU_Sel      <= 5'd0;
        EX_FPU_ASel     <= 2'd0;
        EX_FPU_BSel     <= 2'd0;
        EX_FPU_Sel      <= 2'd0;
        EX_Wr_Back_Sel  <= 2'd0;
        EX_Rs2_Data_Sel <= 1'b0;
        EX_MemRW        <= 2'd0;
        EX_LDFilter_Sel <= 3'd0;
        EX_Wr_Data_Sel  <= 2'd0;
        EX_RegWEn       <= 1'b0;
        EX_FPU_RegWEn   <= 1'b0;
        EX_Is_CSR       <= 1'b0;
        EX_valid        <= 1'b0;         

        EX_PC           <= 32'd0;
        EX_imm          <= 32'd0;
        EX_inst         <= 32'd0; 
    end
    else if (flush) begin
        EX_BrAdder_Sel  <= 1'b0;
        EX_BrUn         <= 1'b0;
        EX_ALU_ASel     <= 2'd0;
        EX_ALU_BSel     <= 2'd0;
        EX_ALU_Sel      <= 5'd0;
        EX_FPU_ASel     <= 2'd0;
        EX_FPU_BSel     <= 2'd0;
        EX_FPU_Sel      <= 2'd0;
        EX_Wr_Back_Sel  <= 2'd0;
        EX_Rs2_Data_Sel <= 1'b0;
        EX_MemRW        <= 2'd0;
        EX_LDFilter_Sel <= 3'd0;
        EX_Wr_Data_Sel  <= 2'd0;
        EX_RegWEn       <= 1'b0;
        EX_FPU_RegWEn   <= 1'b0;
        EX_Is_CSR       <= 1'b0;
        EX_valid        <= 1'b0;         

        EX_PC           <= 32'd0;
        EX_imm          <= 32'd0;
        EX_inst         <= 32'd0;
    
    end
    else if (!stall) begin
        EX_BrAdder_Sel  <= ID_BrAdder_Sel;
        EX_BrUn         <= ID_BrUn;
        EX_ALU_ASel     <= ID_ALU_ASel;
        EX_ALU_BSel     <= ID_ALU_BSel;
        EX_ALU_Sel      <= ID_ALU_Sel;
        EX_FPU_ASel     <= ID_FPU_ASel;
        EX_FPU_BSel     <= ID_FPU_BSel;
        EX_FPU_Sel      <= ID_FPU_Sel;
        EX_Wr_Back_Sel  <= ID_Wr_Back_Sel;
        EX_Rs2_Data_Sel <= ID_Rs2_Data_Sel;
        EX_MemRW        <= ID_MemRW;
        EX_LDFilter_Sel <= ID_LDFilter_Sel;
        EX_Wr_Data_Sel  <= ID_Wr_Data_Sel;
        EX_RegWEn       <= ID_RegWEn;
        EX_FPU_RegWEn   <= ID_FPU_RegWEn;
        EX_Is_CSR       <= ID_Is_CSR;
        EX_valid        <= ID_valid;         

        EX_PC           <= ID_PC;
        EX_imm          <= ID_imm;
        EX_inst         <= ID_inst;
    end
end

endmodule