module hw3_cache_core #(parameter bit READ_ONLY = 0) (
    input  logic        clk, rst, cpu_req, cpu_web,
    input  logic [31:0] cpu_addr, cpu_wdata, cpu_bit_en,    // cpu_bit_en active low
    output logic        cpu_valid,
    output logic [31:0] cpu_rdata,
    
    input  logic        mem_busy, mem_rsp, mem_error,
    input  logic [31:0] mem_rdata,
    output logic        mem_req, 
    output logic        mem_write,      // 1: write, 0: read
    output logic [31:0] mem_addr, mem_wdata,
    output logic [3:0]  mem_wstrb       // for write, active high: write
);

logic        data_en, data_we;
logic [5:0]  data_addr;
logic [31:0] data_rdata;
logic [31:0] data_wdata;
logic        tag_en, tag_we;
logic [3:0]  tag_addr;
logic [23:0] tag_wdata;
logic [23:0] tag_rdata;

// we = 0: read; we = 1: write
hw3_cache_storage storage (
    .clk(clk),.rst(rst),
    .data_en(data_en), .data_we(data_we), .data_addr(data_addr),
    .data_wdata(data_wdata), .data_rdata(data_rdata),
    .tag_en(tag_en), .tag_we(tag_we), .tag_addr(tag_addr),
    .tag_wdata(tag_wdata), .tag_rdata(tag_rdata)
);

// TODO: implement request capture, valid FFs, lookup and miss/refill control.
// TODO: implement D-cache write-through/no-write-allocate and byte merging.
// TODO: clarigy bit offset, wstrb in each write condition

// valid bit for Cache
logic cache_valid [0:15];

localparam StandBy      = 3'd0;
localparam Cache        = 3'd1;
localparam Compare      = 3'd2;
localparam Read         = 3'd3;
localparam Read_Rsp     = 3'd4;
localparam Write        = 3'd5;
localparam Write_Rsp    = 3'd6;

logic [2:0] state;
logic [2:0] next_state;

logic           web;            // 1: Read, 0: Write; 
                                // But SRAM_Behavior we = 0: read, 1: write
logic           hit;            // 1: Hit,  0: Miss
logic [1:0]     readmem_cnt; 

logic [3:0]     index;
logic [1:0]     word_offset;
logic [1:0]     byte_offset;
logic [23:0]    tag;

logic [31:0]    write_data;
logic [31:0]    bit_en;

logic compare_hit;
assign compare_hit = cache_valid[index] && (tag_rdata == tag);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= StandBy;
    end
    else begin
        state <= next_state;
    end
end

