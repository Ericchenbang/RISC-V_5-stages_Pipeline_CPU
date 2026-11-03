module FPU_Adder (
    input   logic   [31:0]  FPU_a,
    input   logic   [31:0]  FPU_b,
    input   logic           FPU_sub,
    output  logic   [31:0]  FPU_sum
);

function automatic logic [5:0] clz (input logic [31:0] num);
    logic [5:0] count;
    logic [31:0] temp;
    begin
        temp = num;
        count = 6'd0;

        if (temp == 32'h0000_0000) begin
            count = 6'd32;
        end
        else begin
            if (temp[31:16] == 16'h0000) begin
                count = count + 6'd16;
                temp <<= 16;
            end
            if (temp[31:24] == 8'h00) begin
                count = count + 6'd8;
                temp <<= 8;
            end
            if (temp[31:28] == 4'h0) begin
                count = count + 6'd4;
                temp <<= 4;
            end
            if (temp[31:30] == 2'b00) begin
                count = count + 6'd2;
                temp <<= 2;
            end
            if (temp[31] == 1'b0) begin
                count = count + 6'd1;
            end
        end
        return count;
    end
endfunction

logic a_sign, b_sign;
assign a_sign = FPU_a[31];
assign b_sign = FPU_b[31] ^ FPU_sub;

logic unsigned [7:0] a_exp, b_exp;
assign a_exp = FPU_a[30:23];
assign b_exp = FPU_b[30:23];
logic [7:0] exp_diff;

// 01.mantissa
logic [31:0] a_man, b_man;
logic [31:0] sum_man;
logic [5:0] lz;

logic g_bit, r_bit, s_bit;

logic sum_sign;
logic unsigned [7:0] sum_exp;
assign FPU_sum = {sum_sign, sum_exp, sum_man[29:7]};

always_comb begin
    a_man = {2'b01, FPU_a[22:0], 7'd0};
    b_man = {2'b01, FPU_b[22:0], 7'd0};
    exp_diff = 8'd0;
    lz = 6'd0;
    g_bit = 1'b0;
    r_bit = 1'b0;
    s_bit = 1'b0;

    if (a_exp == 8'h00) begin  // FPU_a is 0
        if (b_exp == 8'h00) begin   // FPU_b is also 0
            sum_sign = 1'b0; 
            sum_exp = 8'h00;
            sum_man = 32'd0;
        end
        else begin                  // FPU_b is not 0
            sum_sign = b_sign;
            sum_exp = b_exp;
            sum_man = {2'b00, FPU_b[22:0], 7'h00};
        end
    end
    else if (b_exp == 8'h00) begin  // FPU_b is 0 and FPU_a is not 0
        sum_sign = a_sign;
        sum_exp = a_exp;
        sum_man = {2'b00, FPU_a[22:0], 7'h00};
    end
    else begin
        // Can be reduced by min_exp, max_exp?
        if (a_exp > b_exp) begin
            sum_sign = a_sign;
            sum_exp = a_exp;

            exp_diff = a_exp - b_exp;
            b_man >>= exp_diff;

            if ((a_sign ^ b_sign) == 1'b0) begin
                sum_man = a_man + b_man;
            end
            else begin
                sum_man = a_man - b_man;
            end
        end
        else if (a_exp < b_exp) begin
            sum_sign = b_sign;
            sum_exp = b_exp;

            exp_diff = b_exp - a_exp;
            a_man >>= exp_diff;

            if ((b_sign ^ a_sign) == 1'b0) begin
                sum_man = a_man + b_man;
            end
            else begin
                sum_man = b_man - a_man;
            end
        end
        else begin              // a_exp == b_exp
            sum_exp = a_exp;

            if (a_man >= b_man) begin
                sum_sign = a_sign;

                if ((a_sign ^ b_sign) == 1'b0) begin
                    sum_man = a_man + b_man;
                end
                else begin
                    if (a_man == b_man) begin
                        sum_sign = 1'b0;
                        sum_exp = 8'h00;
                        sum_man = 32'h0000_0000;
                    end
                    else begin
                        sum_man = a_man - b_man;
                    end
                end
            end
            else begin
                sum_sign = b_sign;
                if ((a_sign ^ b_sign) == 1'b0) begin
                    sum_man = a_man + b_man;
                end
                else begin
                    sum_man = b_man - a_man;
                end
            end
        end

        if (sum_man == 32'h0000_0000) begin
            lz = 6'd0;
            g_bit = 1'b0;
            r_bit = 1'b0;
            s_bit = 1'b0;
        end
        else begin
            lz = clz(sum_man);
            if (lz == 6'd0) begin
                sum_exp = sum_exp + 1;
                sum_man >>= 1;
            end
            else begin
                sum_exp -= lz - 1;
                sum_man <<= lz - 1;
            end

            g_bit = sum_man[6];
            r_bit = sum_man[5];
            s_bit = |sum_man[4:0];
            
            // 2'b01, 23'bxxx.., 3'bxxx, 4'bxxxx
            if (g_bit) begin
                if ({r_bit, s_bit} > 2'b00) begin
                    sum_man += 8'b1000_0000;
                end
                else if ({r_bit, s_bit} == 2'b00) begin
                    if (sum_man[7]) begin
                        sum_man += 8'b1000_0000;
                    end
                end
                else begin      // prevent latch?
                    sum_man += 8'b0;
                end
            end
        
            if (sum_man[31]) begin
                sum_exp += 1;
                sum_man >>= 1;
            end
            else begin      // prevent latch?
                sum_exp += 0;
                sum_man >>= 0;
            end
        end
    end
end


endmodule