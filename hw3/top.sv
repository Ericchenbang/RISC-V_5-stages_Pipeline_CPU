module top (
    input  logic        clk, rst, external_irq,
    output logic        wfi_sleep,
    output logic        i_mem_req,
    output logic [31:0] i_mem_addr,
    input  logic        i_mem_busy, i_mem_rsp, i_mem_error,
    input  logic [31:0] i_mem_rdata,
    output logic        d_mem_req, d_mem_write,
    output logic [31:0] d_mem_addr, d_mem_wdata,
    output logic [3:0]  d_mem_wstrb,
    input  logic        d_mem_busy, d_mem_rsp, d_mem_error,
    input  logic [31:0] d_mem_rdata,
    output logic        cpu_i_req, cpu_i_valid,
    output logic [31:0] cpu_i_addr, cpu_i_rdata,
    output logic        cpu_d_req, cpu_d_valid, cpu_d_web,
    output logic [31:0] cpu_d_addr, cpu_d_wdata, cpu_d_bit_en, cpu_d_rdata
);

logic im_req,im_valid,dm_req,dm_valid,dm_WEB;
logic [31:0] im_addr,im_read_data,dm_addr,dm_read_data,dm_write_data,dm_bit_en;

hw3_cpu cpu(
    .clk(clk),.rst(rst) ,.im_req(im_req) ,.im_valid(im_valid) ,.im_addr(im_addr),
    .im_read_data(im_read_data) ,.dm_req(dm_req), .dm_valid(dm_valid) ,.dm_WEB(dm_WEB),
    .dm_addr(dm_addr) ,.dm_read_data(dm_read_data) ,.dm_write_data(dm_write_data), .dm_bit_en(dm_bit_en),
    .external_irq(external_irq) ,.wfi_sleep(wfi_sleep));

hw3_icache icache (.clk(clk),.rst(rst),.cpu_req(im_req),.cpu_addr(im_addr),.cpu_valid(im_valid),
    .cpu_rdata(im_read_data) ,.mem_req(i_mem_req),.mem_addr(i_mem_addr),.mem_busy(i_mem_busy),
    .mem_rsp(i_mem_rsp),.mem_error(i_mem_error),.mem_rdata(i_mem_rdata));

hw3_dcache dcache (.clk(clk),.rst(rst),.cpu_req(dm_req),.cpu_addr(dm_addr),.cpu_web(dm_WEB),
    .cpu_wdata(dm_write_data),.cpu_bit_en(dm_bit_en),.cpu_valid(dm_valid),.cpu_rdata(dm_read_data),
    .mem_req(d_mem_req) ,.mem_addr(d_mem_addr),.mem_write(d_mem_write),.mem_wdata(d_mem_wdata),
    .mem_wstrb(d_mem_wstrb),.mem_busy(d_mem_busy),.mem_rsp(d_mem_rsp),.mem_error(d_mem_error),
    .mem_rdata(d_mem_rdata));

assign cpu_i_req=im_req;
assign cpu_i_valid=im_valid;
assign cpu_i_addr=im_addr;
assign cpu_i_rdata=im_read_data;
assign cpu_d_req=dm_req;
assign cpu_d_valid=dm_valid;
assign cpu_d_addr=dm_addr;
assign cpu_d_rdata=dm_read_data;
assign cpu_d_web=dm_WEB;
assign cpu_d_wdata=dm_write_data;
assign cpu_d_bit_en=dm_bit_en;

endmodule
