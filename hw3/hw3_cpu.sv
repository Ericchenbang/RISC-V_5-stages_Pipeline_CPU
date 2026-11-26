`include "opcode_def.sv"

`include "Forwarding.sv"

`include "IF_ID_Reg.sv"
`include "ID_EX_Reg.sv"
`include "EX_M_Reg.sv"
`include "M_WB_Reg.sv"

`include "IF/PC_Selector.sv"

`include "ID/Br_Adder.sv"
`include "ID/Br_Comp.sv"
`include "ID/Control.sv"
`include "ID/FP_RegFile.sv"
`include "ID/Imm_Gen.sv"
`include "ID/RegFile.sv"

`include "EX/ALU.sv"
`include "EX/FPU_Adder.sv"
`include "EX/FPU_Comp.sv"
`include "EX/FPU.sv"

`include "M/LDFilter.sv"
`include "M/STFilter.sv"

`include "WB/CSR.sv"

module hw3_cpu(
    input  logic        clk, 
    input  logic        rst, 
    input  logic        external_irq,
    
    input  logic        im_valid,
    input  logic [31:0] im_read_data,
    output logic        im_req,
    output logic [31:0] im_addr,
    
    input  logic        dm_valid,
    input  logic [31:0] dm_read_data,
    output logic        dm_req, 
    output logic        dm_WEB,
    output logic [31:0] dm_bit_en, 
    output logic [31:0] dm_addr, 
    output logic [31:0] dm_write_data,
    
    output logic        wfi_sleep
);

// HW3 CPU datapath with WB-committed CSR, WFI, IRQ, and MRET control.

/////////////////////////////////////////////
// Signal Declaration
////////////////////////////////////////////

///////////////////////////////
// IF Stage                  //
///////////////////////////////
logic [31:0] IF_PC;
logic        IF_PC_Sel;
logic [31:0] IF_buf_inst;
logic [31:0] IF_buf_PC;
logic        IF_buf_valid;
logic        IM_discard_response;
logic        IM_launch;
logic        IF_accept;
logic        DM_stall;
logic        FW_dep_stall;
logic        ID_branch_stall;
logic        Front_stall;
logic        ID_redirect;
logic        M_ID_Forward_Available;
logic        ID_rs1_EX_match;
logic        ID_rs2_EX_match;
logic        ID_rs1_M_match;
logic        ID_rs2_M_match;
logic        ID_rs1_WB_match;
logic        ID_rs2_WB_match;
logic [31:0] ID_rs1_forwarded;
logic [31:0] ID_rs2_forwarded;

localparam logic [31:0] RESET_VECTOR = 32'h0001_0000;
logic       IF_started;

localparam  IM_Require      = 1'd0;
localparam  IM_Wait_valid   = 1'd1;
logic       IM_state;
logic       IM_next_state;

logic       IF_fetch_hold;
logic       ID_special_event;
logic       ID_special_advance;
logic       PC_redirect;
logic [31:0] PC_redirect_target;

///////////////////////////////
// ID Stage                  //
///////////////////////////////
logic [31:0] ID_PC;
logic [31:0] ID_inst;
logic        ID_valid;

logic [6:0] ID_opcode;
logic [4:0] ID_rd;
logic [2:0] ID_funct3;
logic [4:0] ID_rs1;
logic [4:0] ID_rs2;
logic [6:0] ID_funct7;

// Control Signal
logic           ID_BrAdder_Sel;
logic           ID_BrUn;
logic   [1:0]   ID_ALU_ASel;
logic   [1:0]   ID_ALU_BSel;
logic   [4:0]   ID_ALU_Sel;
logic   [1:0]   ID_FPU_ASel;
logic   [1:0]   ID_FPU_BSel;
logic   [1:0]   ID_FPU_Sel;
logic   [1:0]   ID_Wr_Data_Sel;
logic           ID_Rs2_Data_Sel;
logic   [1:0]   ID_MemRW;
logic   [2:0]   ID_LDFilter_Sel;
logic   [1:0]   ID_Wr_Back_Sel;
logic           ID_RegWEn;
logic           ID_FPU_RegWEn;
logic           ID_Is_CSR;
logic           ID_Is_WFI;
logic           ID_Is_MRET;

