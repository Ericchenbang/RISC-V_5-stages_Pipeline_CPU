`include "opcode_def.sv"
`include "ALU_Sel_def.sv"

module Control (
    input   logic   [6:0]   funct7,
    input   logic   [2:0]   funct3, 
    input   logic   [6:0]   opcode,
    input   logic   [4:0]   rs2,        // for clz, ctz, cpop

    output  logic           RegWEn,
    output  logic           FPU_RegWEn,
    output  logic           BrAdder_Sel,
    output  logic           BrUn,

    output  logic   [1:0]   ALU_ASel,
    output  logic   [1:0]   ALU_BSel,
    output  logic   [4:0]   ALU_Sel,
    output  logic   [1:0]   FPU_ASel,
    output  logic   [1:0]   FPU_BSel,
    output  logic   [1:0]   FPU_Sel,

    output  logic   [1:0]   Wr_Data_Sel,
    output  logic           Rs2_Data_Sel,
    output  logic   [1:0]   MemRW,
    output  logic   [2:0]   LDFilter_Sel,
    output  logic   [1:0]   Wr_Back_Sel,

    output  logic           Is_CSR 
);


always_comb begin
/////////////////////////////////
// DEFAULT                     //
/////////////////////////////////
    RegWEn      = 1'b0;
    FPU_RegWEn  = 1'b0;
    BrAdder_Sel = 1'bx;     
    BrUn        = 1'bx;

    ALU_ASel    = 2'bxx;
    ALU_BSel    = 2'bxx;
    ALU_Sel     = 5'hxx;
    FPU_ASel    = 2'bxx;
    FPU_BSel    = 2'bxx;
    FPU_Sel     = 2'bxx;

    Wr_Data_Sel = 2'bxx;
    Rs2_Data_Sel= 1'bx;
    MemRW       = 2'd0;
    LDFilter_Sel= 3'bxxx;
    Wr_Back_Sel = 2'bxx;
    Is_CSR      = 1'b0;
case (opcode)
/////////////////////////////////
// R_TYPE                      //
/////////////////////////////////
R_TYPE: begin       
    RegWEn      = 1'b1;
    FPU_RegWEn  = 1'b0;
    BrAdder_Sel = 1'bx;
    BrUn        = 1'bx;

    ALU_ASel    = 2'b00;
    ALU_BSel    = 2'b00;
    FPU_ASel    = 2'bxx;
    FPU_BSel    = 2'bxx;
    FPU_Sel     = 2'bxx;

    Wr_Data_Sel = 2'bxx;
    Rs2_Data_Sel= 1'bx;
    MemRW       = 2'b00;
    LDFilter_Sel= 3'bxxx;
    Wr_Back_Sel = 2'd1;
    
    Is_CSR      = 1'b0;

    // ALU_Sel
    case (funct3)
        3'b000: begin
            if (funct7[0])      ALU_Sel = MUL;
            else if (funct7[5]) ALU_Sel = SUB;
            else                ALU_Sel = ADD;
        end
        3'b001: begin
            if (funct7[2]) begin
                if (funct7[5])  ALU_Sel = BCLR;
                else            ALU_Sel = BSET;
            end
            else if (funct7[5]) ALU_Sel = ROL;
            else if (funct7[0]) ALU_Sel = MULH;
            else                ALU_Sel = SLL;
        end
        3'b010: begin
            if (funct7[0]) ALU_Sel = MULHSU;
            else           ALU_Sel = SLT;
        end
        3'b011: begin
            if (funct7[0]) ALU_Sel = MULHU;
            else           ALU_Sel = SLTU;
        end
        3'b100: begin   
            if (funct7[0]) ALU_Sel = MIN;
            else           ALU_Sel = XOR;
        end
        3'b101: begin   
            if (funct7[0])      ALU_Sel = MINU;
            else if (funct7[2]) ALU_Sel = BEXT;
            else if (funct7[4]) ALU_Sel = ROR;
            else if (funct7[5]) ALU_Sel = SRA;
            else                ALU_Sel = SRL;
        end
        3'b110: begin   
            if (funct7[0]) ALU_Sel = MAX;
            else           ALU_Sel = OR;
        end
        3'b111: begin   
            if (funct7[0]) ALU_Sel = MAXU;
            else           ALU_Sel = AND;
        end
    endcase
end
/////////////////////////////////
// JAL                         //
/////////////////////////////////
JAL: begin
    RegWEn      = 1'b1;
    FPU_RegWEn  = 1'b0;
    BrAdder_Sel = 1'b1;     // PC
    BrUn        = 1'bx;

    ALU_ASel    = 2'b01;
    ALU_BSel    = 2'b01;
    ALU_Sel     = ADD;
    FPU_ASel    = 2'bxx;
    FPU_BSel    = 2'bxx;
    FPU_Sel     = 2'bxx;

    Wr_Data_Sel = 2'bxx;
    Rs2_Data_Sel= 1'bx;
    MemRW       = 2'b00;
    LDFilter_Sel= 3'bxxx;
    Wr_Back_Sel = 2'd2;         // PC + 4

    Is_CSR      = 1'b0;
