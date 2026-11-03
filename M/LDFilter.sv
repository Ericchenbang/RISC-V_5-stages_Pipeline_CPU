module LDFilter(
    input  logic [31:0] data,
    input  logic [2:0]  LDFilter_Sel,
    input  logic [31:0] addr_offset,
    output logic [31:0] out
);

logic [31:0] shifted_data;

always_comb begin 
    case(addr_offset[1:0])
        2'd0:    shifted_data = data;
        2'd1:    shifted_data = data >> 8;
        2'd2:    shifted_data = data >> 16;
        2'd3:    shifted_data = data >> 24;
        default: shifted_data = 32'hxxxx_xxxx;
    endcase

    case(LDFilter_Sel)
        3'b000: out = {{24{shifted_data[7]}}, shifted_data[7:0]};   // LB
        3'b001: out = {{16{shifted_data[15]}}, shifted_data[15:0]}; // LH
        3'b010: out = shifted_data;                                 // LW
        3'b100: out = {{24{1'b0}}, shifted_data[7:0]};              // LBU
        3'b101: out = {{24{1'b0}}, shifted_data[15:0]};             // LHU
        default: out = 32'hxxxx_xxxx;
    endcase
end

endmodule