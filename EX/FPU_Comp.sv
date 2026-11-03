module FPU_Comp (
    input   logic   [31:0]   FPU_a,
    input   logic   [31:0]   FPU_b,
    output  logic   [31:0]   FPU_min_out,
    output  logic   [31:0]   FPU_max_out
);

logic a_sign, b_sign;
assign a_sign = FPU_a[31];
assign b_sign = FPU_b[31];

logic unsigned [7:0] a_exp, b_exp;
assign a_exp = FPU_a[30:23];
assign b_exp = FPU_b[30:23];

logic [22:0] a_man, b_man;
assign a_man = FPU_a[22:0];
assign b_man = FPU_b[22:0];

logic [31:0] FPU_min, FPU_max;

// If a and b are both negative, exchange the two results
always_comb begin
    if (a_sign && b_sign) begin
        FPU_min_out = FPU_max;
        FPU_max_out = FPU_min;
    end
    else begin
        FPU_min_out = FPU_min;
        FPU_max_out = FPU_max;
    end
end

always_comb begin
    if ((a_sign ^ b_sign) == 1'b1) begin
        if (a_sign == 1'b0) begin
            FPU_min = FPU_b;
            FPU_max = FPU_a;
        end
        else begin
            FPU_min = FPU_a;
            FPU_max = FPU_b;
        end
    end
    else begin
        if (a_exp != b_exp) begin
            if (a_exp > b_exp) begin
                FPU_min = FPU_b;
                FPU_max = FPU_a;
            end
            else begin
                FPU_min = FPU_a;
                FPU_max = FPU_b;
            end
        end
        else begin
            if (a_man > b_man) begin
                FPU_min = FPU_b;
                FPU_max = FPU_a;
            end
            else begin
                FPU_min = FPU_a;
                FPU_max = FPU_b;
            end
        end
    end
end

endmodule