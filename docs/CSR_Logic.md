# CSR Logic
> Current CSR only support `RDINSTRETH`, `RDINSTRET`, `RDCYCLEH` and `RDCYCLE`


## cycle
When each positive clk edge, `cycle` plus one.

## instret
Use a `valid` signal from IF to WB, indicating the instruction in WB stage can be counted as a retired instruction or not.
- IF/ID: `IF_buf_valid` shows the instruction is valid or not. When flush, clear to zero.
- ID/EX, EX/M: Passing `valid` signal. When flush, clear to zero.
- M/WB: receive `M_valid` and `!DM_stall` so that if load/store is still waiting for `dm_valid`, the instruction will not be counted.

Drive CSR `instret_inc` signal by `WB_valid`