logic           ID_BrEq;
logic           ID_BrLt;

// Imm Gen
logic   [31:0]  ID_imm;

// RegFile
logic   [31:0]  ID_rs1_data;
logic   [31:0]  ID_rs2_data;

// FP_RegFile
logic   [31:0]  ID_fp_rs1_data;
logic   [31:0]  ID_fp_rs2_data;

// Br_Adder
logic   [31:0]  ID_Br_Adder_a;
logic   [31:0]  ID_Br_Adder_out;

// WFI, MRET
logic           ID_WFI_event;
logic           ID_MRET_event;

///////////////////////////////
// EX Stage                  //
///////////////////////////////

// Control Signal
logic           EX_BrAdder_Sel;
logic           EX_BrUn;
logic   [1:0]   EX_ALU_ASel;
logic   [1:0]   EX_ALU_BSel;
logic   [4:0]   EX_ALU_Sel;
logic   [1:0]   EX_FPU_ASel;
logic   [1:0]   EX_FPU_BSel;
logic   [1:0]   EX_FPU_Sel;
logic   [1:0]   EX_Wr_Data_Sel;
logic           EX_Rs2_Data_Sel;
logic   [1:0]   EX_MemRW;
logic   [2:0]   EX_LDFilter_Sel;
logic   [1:0]   EX_Wr_Back_Sel;
logic           EX_RegWEn;
logic           EX_FPU_RegWEn;
logic           EX_Is_CSR;
logic           EX_Is_WFI;
logic           EX_Is_MRET;

logic   [31:0]  EX_PC;
logic   [31:0]  EX_rf_rs1_data;
logic   [31:0]  EX_rf_rs2_data;
logic   [31:0]  EX_rf_fp_rs1_data;
logic   [31:0]  EX_rf_fp_rs2_data;
logic   [31:0]  EX_imm;
logic   [31:0]  EX_inst;
logic           EX_valid;

logic   [4:0]   EX_rs1;
logic   [4:0]   EX_rs2;

// Forwarding
logic   [1:0]   FW_ALU_ASel;
logic   [1:0]   FW_ALU_BSel;
logic   [1:0]   FW_FPU_ASel;
logic   [1:0]   FW_FPU_BSel;
logic   [1:0]   FW_Store_Data_Sel;
logic   [1:0]   FW_FP_Store_Data_Sel;
logic           EX_Forward_Stall;
logic           M_Forward_Result_Ready;
logic   [31:0]  EX_store_data;
logic   [31:0]  EX_fp_store_data;

// ALU
logic   [31:0]  EX_ALU_a;
logic   [31:0]  EX_ALU_b;
logic   [31:0]  EX_ALU_out;
// FPU
logic   [31:0]  EX_FPU_a;
logic   [31:0]  EX_FPU_b;
logic   [31:0]  EX_FPU_out;

///////////////////////////////
// M Stage                  //
///////////////////////////////
logic   [1:0]   M_Wr_Data_Sel;
logic           M_Rs2_Data_Sel;
logic   [1:0]   M_MemRW;
logic   [2:0]   M_LDFilter_Sel;
logic   [1:0]   M_Wr_Back_Sel;
logic           M_RegWEn;
logic           M_FPU_RegWEn;
logic           M_Is_CSR;
logic           M_Is_WFI;
logic           M_Is_MRET;

logic   [31:0]  M_PC;
logic   [31:0]  M_ALU_out;
logic   [31:0]  M_rs2_data;
logic   [31:0]  M_FPU_out;
logic   [31:0]  M_fp_rs2_data;
logic   [31:0]  M_inst;
logic           M_valid;

logic   [4:0]   M_rs1;
logic   [4:0]   M_rs2;
logic   [4:0]   M_rd;

logic   [31:0]  M_write_data;

localparam DM_Standby = 2'd0;
localparam DM_Read_Write = 2'd1;
localparam DM_Wait_Valid = 2'd3;
logic   [1:0]   DM_state;
logic   [1:0]   DM_next_state;

logic   [31:0]  M_read_data;
logic   [31:0]  M_wr_back_data;