end
//////////////////////////////////////////////
// I_TYPE (CLZ, CTZ, CPOP), LOAD, JALR      //
//////////////////////////////////////////////
I_TYPE: begin
    RegWEn      = 1'b1;
    FPU_RegWEn  = 1'b0;
    BrAdder_Sel = 1'bx;
    BrUn        = 1'bx;

    ALU_ASel    = 2'b00;
    ALU_BSel    = 2'b01;
    FPU_ASel    = 2'bxx;
    FPU_BSel    = 2'bxx;
    FPU_Sel     = 2'bxx;

    Wr_Data_Sel = 2'bxx;
    Rs2_Data_Sel= 1'bx;
    MemRW       = 2'd00;
    LDFilter_Sel= 3'bxxx;
    Wr_Back_Sel = 2'd1;     // from ALU

    Is_CSR      = 1'b0;

    case (funct3) 
        3'b000: ALU_Sel = ADD;
        3'b010: ALU_Sel = SLT;
        3'b011: ALU_Sel = SLTU;
        3'b100: ALU_Sel = XOR;
        3'b110: ALU_Sel = OR;
        3'b111: ALU_Sel = AND;
        3'b001: begin
            case(funct7)
                7'b011_0000: begin
                    case(rs2) 
                        5'd0: ALU_Sel = CLZ;
                        5'd1: ALU_Sel = CTZ;
                        5'd2: ALU_Sel = CPOP;
                    endcase
                end
                7'b000_0000: ALU_Sel = SLL;
            endcase
        end
        3'b101: begin
            case(funct7) 
                7'b000_0000: ALU_Sel = SRL;
                7'b010_0000: ALU_Sel = SRA;
            endcase
        end
    endcase
end
LOAD, JALR: begin
    RegWEn      = 1'b1;
    FPU_RegWEn  = 1'b0;   
    BrUn        = 1'bx;

    ALU_ASel    = 2'b00;
    ALU_BSel    = 2'b01;
    ALU_Sel     = ADD;
    FPU_ASel    = 2'bxx;
    FPU_BSel    = 2'bxx;
    FPU_Sel     = 2'bxx;

    Wr_Data_Sel = 2'bxx;
    Rs2_Data_Sel= 1'bx;
    case (opcode)
        LOAD: begin
            BrAdder_Sel = 1'bx;

            MemRW       = 2'b01;
            LDFilter_Sel= funct3;
            Wr_Back_Sel = 2'd0;     // MEM data
        end
        JALR: begin 
            BrAdder_Sel = 1'b0;

            MemRW       = 2'b00;
            LDFilter_Sel= funct3;
            Wr_Back_Sel = 2'd2;     // PC + 4
        end
    endcase
    Is_CSR      = 1'b0;
end
/////////////////////////////////
// STORE                       //
/////////////////////////////////
STORE: begin
    RegWEn      = 1'b0;
    FPU_RegWEn  = 1'b0;
    BrAdder_Sel = 1'bx;
    BrUn        = 1'bx;

    ALU_ASel    = 2'b00;
    ALU_BSel    = 2'b01;
    ALU_Sel     = ADD;
    FPU_ASel    = 2'bxx;
    FPU_BSel    = 2'bxx;
    FPU_Sel     = 2'bxx;

    Wr_Data_Sel = funct3;
    Rs2_Data_Sel= 1'b0;
    MemRW       = 2'b10;
    LDFilter_Sel= 3'bxxx;
    Wr_Back_Sel = 2'bxx;

    Is_CSR      = 1'b0;
end
/////////////////////////////////
// AUIPC, LUI                  //
/////////////////////////////////
AUIPC, LUI_OP: begin
    RegWEn      = 1'b1;
    FPU_RegWEn  = 1'b0;
    BrAdder_Sel = 1'bx;
    BrUn        = 1'bx;

    ALU_ASel    = 2'b01;    // PC
    ALU_BSel    = 2'b01;    // imm
    ALU_Sel     = (opcode == AUIPC) ? ADD : LUI;
    FPU_ASel    = 2'bxx;
    FPU_BSel    = 2'bxx;
    FPU_Sel     = 2'bxx;

    Wr_Data_Sel = 2'bxx;
    Rs2_Data_Sel= 1'bx;
    MemRW       = 2'b00;
    LDFilter_Sel= 3'bxxx;
    Wr_Back_Sel = 2'd1;

    Is_CSR      = 1'b0;
