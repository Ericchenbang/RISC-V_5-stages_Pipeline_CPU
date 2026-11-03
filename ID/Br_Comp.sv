module Br_Comp(
    input   logic   [31:0] rs1_data,
    input   logic   [31:0] rs2_data,
    input   logic          BrUn,

    output  logic          BrEq,
    output  logic          BrLt
);

assign BrEq = (rs1_data == rs2_data);

assign BrLt = BrUn ? ($unsigned(rs1_data) < $unsigned(rs2_data)) : 
                     ($signed(rs1_data) < $signed(rs2_data));

endmodule