///////////////////////////////
// WB Stage                  //
///////////////////////////////
logic           WB_RegWEn;
logic           WB_FPU_RegWEn;
logic   [31:0]  WB_PC;
logic           WB_Is_CSR;
logic           WB_Is_WFI;
logic           WB_Is_MRET;

logic   [31:0]  WB_inst;
logic           WB_valid;
logic           instret_inc;
logic   [31:0]  WB_wr_back_data;

logic   [4:0]   WB_rs1;
logic   [31:0]  WB_rs1_data;
logic   [4:0]   WB_rd;

logic   [31:0]  WB_csr_data;
logic   [31:0]  WB_final_wr_back_data;

logic   [31:0]  csr_out_PC;
logic           fetch_continue;

/////////////////////////////////////////////
// Logic
////////////////////////////////////////////
///////////////////////////////
// IF Stage                  //
///////////////////////////////

PC_Selector u_pc_selector(
    .opcode(ID_opcode),
    .funct3(ID_funct3),
    .BrEq(ID_BrEq),
    .BrLt(ID_BrLt),
    .PC_Sel(IF_PC_Sel)
);

assign DM_stall = (M_MemRW != 2'd0) &&
                  !((DM_state == DM_Wait_Valid) && dm_valid);
assign FW_dep_stall = EX_Forward_Stall && !DM_stall;
assign Front_stall = DM_stall || FW_dep_stall || ID_branch_stall;
assign ID_special_event = ID_WFI_event || ID_MRET_event;
assign ID_special_advance = ID_special_event && !Front_stall;
assign ID_redirect = ID_valid && IF_PC_Sel && !Front_stall &&
                     !IF_fetch_hold && !ID_special_event;
assign PC_redirect = fetch_continue || ID_redirect;

always_comb begin
    if (fetch_continue)
        PC_redirect_target = csr_out_PC;
    else
        PC_redirect_target = ID_Br_Adder_out;
end

assign IF_accept = IF_buf_valid && !Front_stall && !ID_redirect &&
                   !IF_fetch_hold && !ID_special_event && !fetch_continue;
assign IM_launch = IF_started && 
                   (IM_state == IM_Require) &&
                   !IF_buf_valid && !ID_redirect && !Front_stall &&
                   !IF_fetch_hold && !ID_special_event && !fetch_continue;
assign M_ID_Forward_Available = M_Forward_Result_Ready && !M_Is_CSR;

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        IF_fetch_hold <= 1'b0;
    else if (fetch_continue)
        IF_fetch_hold <= 1'b0;
    else if (ID_special_event)
        IF_fetch_hold <= 1'b1;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        IF_PC               <= 32'd0;
        IF_started          <= 1'b0;
        IF_buf_inst         <= 32'd0;
        IF_buf_PC           <= 32'd0;
        IF_buf_valid        <= 1'b0;
        IM_discard_response <= 1'b0;
    end
    else if (!IF_started) begin
        IF_PC <= RESET_VECTOR;
        IF_started <= 1'b1;
    end
    else if (PC_redirect) begin
        // Redirect wins over sequential fetch; discard younger buffered data.
        IF_PC        <= PC_redirect_target;
        IF_buf_valid <= 1'b0;
        if ((IM_state == IM_Wait_valid) && !im_valid)
            IM_discard_response <= 1'b1;
        else
            IM_discard_response <= 1'b0;
    end
    else if (ID_special_event || IF_fetch_hold) begin
        // Freeze PC and drop younger fetch data, while the IM FSM continues
        // waiting for any outstanding response and consumes it as discarded.
        IF_buf_valid <= 1'b0;
        if ((IM_state == IM_Wait_valid) && !im_valid)
            IM_discard_response <= 1'b1;
        else
            IM_discard_response <= 1'b0;
    end
    else begin
        if (IF_accept) begin
            IF_PC        <= IF_buf_PC + 32'd4;
            IF_buf_valid <= 1'b0;
        end

        if ((IM_state == IM_Wait_valid) && im_valid) begin
            if (IM_discard_response) begin
                IF_buf_valid        <= 1'b0;
                IM_discard_response <= 1'b0;
            end
            else begin
                IF_buf_inst         <= im_read_data;
                IF_buf_PC           <= im_addr;
                IF_buf_valid        <= 1'b1;
                IM_discard_response <= 1'b0;
            end
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        IM_state <= IM_Require;
    else
        IM_state <= IM_next_state;
end

always_comb begin
    IM_next_state = IM_state;
    case (IM_state)
        IM_Require: begin
            if (IM_launch)
                IM_next_state = IM_Wait_valid;
        end
        IM_Wait_valid: begin
            if (im_valid)
                IM_next_state = IM_Require;
        end
    endcase
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        im_req  <= 1'b0;
        im_addr <= 32'd0;
    end
    else begin
        if (IM_launch) begin
            im_req  <= 1'b1;
            im_addr <= IF_PC;
        end
        else begin
            im_req <= 1'b0;
        end
    end
end

IF_ID_Reg u_IF_ID_Reg(
    .clk(clk),
    .rst(rst),
    .stall(Front_stall),
    .flush(PC_redirect || ID_special_advance ||
           (!IF_buf_valid && !Front_stall)),
    .IF_valid(IF_accept),
    .IF_PC(IF_buf_PC),
    .IF_inst(IF_buf_inst),
    .ID_PC(ID_PC),
    .ID_inst(ID_inst),
    .ID_valid(ID_valid)
);
///////////////////////////////
// ID Stage                  //
///////////////////////////////
assign ID_WFI_event = ID_valid && ID_Is_WFI;
assign ID_MRET_event = ID_valid && ID_Is_MRET;

assign ID_opcode = ID_inst[6:0];
assign ID_rd     = ID_inst[11:7];
assign ID_funct3 = ID_inst[14:12];
assign ID_rs1    = ID_inst[19:15];
assign ID_rs2    = ID_inst[24:20];
assign ID_funct7 = ID_inst[31:25];

Control u_Control(
    .funct7(ID_funct7),
    .funct3(ID_funct3),
    .opcode(ID_opcode),
    .rs2(ID_rs2),
    .rs1(ID_rs1),
    .rd(ID_rd),
    .RegWEn(ID_RegWEn),
    .FPU_RegWEn(ID_FPU_RegWEn),
    .BrAdder_Sel(ID_BrAdder_Sel),
    .BrUn(ID_BrUn),
    .ALU_ASel(ID_ALU_ASel),
    .ALU_BSel(ID_ALU_BSel),
    .ALU_Sel(ID_ALU_Sel),
    .FPU_ASel(ID_FPU_ASel),
    .FPU_BSel(ID_FPU_BSel),
    .FPU_Sel(ID_FPU_Sel),
    .Wr_Data_Sel(ID_Wr_Data_Sel),
    .Rs2_Data_Sel(ID_Rs2_Data_Sel),
    .MemRW(ID_MemRW),
    .LDFilter_Sel(ID_LDFilter_Sel),
    .Wr_Back_Sel(ID_Wr_Back_Sel),
    .Is_CSR(ID_Is_CSR),
    .Is_WFI(ID_Is_WFI),
    .Is_MRET(ID_Is_MRET)
);

Imm_Gen u_Imm_Gen(
    .inst(ID_inst),
    .imm(ID_imm)
);

RegFile u_RegFile(
    .clk(clk),
    .rst(rst),
    .rs1(ID_rs1),
    .rs2(ID_rs2),
    .ex_rs1(EX_rs1),
    .ex_rs2(EX_rs2),
    .rs1_data(ID_rs1_data),
    .rs2_data(ID_rs2_data),
    .ex_rs1_data(EX_rf_rs1_data),
    .ex_rs2_data(EX_rf_rs2_data),
    .rd(WB_inst[11:7]),
    .rd_data(WB_final_wr_back_data),
    .RegWEn(WB_RegWEn),
    .csr_rs1(WB_rs1),
    .csr_rs1_data(WB_rs1_data)
);

FP_RegFile u_FP_RegFile(
    .clk(clk),
    .rs1(ID_rs1),
    .rs2(ID_rs2),
    .ex_rs1(EX_rs1),
    .ex_rs2(EX_rs2),
    .fp_rs1_data(ID_fp_rs1_data),
    .fp_rs2_data(ID_fp_rs2_data),
    .ex_fp_rs1_data(EX_rf_fp_rs1_data),
    .ex_fp_rs2_data(EX_rf_fp_rs2_data),
    .rd(WB_inst[11:7]),
    .rd_data(WB_final_wr_back_data),
    .FPU_RegWEn(WB_FPU_RegWEn)
);


assign ID_Br_Adder_a = ID_BrAdder_Sel ? ID_PC : ID_rs1_forwarded;
Br_Adder u_Br_Adder(
    .a(ID_Br_Adder_a),
    .imm(ID_imm),
    .Br_Adder_out(ID_Br_Adder_out)
);

Br_Comp u_Br_Comp(
    .rs1_data(ID_rs1_forwarded),
    .rs2_data(ID_rs2_forwarded),
    .BrUn(ID_BrUn),
    .BrEq(ID_BrEq),
    .BrLt(ID_BrLt)
);

assign ID_rs1_EX_match = EX_RegWEn && (EX_inst[11:7] != 5'd0) &&
                         (EX_inst[11:7] == ID_rs1);
assign ID_rs2_EX_match = EX_RegWEn && (EX_inst[11:7] != 5'd0) &&
                         (EX_inst[11:7] == ID_rs2);
assign ID_rs1_M_match  = M_RegWEn && (M_rd != 5'd0) && (M_rd == ID_rs1);
assign ID_rs2_M_match  = M_RegWEn && (M_rd != 5'd0) && (M_rd == ID_rs2);
assign ID_rs1_WB_match = WB_RegWEn && (WB_rd != 5'd0) && (WB_rd == ID_rs1);
assign ID_rs2_WB_match = WB_RegWEn && (WB_rd != 5'd0) && (WB_rd == ID_rs2);

always_comb begin
    ID_rs1_forwarded = ID_rs1_data;
    if (((ID_opcode == B_TYPE) || (ID_opcode == JALR)) && (ID_rs1 != 5'd0)) begin
        if (ID_rs1_M_match) begin
            if (M_ID_Forward_Available)
                ID_rs1_forwarded = M_wr_back_data;
        end
        else if (ID_rs1_WB_match)
            ID_rs1_forwarded = WB_final_wr_back_data;
    end
end

always_comb begin
    ID_rs2_forwarded = ID_rs2_data;
    if ((ID_opcode == B_TYPE) && (ID_rs2 != 5'd0)) begin
        if (ID_rs2_M_match) begin
            if (M_ID_Forward_Available)
                ID_rs2_forwarded = M_wr_back_data;
        end
        else if (ID_rs2_WB_match)
            ID_rs2_forwarded = WB_final_wr_back_data;
    end
end

always_comb begin
    ID_branch_stall = 1'b0;
    if ((ID_opcode == B_TYPE) || (ID_opcode == JALR)) begin
        if ((ID_rs1 != 5'd0) &&
            (ID_rs1_EX_match || (ID_rs1_M_match && !M_ID_Forward_Available)))
            ID_branch_stall = 1'b1;
        if ((ID_opcode == B_TYPE) && (ID_rs2 != 5'd0) &&
            (ID_rs2_EX_match || (ID_rs2_M_match && !M_ID_Forward_Available)))
            ID_branch_stall = 1'b1;
    end
end


ID_EX_Reg u_ID_EX_Reg(
    .clk(clk),
    .rst(rst),
    .stall(DM_stall || FW_dep_stall),
    .flush((ID_branch_stall && !DM_stall && !FW_dep_stall) || fetch_continue),

    .ID_BrAdder_Sel(ID_BrAdder_Sel),
    .ID_BrUn(ID_BrUn),
    .ID_ALU_ASel(ID_ALU_ASel),
    .ID_ALU_BSel(ID_ALU_BSel),
    .ID_ALU_Sel(ID_ALU_Sel),
    .ID_FPU_ASel(ID_FPU_ASel),
    .ID_FPU_BSel(ID_FPU_BSel),
    .ID_FPU_Sel(ID_FPU_Sel),
    .ID_Wr_Data_Sel(ID_Wr_Data_Sel),
    .ID_Rs2_Data_Sel(ID_Rs2_Data_Sel),
    .ID_MemRW(ID_MemRW),
    .ID_LDFilter_Sel(ID_LDFilter_Sel),
    .ID_Wr_Back_Sel(ID_Wr_Back_Sel),
    .ID_RegWEn(ID_RegWEn),
    .ID_FPU_RegWEn(ID_FPU_RegWEn),
    .ID_Is_CSR(ID_Is_CSR),
    .ID_Is_WFI(ID_Is_WFI),
    .ID_Is_MRET(ID_Is_MRET),

    .ID_PC(ID_PC),
    .ID_imm(ID_imm),
    .ID_inst(ID_inst),
    .ID_valid(ID_valid),

    .EX_BrAdder_Sel(EX_BrAdder_Sel),
    .EX_BrUn(EX_BrUn),
    .EX_ALU_ASel(EX_ALU_ASel),
    .EX_ALU_BSel(EX_ALU_BSel),
    .EX_ALU_Sel(EX_ALU_Sel),
    .EX_FPU_ASel(EX_FPU_ASel),
    .EX_FPU_BSel(EX_FPU_BSel),
    .EX_FPU_Sel(EX_FPU_Sel),
    .EX_Wr_Data_Sel(EX_Wr_Data_Sel),
    .EX_Rs2_Data_Sel(EX_Rs2_Data_Sel),
    .EX_MemRW(EX_MemRW),
    .EX_LDFilter_Sel(EX_LDFilter_Sel),
    .EX_Wr_Back_Sel(EX_Wr_Back_Sel),
    .EX_RegWEn(EX_RegWEn),
    .EX_FPU_RegWEn(EX_FPU_RegWEn),
    .EX_Is_CSR(EX_Is_CSR),
    .EX_Is_WFI(EX_Is_WFI),
    .EX_Is_MRET(EX_Is_MRET),

    .EX_PC(EX_PC),
    .EX_imm(EX_imm),
    .EX_inst(EX_inst),
    .EX_valid(EX_valid)
);

///////////////////////////////
// EX Stage                  //
///////////////////////////////
assign EX_rs1 = EX_inst[19:15];
assign EX_rs2 = EX_inst[24:20];

Forwarding u_Forwarding(
    .EX_opcode(EX_inst[6:0]),
    .EX_rs1(EX_rs1),
    .EX_rs2(EX_rs2),
    .EX_ALU_ASel(EX_ALU_ASel),
    .EX_ALU_BSel(EX_ALU_BSel),
    .M_rd(M_rd),
    .M_RegWEn(M_RegWEn),
    .M_FPU_RegWEn(M_FPU_RegWEn),
    .M_Is_CSR(M_Is_CSR),
    .M_Forward_Result_Ready(M_Forward_Result_Ready),
    .WB_rd(WB_rd),
    .WB_RegWEn(WB_RegWEn),
    .WB_FPU_RegWEn(WB_FPU_RegWEn),
    .FW_ALU_ASel(FW_ALU_ASel),
    .FW_ALU_BSel(FW_ALU_BSel),
    .FW_FPU_ASel(FW_FPU_ASel),
    .FW_FPU_BSel(FW_FPU_BSel),
    .FW_Store_Data_Sel(FW_Store_Data_Sel),
    .FW_FP_Store_Data_Sel(FW_FP_Store_Data_Sel),
    .FW_Stall(EX_Forward_Stall)
);

assign M_Forward_Result_Ready = (M_MemRW != 2'd1) ||
                                    ((DM_state == DM_Wait_Valid) && dm_valid);

always_comb begin
    case (FW_Store_Data_Sel)
        2'b01, 2'b11: EX_store_data = M_wr_back_data;
        2'b10:        EX_store_data = WB_final_wr_back_data;
        default:      EX_store_data = EX_rf_rs2_data;
    endcase
end

always_comb begin
    case (FW_FP_Store_Data_Sel)
        2'b01, 2'b11: EX_fp_store_data = M_wr_back_data;
        2'b10:        EX_fp_store_data = WB_final_wr_back_data;
        default:      EX_fp_store_data = EX_rf_fp_rs2_data;
    endcase
end


always_comb begin
    EX_ALU_a = 32'd0;
    case (FW_ALU_ASel)
        2'b00: begin
            case(EX_ALU_ASel)
                2'd0: EX_ALU_a = EX_rf_rs1_data;
                2'd1: EX_ALU_a = EX_PC;
            endcase
        end
        2'b01: EX_ALU_a = M_wr_back_data;
        2'b10: EX_ALU_a = WB_final_wr_back_data;
        2'b11: EX_ALU_a = M_wr_back_data;
    endcase
end
always_comb begin
    EX_ALU_b = 32'd0;
    case(FW_ALU_BSel)
        2'b00: begin
            case(EX_ALU_BSel)
                2'd0: EX_ALU_b = EX_rf_rs2_data;
                2'd1: EX_ALU_b = EX_imm;
            endcase
        end
        2'b01: EX_ALU_b = M_wr_back_data;
        2'b10: EX_ALU_b = WB_final_wr_back_data;
        2'b11: EX_ALU_b = M_wr_back_data;
    endcase
end
ALU u_ALU(
    .a(EX_ALU_a),
    .b(EX_ALU_b),
    .ALU_Sel(EX_ALU_Sel),
    .out(EX_ALU_out)
);

always_comb begin
    EX_FPU_a = 32'd0;
    case (FW_FPU_ASel)
        2'b00: EX_FPU_a = EX_rf_fp_rs1_data;
        2'b01: EX_FPU_a = M_wr_back_data;
        2'b10: EX_FPU_a = WB_final_wr_back_data;
        2'b11: EX_FPU_a = M_wr_back_data;
    endcase
end
always_comb begin
    EX_FPU_b = 32'd0;
    case (FW_FPU_BSel)
        2'b00: EX_FPU_b = EX_rf_fp_rs2_data;
        2'b01: EX_FPU_b = M_wr_back_data;
        2'b10: EX_FPU_b = WB_final_wr_back_data;
        2'b11: EX_FPU_b = M_wr_back_data;
    endcase
end
FPU u_FPU(
    .FPU_a(EX_FPU_a),
    .FPU_b(EX_FPU_b),
    .FPU_Sel(EX_FPU_Sel),
    .FPU_out(EX_FPU_out)
);

EX_M_Reg u_EX_M_Reg(
    .clk(clk),
    .rst(rst),
    .stall(DM_stall),
    .flush(FW_dep_stall),

    .EX_Wr_Data_Sel(EX_Wr_Data_Sel),
    .EX_Rs2_Data_Sel(EX_Rs2_Data_Sel),
    .EX_MemRW(EX_MemRW),
    .EX_LDFilter_Sel(EX_LDFilter_Sel),
    .EX_Wr_Back_Sel(EX_Wr_Back_Sel),
    .EX_RegWEn(EX_RegWEn),
    .EX_FPU_RegWEn(EX_FPU_RegWEn),
    .EX_Is_CSR(EX_Is_CSR),
    .EX_Is_WFI(EX_Is_WFI),
    .EX_Is_MRET(EX_Is_MRET),

    .EX_PC(EX_PC),
    .EX_ALU_out(EX_ALU_out),
    .EX_rs2_data(EX_store_data),
    .EX_FPU_out(EX_FPU_out),
    .EX_fp_rs2_data(EX_fp_store_data),
    .EX_inst(EX_inst),
    .EX_valid(EX_valid),

    .M_Wr_Data_Sel(M_Wr_Data_Sel),
    .M_Rs2_Data_Sel(M_Rs2_Data_Sel),
    .M_MemRW(M_MemRW),
    .M_LDFilter_Sel(M_LDFilter_Sel),
    .M_Wr_Back_Sel(M_Wr_Back_Sel),
    .M_RegWEn(M_RegWEn),
    .M_FPU_RegWEn(M_FPU_RegWEn),
    .M_Is_CSR(M_Is_CSR),
    .M_Is_WFI(M_Is_WFI),
    .M_Is_MRET(M_Is_MRET),

    .M_PC(M_PC),
    .M_ALU_out(M_ALU_out),
    .M_rs2_data(M_rs2_data),
    .M_FPU_out(M_FPU_out),
    .M_fp_rs2_data(M_fp_rs2_data),
    .M_inst(M_inst),
    .M_valid(M_valid)
);


///////////////////////////////
// M Stage                  //
///////////////////////////////
assign M_rd = M_inst[11:7];

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        DM_state <= DM_Standby;
    end
    else begin
        DM_state <= DM_next_state;
    end
end

always_comb begin
    DM_next_state = DM_state;
    if (DM_state == DM_Standby) begin
        if (M_MemRW == 2'd0) begin
            DM_next_state = DM_Standby;
        end
        else begin
            DM_next_state = DM_Read_Write;
        end
    end
    else if (DM_state == DM_Read_Write) begin
        DM_next_state = DM_Wait_Valid;
    end
    else if (DM_state == DM_Wait_Valid) begin
        if (dm_valid == 1'b1) begin
            DM_next_state = DM_Standby;
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        dm_req        <= 1'b0;
        dm_WEB        <= 1'b0;
        dm_addr       <= 32'd0;
        dm_write_data <= 32'd0;
    end
    else begin
        if (DM_state == DM_Read_Write) begin
            dm_req        <= 1'b1;
            dm_WEB        <= M_MemRW[0];   // 1: Read, 0: Write
            dm_addr       <= M_ALU_out;
            dm_write_data <= M_write_data;
        end
        else begin
            dm_req <= 1'b0;
        end
    end
end
STFilter u_STFilter(
    .Wr_Data_Sel(M_Wr_Data_Sel),
    .addr_offset(M_ALU_out),
    .Rs2_Data_Sel(M_Rs2_Data_Sel),
    .fp_rs2_data(M_fp_rs2_data),
    .rs2_data(M_rs2_data),

    .bit_mask(dm_bit_en),
    .write_data(M_write_data)
);

LDFilter u_LDFilter(
    .data(dm_read_data),
    .LDFilter_Sel(M_LDFilter_Sel),
    .addr_offset(M_ALU_out),
    .out(M_read_data)
);

always_comb begin
    M_wr_back_data = 32'd0;
    case(M_Wr_Back_Sel)
        2'd0: M_wr_back_data = M_read_data;
        2'd1: M_wr_back_data = M_ALU_out;
        2'd2: M_wr_back_data = M_PC + 32'd4;
        2'd3: M_wr_back_data = M_FPU_out;
    endcase
end

M_WB_Reg u_M_WB_Reg (
    .clk(clk),
    .rst(rst),
    .M_valid(M_valid && !DM_stall),

    .M_RegWEn(M_RegWEn && M_valid && !DM_stall),
    .M_FPU_RegWEn(M_FPU_RegWEn && M_valid && !DM_stall),
    .M_PC(M_PC),
    .M_Is_CSR(M_Is_CSR && M_valid && !DM_stall),
    .M_Is_WFI(M_Is_WFI && M_valid && !DM_stall),
    .M_Is_MRET(M_Is_MRET && M_valid && !DM_stall),
    .M_inst(DM_stall ? 32'd0 : M_inst),
    .M_wr_back_data(DM_stall ? 32'd0 : M_wr_back_data),

    .WB_RegWEn(WB_RegWEn),
    .WB_FPU_RegWEn(WB_FPU_RegWEn),
    .WB_PC(WB_PC),
    .WB_Is_CSR(WB_Is_CSR),
    .WB_Is_WFI(WB_Is_WFI),
    .WB_Is_MRET(WB_Is_MRET),
    .WB_inst(WB_inst),
    .WB_valid(WB_valid),
    .WB_wr_back_data(WB_wr_back_data)
);

///////////////////////////////
// WB Stage                  //
///////////////////////////////
assign WB_rd  = WB_inst[11:7];
assign WB_rs1 = WB_inst[19:15];

assign instret_inc = WB_valid;

CSR u_CSR(
    .clk(clk),
    .rst(rst),
    .instret_inc(instret_inc),
    .irq(external_irq),
    .is_CSR(WB_valid && WB_Is_CSR),
    .is_WFI(WB_valid && WB_Is_WFI),
    .is_MRET(WB_valid && WB_Is_MRET),
    .csr_inst(WB_inst),
    .csr_rs1_data(WB_rs1_data),
    .csr_data(WB_csr_data),
    .WB_PC(WB_PC),
    .csr_out_PC(csr_out_PC),
    .fetch_continue(fetch_continue),
    .wfi_sleep(wfi_sleep)
);

assign WB_final_wr_back_data = WB_Is_CSR ? WB_csr_data : WB_wr_back_data;

endmodule