end
/////////////////////////////////
// B_TYPE                      //
/////////////////////////////////
B_TYPE: begin
    RegWEn      = 1'b0;
    FPU_RegWEn  = 1'b0;
    BrAdder_Sel = 1'b1;     // PC

    case(funct3)
        3'b110, 3'b111: BrUn = 1'b1;
        3'b000, 3'b001, 3'b100, 3'b101: BrUn = 1'b0;
    endcase

    ALU_ASel    = 2'bxx;
    ALU_BSel    = 2'bxx;
    ALU_Sel     = 5'hxx;
    FPU_ASel    = 2'bxx;
    FPU_BSel    = 2'bxx;
    FPU_Sel     = 2'bxx;

    Wr_Data_Sel = 2'bxx;
    Rs2_Data_Sel= 1'bx;
    MemRW       = 2'b00;
    LDFilter_Sel= 3'bxxx;
    Wr_Back_Sel = 2'bxx;

    Is_CSR      = 1'b0;
end
/////////////////////////////////
// CSR                         //
/////////////////////////////////
CSR: begin
    RegWEn      = 1'b1;
    FPU_RegWEn  = 1'b0;
    BrAdder_Sel = 1'bx;
    BrUn        = 1'bx;

    ALU_ASel    = 2'b00;
    ALU_BSel    = 2'b00;
    ALU_Sel     = ADD;
    FPU_ASel    = 2'bxx;
    FPU_BSel    = 2'bxx;
    FPU_Sel     = 2'bxx;

    Wr_Data_Sel = 2'd1;
    Rs2_Data_Sel= 1'bx;
    MemRW       = 2'b00;
    LDFilter_Sel= 3'bxxx;
    Wr_Back_Sel = 2'bxx;         

    Is_CSR      = 1'b1;
end
/////////////////////////////////
// F-EXTENSION                 //
/////////////////////////////////
FPR_TYPE: begin
    RegWEn      = 1'b0;
    FPU_RegWEn  = 1'b1;
    BrAdder_Sel = 1'bx;
    BrUn        = 1'bx;

    ALU_ASel    = 2'bxx;
    ALU_BSel    = 2'bxx;
    ALU_Sel     = 5'hxx;
    FPU_ASel    = 2'b00;
    FPU_BSel    = 2'b00;

    Wr_Data_Sel = 2'bxx;
    Rs2_Data_Sel= 1'bx;
    MemRW       = 2'b00;    
    LDFilter_Sel= 3'bxxx;  
    Wr_Back_Sel = 2'd3; 

    Is_CSR      = 1'b0;  
    
    case (funct3) 
        3'b111: begin
            case(funct7[2])
                1'b0: FPU_Sel = 2'b00;  // ADD
                1'b1: FPU_Sel = 2'b01;  // SUB
            endcase
        end
        3'b000: FPU_Sel = 2'b10;    // MIN
        3'b001: FPU_Sel = 2'b11;    // MAX
    endcase
end
FP_LOAD, FP_STORE: begin
    RegWEn      = 1'b0;
    // FPU_RegWEn  = (opcode == FP_LOAD) ? 1'b1 : 1'b0;
    BrAdder_Sel = 1'bx;
    BrUn        = 1'bx;

    ALU_ASel    = 2'b00;    // FLW, FSW need ALU ADD
    ALU_BSel    = 2'b01;
    ALU_Sel     = ADD;
    FPU_ASel    = 2'bxx;
    FPU_BSel    = 2'bxx;
    FPU_Sel     = 2'bxx;
    
    case (opcode)
        FP_LOAD: begin
            Wr_Data_Sel = 2'bxx;
            FPU_RegWEn = 1'b1;

            Rs2_Data_Sel= 1'bx;
            MemRW       = 2'b01;    
            LDFilter_Sel= funct3;   // 3'b010  
            Wr_Back_Sel = 2'd0;
        end
        FP_STORE: begin
            Wr_Data_Sel = 2'b10;
            FPU_RegWEn = 1'b0;
            
            Rs2_Data_Sel= 1'b1;
            MemRW       = 2'b10;    
            LDFilter_Sel= 3'bxxx;  
            Wr_Back_Sel = 2'bxx;
        end
    endcase
    Is_CSR      = 1'b0;
end
/////////////////////////////////
// DSP                         //
/////////////////////////////////
DSP: begin
    RegWEn      = 1'b1;
    FPU_RegWEn  = 1'b0;
    BrAdder_Sel = 1'bx;
    BrUn        = 1'bx;

    ALU_ASel    = 2'b00;
    ALU_BSel    = 2'b00;
    FPU_ASel    = 2'bxx;
    FPU_BSel    = 2'bxx;
    FPU_Sel     = 2'bxx;

    Wr_Data_Sel = 2'bxx;
    Rs2_Data_Sel= 1'bx;
    MemRW       = 2'b00;
    LDFilter_Sel= 3'bxxx;
    Wr_Back_Sel = 2'd1;

    Is_CSR      = 1'b0;

    case (funct3)
        3'b000: ALU_Sel = DOTP4;
        3'b001: ALU_Sel = SADD8;
        3'b010: ALU_Sel = SSUB8;
        3'b011: ALU_Sel = ABS;
        3'b100: ALU_Sel = CLIP8;
    endcase
end
endcase
end
endmodule