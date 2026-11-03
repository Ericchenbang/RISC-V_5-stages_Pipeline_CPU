module CSR(
    input   logic           clk,
    input   logic           rst,

    input   logic           instret_inc,
    
    input   logic   [11:0]  csr_addr,
    output  logic   [31:0]  csr_data
);

logic [63:0] cycle;
logic [63:0] instret;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        cycle   <= 64'd0;

        instret <= 64'd0;
    end
    else begin
        cycle   <= cycle + 64'd1;

        if (instret_inc) begin
            instret <= instret + 64'd1;
        end
    end
end

always_comb begin
    case (csr_addr)
        12'b1100_1000_0010: csr_data = instret[63:32];
        12'b1100_0000_0010: csr_data = instret[31:0];
        12'b1100_1000_0000: csr_data = cycle[63:32];
        12'b1100_0000_0000: csr_data = cycle[31:0];;
        default:            csr_data = 32'hxxxx_xxxx;
    endcase
end

endmodule