always_comb begin
    next_state = state;
    case (state)
        StandBy: if (cpu_req) next_state = Cache;
        Cache:                next_state = Compare;
        Compare: begin
            if (web) begin
                if (compare_hit) begin
                    next_state = StandBy;
                end
                else begin
                    if (!mem_busy) next_state = Read_Rsp;
                    else           next_state = Read;
                end
            end
            else begin
                if (!mem_busy) next_state = Write_Rsp;
                else           next_state = Write;
            end
        end
        Read: if (!mem_busy) next_state = Read_Rsp;
        Read_Rsp: begin
            if (mem_rsp) begin
                if (readmem_cnt == 2'd3) next_state = StandBy;
                else if (mem_busy)       next_state = Read;
            end
        end
        Write: if (!mem_busy)       next_state = Write_Rsp;
        Write_Rsp: if (mem_rsp) next_state = StandBy;
    endcase
end 

integer i;
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        cpu_valid <= 1'b0;
        mem_req <= 1'b0;

        for (i = 0; i < 16; i = i + 1) begin
            cache_valid[i] <= 1'b0;
        end

        data_en <= 1'b0;
        tag_en <= 1'b0;

        web <= 1'b0;
        hit <= 1'b0;
        readmem_cnt <= 2'd0;

        index <= 4'd0;
        word_offset <= 2'd0;
        byte_offset <= 2'd0;
        tag         <= 24'd0;
        
        write_data <= 32'd0;
        bit_en <= 32'd0;
    end
    else if (state == StandBy) begin
        cpu_valid <= 1'b0;
        mem_req <= 1'b0;
        
        if (cpu_req) begin
            web <= cpu_web;

            index       <= cpu_addr[7:4];
            word_offset <= cpu_addr[3:2];
            byte_offset <= cpu_addr[1:0];
            tag         <= cpu_addr[31:8];

            // Read and write both has to know the data in cache
            data_en <= 1'b1;
            data_we <= 1'b0;
            data_addr <= cpu_addr[7:2]; 
            write_data <= cpu_wdata;
            bit_en <= cpu_bit_en;
            
            tag_en <= 1'b1;
            tag_we <= 1'b0;
            tag_addr <= cpu_addr[7:4];
        end
        else begin
            data_en <= 1'b0;
            tag_en <= 1'b0;
        end
    end
    else if (state == Cache) begin
        data_en <= 1'b0;
        tag_en <= 1'b0;
    end
    else if (state == Compare) begin
        if (compare_hit) hit <= 1'b1;
        else             hit <= 1'b0;

        if (web) begin              // Read
            if (compare_hit) begin
                cpu_valid <= 1'b1;
                cpu_rdata <= data_rdata;
            end
            else begin
                if (!mem_busy) begin
                    mem_req <= 1'b1;
                    mem_write <= 1'b0;
                    mem_addr <= {tag, index, 2'b00, 2'b00};
                end
            end
        end
        else begin                  // Write
            if (compare_hit) begin
                data_en <= 1'b1;
                data_we <= 1'b1;
                data_addr <= {index, word_offset};
                data_wdata <= (data_rdata & bit_en) | (write_data & ~bit_en);
            end
            
            if (!mem_busy) begin
                mem_req <= 1'b1;
                mem_write <= 1'b1;
                mem_addr <= {tag, index, word_offset, 2'b00};
                mem_wdata <= write_data;
                mem_wstrb[0] <= bit_en[7:0] == 8'd0;
                mem_wstrb[1] <= bit_en[15:8] == 8'd0;
                mem_wstrb[2] <= bit_en[23:16] == 8'd0;
                mem_wstrb[3] <= bit_en[31:24] == 8'd0;
            end
        end
    end
    else if (state == Read) begin
        data_en <= 1'b0;
        tag_en <= 1'b0;

        if (!mem_busy) begin
            mem_req <= 1'b1;
            mem_write <= 1'b0;
            mem_addr <= {tag, index, readmem_cnt, 2'b00};
        end
    end
    else if (state == Read_Rsp) begin
        if (mem_rsp) begin
            readmem_cnt <= readmem_cnt + 1;

            if (readmem_cnt == word_offset) begin
                cpu_rdata <= mem_rdata;
            end

            data_en <= 1'b1;
            data_we <= 1'b1;
            data_addr <= {index, readmem_cnt};
            data_wdata <= mem_rdata;

            if (readmem_cnt == 2'd3) begin
                mem_req <= 1'b0;
                cpu_valid <= 1'b1;

                tag_en <= 1'b1;
                tag_we <= 1'b1;
                tag_addr <= index;
                tag_wdata <= tag;

                cache_valid[index] <= 1'b1;
            end
            else begin
                if (!mem_busy) begin
                    mem_req <= 1'b1;
                    mem_write <= 1'b0;
                    mem_addr <= {tag, index, readmem_cnt + 2'd1, 2'b00};
                end
                else mem_req <= 1'b0;
            end
        end
        else begin
            data_en <= 1'b0;
            tag_en <= 1'b0;
            mem_req <= 1'b0;
        end
    end
    else if (state == Write) begin
        data_en <= 1'b0;
        if (!mem_busy) begin
            mem_req <= 1'b1;
            mem_write <= 1'b1;
            mem_addr <= {tag, index, word_offset, 2'b00};
            mem_wdata <= write_data;
            mem_wstrb[0] <= bit_en[7:0] == 8'd0;
                mem_wstrb[1] <= bit_en[15:8] == 8'd0;
                mem_wstrb[2] <= bit_en[23:16] == 8'd0;
                mem_wstrb[3] <= bit_en[31:24] == 8'd0;
        end
    end
    else if (state == Write_Rsp) begin
        if (mem_rsp) begin
            cpu_valid <= 1'b1;
        end
        data_en <= 1'b0;
        mem_req <= 1'b0;
    end
end


endmodule
