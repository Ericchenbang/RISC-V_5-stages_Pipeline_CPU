`ifndef OPCODE_DEF
`define OPCODE_DEF
package opcode_def;
    localparam logic [6:0] R_TYPE   = 7'b011_0011;
    localparam logic [6:0] JAL      = 7'b110_1111;
    localparam logic [6:0] I_TYPE   = 7'b001_0011;
    localparam logic [6:0] LOAD     = 7'b000_0011;
    localparam logic [6:0] JALR     = 7'b110_0111;
    localparam logic [6:0] STORE    = 7'b010_0011;
    localparam logic [6:0] AUIPC    = 7'b001_0111;
    localparam logic [6:0] LUI_OP   = 7'b011_0111;
    localparam logic [6:0] B_TYPE   = 7'b110_0011;
    localparam logic [6:0] CSR      = 7'b111_0011;
    localparam logic [6:0] FP_LOAD  = 7'b000_0111;
    localparam logic [6:0] FP_STORE = 7'b010_0111;
    localparam logic [6:0] FPR_TYPE = 7'b101_0011;
    // clz, ctz, cpop opcode same as I-type
    // B-extension opcode same as R-type
    localparam logic [6:0] DSP      = 7'b000_1011;
endpackage
`endif 