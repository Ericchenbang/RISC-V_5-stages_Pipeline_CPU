module hw3_icache(
    input  logic        clk, rst, cpu_req,
    input  logic [31:0] cpu_addr,
    output logic        cpu_valid,
    output logic [31:0] cpu_rdata,
    output logic        mem_req, 
    output logic [31:0] mem_addr,
    input  logic        mem_busy, mem_rsp, mem_error,
    input  logic [31:0] mem_rdata
);

hw3_cache_core #(.READ_ONLY(1'b1)) controller(
    .clk(clk), .rst(rst), .cpu_req(cpu_req), .cpu_addr(cpu_addr),
    .cpu_web(1'b1), .cpu_wdata(32'b0), .cpu_bit_en(32'hFFFF_FFFF),
    .cpu_valid(cpu_valid), .cpu_rdata(cpu_rdata),
    .mem_req(mem_req), .mem_addr(mem_addr), .mem_write(),
    .mem_wdata(), .mem_wstrb(),
    .mem_busy(mem_busy), .mem_rsp(mem_rsp), .mem_error(mem_error), .mem_rdata(mem_rdata)
);

endmodule