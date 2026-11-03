`include "ALU_Sel_def.sv"
module ALU(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [4:0]  ALU_Sel,
    output logic [31:0] out
);


function automatic logic [5:0] clz_func (input logic [31:0] num);
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

function automatic logic [5:0] ctz_func (input logic [31:0] num);
    return clz_func({
        num[0], num[1], num[2], num[3], num[4], num[5], num[6], num[7],
        num[8], num[9], num[10], num[11], num[12], num[13], num[14], num[15],
        num[16], num[17], num[18], num[19], num[20], num[21], num[22], num[23],
        num[24], num[25], num[26], num[27], num[28], num[29], num[30], num[31]
    });
endfunction

function automatic logic [5:0] cpop_func (input logic [31:0] num);
    logic [1:0] firstAdd [15:0];
    logic [2:0] secondAdd [7:0];
    logic [3:0] thirdAdd [3:0];
    logic [4:0] fourthAdd [1:0];
    logic [5:0] sum;
    integer i;
    begin
        for (i = 0; i < 16; i = i + 1) begin
            firstAdd[i] = num[i] + num[16 + i];
        end

        for (i = 0; i < 8; i = i + 1) begin
            secondAdd[i] = firstAdd[i] + firstAdd[8 + i];
        end

        for (i = 0; i < 4; i = i + 1) begin
            thirdAdd[i] = secondAdd[i] + secondAdd[4 + i];
        end

        for (i = 0; i < 2; i = i + 1) begin
            fourthAdd[i] = thirdAdd[i] + thirdAdd[2 + i];
        end

        sum = fourthAdd[0] + fourthAdd[1];
        return sum;
    end
endfunction

function automatic logic [31:0] dotp4_func (input logic [31:0] num1, input logic [31:0] num2);
    logic signed [31:0] ans, temp01, temp23; 
    logic signed [15:0] temp [0:3];
    begin
        temp[0] = {{8{num1[7]}}, num1[7:0]}   * {{8{num2[7]}}, num2[7:0]};
        temp[1] = {{8{num1[15]}}, num1[15:8]}  * {{8{num2[15]}}, num2[15:8]};
        temp[2] = {{8{num1[23]}}, num1[23:16]} * {{8{num2[23]}}, num2[23:16]};
        temp[3] = {{8{num1[31]}}, num1[31:24]} * {{8{num2[31]}}, num2[31:24]};       

        temp01 = temp[0] + temp[1];
        temp23 = temp[2] + temp[3];

        ans = temp01 + temp23;

        return ans;
    end
endfunction

function automatic logic [31:0] sadd8_func (input logic [31:0] num1, input logic [31:0] num2);
    logic [31:0] ans;
    logic signed [8:0] result [0:7];
    begin
        result[0] =  {num1[7], num1[7:0]}    + {num2[7], num2[7:0]};
        //result[0] = $signed(num1) + $signed(num2);    -> wrong
        result[1] =  {num1[15], num1[15:8]}  + {num2[15], num2[15:8]};
        result[2] =  {num1[23], num1[23:16]} + {num2[23], num2[23:16]};
        result[3] =  {num1[31], num1[31:24]} + {num2[31], num2[31:24]};

        result[4] = (result[0] > 9'sd127) ? 9'sd127 : (result[0] < -9'sd128) ? -9'sd128 : result[0];
        result[5] = (result[1] > 9'sd127) ? 9'sd127 : (result[1] < -9'sd128) ? -9'sd128 : result[1];
        result[6] = (result[2] > 9'sd127) ? 9'sd127 : (result[2] < -9'sd128) ? -9'sd128 : result[2];
        result[7] = (result[3] > 9'sd127) ? 9'sd127 : (result[3] < -9'sd128) ? -9'sd128 : result[3];
    
        ans = {result[7][7:0], result[6][7:0], result[5][7:0], result[4][7:0]};
        return ans;
    end
endfunction

function automatic logic [31:0] ssub8_func (input logic [31:0] num1, num2);
    logic [31:0] ans;
    logic signed [8:0] result [0:7];
    begin
        result[0] =  {num1[7], num1[7:0]}    - {num2[7], num2[7:0]};
        result[1] =  {num1[15], num1[15:8]}  - {num2[15], num2[15:8]};
        result[2] =  {num1[23], num1[23:16]} - {num2[23], num2[23:16]};
        result[3] =  {num1[31], num1[31:24]} - {num2[31], num2[31:24]};

        result[4] = (result[0] > 9'sd127) ? 9'sd127 : (result[0] < -9'sd128) ? -9'sd128 : result[0];
        result[5] = (result[1] > 9'sd127) ? 9'sd127 : (result[1] < -9'sd128) ? -9'sd128 : result[1];
        result[6] = (result[2] > 9'sd127) ? 9'sd127 : (result[2] < -9'sd128) ? -9'sd128 : result[2];
        result[7] = (result[3] > 9'sd127) ? 9'sd127 : (result[3] < -9'sd128) ? -9'sd128 : result[3];
    
        ans = {result[7][7:0], result[6][7:0], result[5][7:0], result[4][7:0]};
        return ans;
    end
endfunction


always@ (*) begin
logic [63:0] mul_reg;
mul_reg = 64'd0;

case (ALU_Sel)
    ///////////////////
    // R_TYPE        //
    ///////////////////
    ADD: out = a + b;
    SUB: out = a - b;
    SLL: out = a << (b[4:0]);
    SLT: out = ($signed(a) < $signed(b)) ? 1 : 0;
    SLTU: out = (a < b) ? 1 : 0;
    XOR: out = a ^ b;
    SRL: out = a >> (b[4:0]);
    SRA: out = $signed(a) >>> (b[4:0]);
    OR: out = a | b;
    AND: out = a & b;
    
    ///////////////////
    // M_EXTENSION   //
    ///////////////////
    MUL: out = a * b;
    MULH: begin  
        // mul_reg = $signed(a) * $signed(b); // when mul_reg is signed 
        mul_reg = ({{32{a[31]}}, a}) * ({{32{b[31]}}, b});
        out = mul_reg[63:32];
    end
    MULHSU: begin    
        mul_reg = ({{32{a[31]}}, a}) * ({32'h0000_0000, b});
        out = mul_reg[63:32];
    end
    MULHU: begin
        mul_reg = a * b;
        out = mul_reg[63:32];
    end

    ///////////////////
    // B_EXTENSION   //
    ///////////////////
    clz_func: out = clz_func(a);
    ctz_func: out = ctz_func(a);
    cpop_func: out = cpop_func(a);
    ROL: out = (a << b[4:0]) | (a >> (5'd31 - b[4:0] + 5'd1));
    ROR: out = (a >> b[4:0]) | (a << (5'd31 - b[4:0] + 5'd1));
    MIN: out = $signed(a) < $signed(b) ? a : b;
    MAX: out = $signed(a) > $signed(b) ? a : b;
    MINU: out = (a < b) ? a : b;
    MAXU: out = (a > b) ? a : b;
    BSET: out = a | (32'h0000_0001 << b[4:0]);  
    BCLR: out = a & (~(32'h0000_0001 << b[4:0]));
    BEXT: out = (a >> b[4:0]) & 1;

    ///////////////////
    // DSP           //
    ///////////////////
    dotp4_func: out = dotp4_func(a, b);
    sadd8_func: out = sadd8_func(a, b);
    ssub8_func: out = ssub8_func(a, b);    
    ABS: begin        
        out = (a == 32'h8000_0000) ? 32'h7FFF_FFFF : ($signed(a) < 0 ? -($signed(a)) : a);
    end
    CLIP8: begin       
        out = ($signed(a) > 32'sd127) ? 32'sd127 : ($signed(a) < -32'sd128) ? -32'sd128 : $signed(a);
    end


    
    LUI: out = b;

    default: begin
        out = 32'hxxxx_xxxx;
        mul_reg = 64'hxxxx_xxxx_xxxx_xxxx;
    end
endcase
end
endmodule