`ifndef ALU_SEL_DEF
`define ALU_SEL_DEF
package ALU_Sel_def;
    localparam logic [4:0] ADD   = 5'd0;
    localparam logic [4:0] SUB   = 5'd1;
    localparam logic [4:0] SLL   = 5'd2;
    localparam logic [4:0] SLT   = 5'd3;
    localparam logic [4:0] SLTU  = 5'd4;
    localparam logic [4:0] XOR   = 5'd5;
    localparam logic [4:0] SRL   = 5'd6;
    localparam logic [4:0] SRA   = 5'd7;
    localparam logic [4:0] OR    = 5'd8;
    localparam logic [4:0] AND   = 5'd9;
    localparam logic [4:0] MUL   = 5'd10;
    localparam logic [4:0] MULH  = 5'd11;
    localparam logic [4:0] MULHSU= 5'd12;
    localparam logic [4:0] MULHU = 5'd13;
    localparam logic [4:0] CLZ   = 5'd14;
    localparam logic [4:0] CTZ   = 5'd15;
    localparam logic [4:0] CPOP  = 5'd16;
    localparam logic [4:0] ROL   = 5'd17;
    localparam logic [4:0] ROR   = 5'd18;
    localparam logic [4:0] MIN   = 5'd19;
    localparam logic [4:0] MAX   = 5'd20;
    localparam logic [4:0] MINU  = 5'd21;
    localparam logic [4:0] MAXU  = 5'd22;
    localparam logic [4:0] BSET  = 5'd23;
    localparam logic [4:0] BCLR  = 5'd24;
    localparam logic [4:0] BEXT  = 5'd25;
    localparam logic [4:0] DOTP4 = 5'd26;
    localparam logic [4:0] SADD8 = 5'd27;
    localparam logic [4:0] SSUB8 = 5'd28;
    localparam logic [4:0] ABS   = 5'd29;
    localparam logic [4:0] CLIP8 = 5'd30;
    localparam logic [4:0] LUI   = 5'd31;
endpackage
`endif