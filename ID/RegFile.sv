module RegFile(
    input   logic           clk,

    input   logic   [4:0]   rs1,
    input   logic   [4:0]   rs2,
    input   logic   [4:0]   ex_rs1,
    input   logic   [4:0]   ex_rs2,
    output  logic   [31:0]  rs1_data,
    output  logic   [31:0]  rs2_data,
    output  logic   [31:0]  ex_rs1_data,
    output  logic   [31:0]  ex_rs2_data,
    
    input   logic   [4:0]   rd,
    input   logic   [31:0]  rd_data,

    input   logic           RegWEn
);

logic [31:0] Reg [31:0];

// Read
assign rs1_data = (rs1 == 5'd0) ? 32'd0 : Reg[rs1];
assign rs2_data = (rs2 == 5'd0) ? 32'd0 : Reg[rs2];
assign ex_rs1_data = (ex_rs1 == 5'd0) ? 32'd0 : Reg[ex_rs1];
assign ex_rs2_data = (ex_rs2 == 5'd0) ? 32'd0 : Reg[ex_rs2];

// Write
always_ff @(posedge clk) begin
    if (RegWEn && rd != 5'd0) begin
        Reg[rd] <= rd_data;
    end
end
endmodule