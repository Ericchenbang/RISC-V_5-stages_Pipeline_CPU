# IMEM Handshake Logic
## Finite State Machine
```
         IM_launch == 1
        |------------->|
IM_Require              IM_Wait_valid
        |<-------------|
          im_valid == 1
```

## Helper registers
### `IF_buf_inst`
Store the 32-bit instruction from IMEM 

### `IF_buf_PC`
The original address of the instruction. Afterwards, branch/jump operation can calculate correctly.

### `IF_buf_valid`
Indicates whether it is a valid instruction in the buffer or not. If it's one, instruction is stored but not yet send to IF/ID pipeline register.

## Signals
### `IF_accept`
IF buffer has instruction and IF registers can move forward. Move `IF_PC` forward.

### `IM_launch`
Launch next IMEM request. Send one cycle `im_req` and `im_addr`.

### `IM_discard_response`
When redirect, there is a response for wrong `im_addr` still be waiting. After received that `im_valid`, CPU discards that response.

## Handshake process
1. Launch request: `IM_launch` is setup. CPU send `IF_PC` to `im_addr`, and setup `im_req`. State transforms from `IM_Require` to `IM_Wait_valid`.
2. Wait Response
3. Get Response: `im_valid` be pulled up, CPU send `im_read_data` to `IF_buf_inst`, `im_addr` to `IF_buf_PC` and set `IF_buf_valid` to 1.
4. Send to IF/ID: Only if `IF_buf_valid` is setup and IF/ID no need to stall or redirect, then `IF_accept` setup. IF/ID pipeline register receive instruction and PC on positive clock edge. `IF_buf_valid` clear to zero, `IF_PC` plus 4.



