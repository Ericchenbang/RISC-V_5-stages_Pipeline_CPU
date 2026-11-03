module STFilter(
    input  logic [1:0]  Wr_Data_Sel,
    input  logic [31:0] addr_offset,
    input  logic        Rs2_Data_Sel,
    input  logic [31:0] fp_rs2_data,
    input  logic [31:0] rs2_data,

    output logic [31:0] bit_mask,
    output logic [31:0] write_data
);

logic   [31:0]  data;

always_comb begin
    bit_mask = 32'h0000_0000;
    case (Wr_Data_Sel)
        2'd0: begin     // SB
            case(addr_offset[1:0])
                2'd0: bit_mask = 32'hFFFF_FF00;
                2'd1: bit_mask = 32'hFFFF_00FF;
                2'd2: bit_mask = 32'hFF00_FFFF;
                2'd3: bit_mask = 32'h00FF_FFFF;
            endcase
        end
        2'd1: begin     // SH
            case(addr_offset[1:0])
                2'd0: bit_mask = 32'hFFFF_0000;
                2'd2: bit_mask = 32'h0000_FFFF;
            endcase
        end
        2'd2: begin     // SW
            bit_mask = 32'h0000_0000;
        end 
    endcase


    data = Rs2_Data_Sel ? fp_rs2_data : rs2_data;
    case (addr_offset[1:0])
        2'd0:    write_data = data;
        2'd1:    write_data = data << 8;
        2'd2:    write_data = data << 16;
        2'd3:    write_data = data << 24;
        default: write_data = 32'hxxxx_xxxx;
    endcase
end
endmodule