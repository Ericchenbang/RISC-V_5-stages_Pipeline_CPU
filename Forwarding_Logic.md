# Forwarding Logic
## operand in EX stage needs forwarding (ALU / FPU calculation)
First, we need to determine the instruction in EX stage use int or fp rs1 or rs2 by the input opcode. Also the stored data into DMEM.

Second, we check if `RegWEn` or `FPU_RegWEn` in M or WB stage is set up, and if rd is match with rs1 or rs2. Specially for RegFile, `x0` is always zero. So if rd is x0 then it's no need to forwarding.

Third, the read data for DMEM may be some latency so that the forwarding need to wait for it. And I implement CSR logic in WB stage, therefore, if the instruction in M stage is CSR and it rd is equal to rs1 or rs2 in EX stage, it also has to wait.
The output signal `FW_Stall` is to indicate whether the forwarding needs CPU to stall or not.

Fourth, I create a function to assign the value of each `*_Sel` signal. 
|value | meaning|
| -- | --|
| `2'b00`| use the value read from the RF or FP_RF|
| `2'b01`| forward the M-stage write-back value|
| `2'b10`| forward the WB-stage final write-back value|
| `2'b11`| M-stage producer matches, but its result is not ready; stall required|

1. For `ALU_A/BSel`, we need to check if the operand is from register file, since it may be from PC or Imm.
2. Then we check for M stage forwarding in above second step. Since if M and WB also match, M stage has a newer update of the rd. And we need to check if the result of M is ready or not, which mentioned in above third step.
3. Then we check for WB stage forwarding in above second step.

## operand in ID stage needs forwarding (branch / jump calculation)
Only int rs1/rs2 need forwarding in ID stage. We check if the rd in EX, M or WB stage is equal to the source registers in ID stage. And check if it is x0 or not.

The logic is first check the instruction in ID is B_TYPE or JALR or neither. Then check the equivalence on last step. 

If it is match to EX stage or the result of M stage is not yet ready, we need to stall the CPU.

