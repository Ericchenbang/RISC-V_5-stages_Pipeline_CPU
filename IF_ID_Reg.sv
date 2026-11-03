module IF_ID_Reg(
    input   logic           clk,
    input   logic           rst,

    input   logic           stall,
    input   logic           flush,
    input   logic           IF_valid,

    input   logic   [31:0]  IF_PC,
    input   logic   [31:0]  IF_inst,


    output  logic   [31:0]  ID_PC,
    output  logic   [31:0]  ID_inst,
    output  logic           ID_valid
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        ID_PC   <= 32'd0;
        ID_inst <= 32'd0;
        ID_valid <= 1'b0;

    end
    else if (flush) begin
        ID_PC   <= 32'd0;
        ID_inst <= 32'd0;
        ID_valid <= 1'b0;

    end
    else if (!stall) begin
        ID_PC   <= IF_PC;
        ID_inst <= IF_inst;
        ID_valid <= IF_valid;


    end
end

endmodule