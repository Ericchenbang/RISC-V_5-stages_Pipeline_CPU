module hw3_dcache(
    input  logic        clk, rst, cpu_req, cpu_web,
    input  logic [31:0] cpu_addr, cpu_wdata, cpu_bit_en,
    output logic        cpu_valid,
    output logic [31:0] cpu_rdata,
    output logic        mem_req, mem_write,
    output logic [31:0] mem_addr, mem_wdata,
    output logic [3:0]  mem_wstrb,
    input  logic        mem_busy, mem_rsp, mem_error,
    input  logic [31:0] mem_rdata
);

hw3_cache_core #(.READ_ONLY(1'b0)) controller(
    .clk(clk), .rst(rst), .cpu_req(cpu_req), .cpu_addr(cpu_addr),
    .cpu_web(cpu_web), .cpu_wdata(cpu_wdata), .cpu_bit_en(cpu_bit_en),
    .cpu_valid(cpu_valid), .cpu_rdata(cpu_rdata),
    .mem_req(mem_req), .mem_addr(mem_addr), .mem_write(mem_write),
    .mem_wdata(mem_wdata), .mem_wstrb(mem_wstrb),
    .mem_busy(mem_busy), .mem_rsp(mem_rsp), .mem_error(mem_error), .mem_rdata(mem_rdata)
);


endmodule