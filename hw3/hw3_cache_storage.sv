module hw3_cache_storage(
    input  logic         clk, rst,
    input  logic         data_en, data_we,
    input  logic [5:0]   data_addr,
    input  logic [31:0]  data_wdata,
    output wire  [31:0]  data_rdata,
    
    input  logic         tag_en, tag_we,
    input  logic [3:0]   tag_addr,
    input  logic [23:0]  tag_wdata,
    output wire  [23:0]  tag_rdata
);

hw3_sram_tile #(
    .ADDR_WIDTH(6), .DATA_WIDTH(32), .KIND(0)
)data_sram(
    .clk(clk), .rst(rst), .en(data_en), .we(data_we),
    .addr(data_addr), .wdata(data_wdata), .rdata(data_rdata)
);


hw3_sram_tile #(
    .ADDR_WIDTH(4), .DATA_WIDTH(24), .KIND(1)
)tag_sram(
    .clk(clk), .rst(rst), .en(tag_en), .we(tag_we),
    .addr(tag_addr), .wdata(tag_wdata), .rdata(tag_rdata)
);


endmodule