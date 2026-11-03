# 5-Stage Pipelined RISC-V CPU

## Control Signal
### IF 
### ID


| Signal \ Value | 0 | 1 |
| -------- | -------- | -------- |
| BrUn       | Signed Comp    | Unsigned Comp   |
| BrEq (out) | Not equal    | Equal    |
| BrLt (out) | Not less than    | Less than    |
| BrAdd_Sel | rs1_data | PC|


### EX

| Signal \ Value | 0 | 1 | 2 | 3|
| - | - | - |-|-|
| ALU_ASel | rs1_data | PC | EX to EX forwarding | M to EX forwarding  |
| ALU_BSel | rs2_data | Imm | EX to EX forwarding |M to EX forwarding| 

- ALU_Sel

|Value|Operation|Value|Operation|Value|Operation
|-|-|-|-|-|-|
|0|ADD|14|CLZ|26|DOTP4
|1|SUB|15|CTZ|27|SADD8|
|2|SLL|16|CPOP|28|SSUB8|
|3|SLT|17|ROL|29|ABS|
|4|SLTU|18|ROR|30|CLIP8|
|5|XOR|19|MIN|
|6|SRL|20|MAX|
|7|SRA|21|MINU|
|8|OR|22|MAXU|
|9|AND|23|BSET|
|10|MUL|24|BCLR|
|11|MULH|25|BEXT|
|12|MULHSU|
|13|MULHU|

- FPU_ASel

|0|1|2|
|-|-|-|
|fp_rs1_data|EX to EX forwarding|M to EX forwarding|

- FPU_BSel

|0|1|2|
|-|-|-|
|fp_rs2_data|EX to EX forwarding|M to EX forwarding|


- FPU_Sel

|0|1|2|3|
|-|-|-|-|
|ADD (fp)|SUB (fp)|MIN|MAX|

- Is_FP_TYPE

|0|1|
|-|-|
|not FP_TYPE | is FP_TYPE|


### M
- Wr_Data_Sel

|0|1|2
|-|-|-|
|SB|SH|SW|


- Rs2_Data_Sel

|0|1|
|-|-|
|rs2_data| fp_rs2_data|

- MemRW

|0|1|2|
|-|-|-|
|No Read or Write |Read | Write|

- LDFilter_Sel

|0|1|2|4|5
|-|-|-|-|-|
|LB |LH|LW|LBU|LHU|

- Wr_Back_Sel

|0|1|2|3|
|-|-|-|-|
|Mem data |ALU_out | PC + 4| FP_out | 

### WB

|Signal |0|1|
|-|-|-|
|Is_CSR|Data from pipeline register|CSR data|
| RegWEn     | Can't write    | Can write    |
| FPU_RegWEn | Can't write    | Can write    |


## Hardware Unit
### ImmGen
```
input  [31:0] inst;
output [31:0] imm;
```
- I-type, JALR, LOAD
- STORE
- B-type
- AUIPC, LUI
- JAL


### Forwarding
- FW_ALU_ASel
- FW_ALU_BSel
- FW_FPU_ASel
- FW_FPU_BSel
- FW_Store_Data_Sel
- FW_FP_Store_Data_Sel

| value |meaning|
|--|--|
| 0| use the value determined by *_*Sel|
| 1| forward the M-stage write-back value|
| 2| forward the WB-stage final write-back value|
| 3| M-stage matches but the result is not ready; stall needed|