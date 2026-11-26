module CSR(
    input   logic           clk,
    input   logic           rst,

    // WB-stage commit events
    input   logic           instret_inc,
    input   logic           irq,
    input   logic           is_CSR,
    input   logic           is_WFI,
    input   logic           is_MRET,

    input   logic   [31:0]  csr_inst,
    input   logic   [31:0]  csr_rs1_data,
    output  logic   [31:0]  csr_data,

    input   logic   [31:0]  WB_PC,
    output  logic   [31:0]  csr_out_PC,
    output  logic           fetch_continue,
    output  logic           wfi_sleep
);

logic [11:0] addr;
logic [31:0] zimm;
logic [2:0] funct3;

assign addr   = csr_inst[31:20];
assign zimm   = {27'd0, csr_inst[19:15]};
assign funct3 = csr_inst[14:12];

logic [63:0] cycle;
logic [63:0] instret;

logic [31:0] mstatus;  // MIE[3], MPIE[7]
logic [31:0] mie;      // MEIE[11]
logic [31:0] mtvec;    // direct mode supported
logic [31:0] mepc;
logic [31:0] mip;      // MEIP[11] reflects irq

logic [31:0] store_PC;
logic [31:0] out_temp;
logic [31:0] new_temp;
logic        csr_write_enable;
logic        interrupt_enable;
logic        mret_commit;
logic        wfi_commit;

assign interrupt_enable = wfi_sleep && irq && mstatus[3] && mie[11];
assign mret_commit      = instret_inc && is_MRET;
assign wfi_commit       = instret_inc && is_WFI;

// This is the redirect-valid event. Its target is available in the same
// cycle so the CPU PC register can sample the correct address at the edge.
assign fetch_continue = interrupt_enable || mret_commit;

always_comb begin
    csr_out_PC = 32'd0;
    if (interrupt_enable)
        csr_out_PC = {mtvec[31:2], 2'b00};
    else if (mret_commit)
        csr_out_PC = {mepc[31:2], 2'b00};
end

// MEIP is an input level from the interrupt source and is read-only.
always_comb begin
    mip[31:12] = 20'd0;
    mip[11] = irq;
    mip[10:0] = 11'd0;
end

assign csr_data = out_temp;

// CSRRW/CSRRWI always write. CSRRS/CSRRC write only when rs1 != x0;
// immediate set/clear writes only when zimm != 0.
always_comb begin
    csr_write_enable = 1'b0;
    case (funct3)
        3'b001, 3'b101: csr_write_enable = 1'b1;
        3'b010, 3'b011, 3'b110, 3'b111:
            csr_write_enable = (csr_inst[19:15] != 5'd0);
        default: csr_write_enable = 1'b0;
    endcase
end

always_comb begin
    out_temp = 32'd0;
    new_temp = 32'd0;

    if (is_CSR) begin
        case (addr)
            12'hC82: out_temp = instret[63:32];
            12'hC02: out_temp = instret[31:0];
            12'hC80: out_temp = cycle[63:32];
            12'hC00: out_temp = cycle[31:0];
            12'h300: out_temp = mstatus;
            12'h304: out_temp = mie;
            12'h305: out_temp = mtvec;
            12'h341: out_temp = mepc;
            12'h344: out_temp = mip;
            default: out_temp = 32'd0;
        endcase

        case (funct3)
            3'b001: new_temp = csr_rs1_data;
            3'b010: new_temp = out_temp | csr_rs1_data;
            3'b011: new_temp = out_temp & ~csr_rs1_data;
            3'b101: new_temp = zimm;
            3'b110: new_temp = out_temp | zimm;
            3'b111: new_temp = out_temp & ~zimm;
            default: new_temp = 32'd0;
        endcase
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        cycle     <= 64'd0;
        instret   <= 64'd0;
        mstatus   <= 32'd0;
        mie       <= 32'd0;
        mtvec     <= 32'd0;
        mepc      <= 32'd0;
        store_PC  <= 32'd0;
        wfi_sleep <= 1'b0;
    end
    else begin
        cycle <= cycle + 64'd1;

        if (instret_inc)
            instret <= instret + 64'd1;

        // WFI retires once, then the CPU waits with its pipeline drained.
        if (wfi_commit) begin
            store_PC  <= WB_PC;
            wfi_sleep <= 1'b1;
        end

        // Interrupt acceptance is independent of retirement. While asleep,
        // no valid WB instruction exists to increment instret.
        if (interrupt_enable) begin
            mepc       <= {store_PC[31:2], 2'b00} + 32'd4;
            mstatus[7] <= mstatus[3];
            mstatus[3] <= 1'b0;
            wfi_sleep  <= 1'b0;
        end
        else if (mret_commit) begin
            mstatus[3] <= mstatus[7];
            mstatus[7] <= 1'b1;
            wfi_sleep  <= 1'b0;
        end
        else if (instret_inc && is_CSR && csr_write_enable) begin
            case (addr)
                12'h300: begin
                    // This implementation models only MIE and MPIE.
                    mstatus[3] <= new_temp[3];
                    mstatus[7] <= new_temp[7];
                end
                12'h304: mie[11] <= new_temp[11];
                12'h305: mtvec <= {new_temp[31:2], 2'b00};
                12'h341: mepc  <= {new_temp[31:2], 2'b00};
                // mip.MEIP and the cycle/instret aliases are read-only.
                default: begin end
            endcase
        end
        mstatus[31:8] <= 24'd0;
        mstatus[6:4] <= 3'd0;
        mstatus[2:0] <= 3'd0;
        mie[31:12] <= 20'd0;
        mie[10:0]  <= 11'd0;
    end
end

endmodule