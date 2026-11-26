module M_WB_Reg(
    input   logic           clk,
    input   logic           rst,

    input   logic           M_RegWEn,
    input   logic           M_FPU_RegWEn,
    input   logic   [31:0]  M_PC,
    input   logic           M_Is_CSR,
    input   logic           M_Is_WFI,
    input   logic           M_Is_MRET,
    input   logic           M_valid,

    input   logic   [31:0]  M_inst,
    input   logic   [31:0]  M_wr_back_data,

    output  logic           WB_RegWEn,
    output  logic           WB_FPU_RegWEn,
    output  logic   [31:0]  WB_PC,
    output  logic           WB_Is_CSR,
    output  logic           WB_Is_WFI,
    output  logic           WB_Is_MRET,
    output  logic           WB_valid,

    output  logic   [31:0]  WB_inst,
    output  logic   [31:0]  WB_wr_back_data
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        WB_RegWEn       <= 1'b0;
        WB_FPU_RegWEn   <= 1'b0;
        WB_PC           <= 32'd0;
        WB_Is_CSR       <= 1'b0;
        WB_Is_WFI       <= 1'b0;
        WB_Is_MRET      <= 1'b0;
        WB_valid        <= 1'b0;
        WB_inst         <= 32'd0;
        WB_wr_back_data <= 32'd0;
    end
    else begin 
        WB_RegWEn       <= M_RegWEn;
        WB_FPU_RegWEn   <= M_FPU_RegWEn;
        WB_PC           <= M_PC;
        WB_Is_CSR       <= M_Is_CSR;
        WB_Is_WFI       <= M_Is_WFI;
        WB_Is_MRET      <= M_Is_MRET;
        WB_valid        <= M_valid;
        WB_inst         <= M_inst;
        WB_wr_back_data <= M_wr_back_data;
    end
end
endmodule