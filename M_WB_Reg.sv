module M_WB_Reg(
    input   logic           clk,
    input   logic           rst,
    input   logic           stall,

    input   logic           M_RegWEn,
    input   logic           M_FPU_RegWEn,
    input   logic           M_Is_CSR,
    input   logic           M_valid,

    input   logic   [31:0]  M_inst,
    input   logic   [31:0]  M_wr_back_data,

    output  logic           WB_RegWEn,
    output  logic           WB_FPU_RegWEn,
    output  logic           WB_Is_CSR,
    output  logic           WB_valid,

    output  logic   [31:0]  WB_inst,
    output  logic   [31:0]  WB_wr_back_data
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        WB_RegWEn       <= 1'b0;
        WB_FPU_RegWEn   <= 1'b0;
        WB_Is_CSR       <= 1'b0;
        WB_valid        <= 1'b0;
        WB_inst         <= 32'd0;
        WB_wr_back_data <= 32'd0;
    end
    else if (!stall) begin
        WB_RegWEn       <= M_RegWEn;
        WB_FPU_RegWEn   <= M_FPU_RegWEn;
        WB_Is_CSR       <= M_Is_CSR;
        WB_valid        <= M_valid;
        WB_inst         <= M_inst;
        WB_wr_back_data <= M_wr_back_data;
    end
end
endmodule