module FPU(
    input   logic   [31:0]  FPU_a,
    input   logic   [31:0]  FPU_b,
    input   logic   [1:0]   FPU_Sel,    // 0: ADD, 1: SUB, 2: MIN, 3: MAX

    output  logic   [31:0]  FPU_out
);

logic [31:0] add_result;
logic [31:0] min_result;
logic [31:0] max_result;


FPU_Adder u_fpu_adder (
    .FPU_a      (FPU_a),
    .FPU_b      (FPU_b),
    .FPU_sub    (FPU_Sel == 2'b01),
    .FPU_sum    (add_result)
);

FPU_Comp u_fpu_comp (
    .FPU_a      (FPU_a),
    .FPU_b      (FPU_b),
    .FPU_min_out    (min_result),
    .FPU_max_out    (max_result)
);

always_comb begin
    case (FPU_Sel)
        2'b00, 2'b01: FPU_out = add_result;
        2'b10:        FPU_out = min_result;
        2'b11:        FPU_out = max_result;
        default:      FPU_out = 32'hxxxx_xxxx;
    endcase
end
endmodule