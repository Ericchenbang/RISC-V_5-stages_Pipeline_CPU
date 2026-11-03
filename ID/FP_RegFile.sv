module FP_RegFile(
    input   logic           clk,

    input   logic   [4:0]   rs1,
    input   logic   [4:0]   rs2,
    input   logic   [4:0]   ex_rs1,
    input   logic   [4:0]   ex_rs2,
    output  logic   [31:0]  fp_rs1_data,
    output  logic   [31:0]  fp_rs2_data,
    output  logic   [31:0]  ex_fp_rs1_data,
    output  logic   [31:0]  ex_fp_rs2_data,
    
    input   logic   [4:0]   rd,
    input   logic   [31:0]  rd_data,

    input   logic           FPU_RegWEn
);

logic [31:0] FP_Reg [31:0];

// Read
assign fp_rs1_data = FP_Reg[rs1];
assign fp_rs2_data = FP_Reg[rs2];
assign ex_fp_rs1_data = FP_Reg[ex_rs1];
assign ex_fp_rs2_data = FP_Reg[ex_rs2];

// Write
always_ff @(posedge clk) begin
    if (FPU_RegWEn) begin
        FP_Reg[rd] <= rd_data;
    end
end
endmodule