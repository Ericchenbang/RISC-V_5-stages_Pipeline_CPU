module Br_Adder(
    input   logic   [31:0]  a,
    input   logic   [31:0]  imm,
    output  logic   [31:0]  Br_Adder_out
);

// For JALR, needs to clear LSB bit. Since value of imm in JALR can be odd. 
// For B_TYPE, it's no need to do it. Since value of imm of B_TYPE always be even. 
assign Br_Adder_out = ((a + imm) & 32'hFFFF_FFFE);

endmodule