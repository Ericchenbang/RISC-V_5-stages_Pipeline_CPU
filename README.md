# RISC-V 5-stages Pipeline CPU
This is a 32-bit, five-stage pipelined RISC-V CPU that implements a subset of the RV32IMF ISA, selected instructions from the B (bit-manipulation) extension, and custom DSP instructions. It also supports selected Zicsr instructions and the `cycle` and `instret` counters.

## Datapath
![datapath_pic](./CPU_datapath_v5.png)

- Blue lines represent pipeline registers
- Black lines represent wires and other hardware units
- Purple lines represent control signal
- Green and orange lines represent M and WB stage forwarding


### [Stall and flush logic](./docs/Stall_Flush_Logic.md)

### [Forwarding logic](./docs/Forwarding_Logic.md)

### [IMEM handshake logic](./docs/IM_Handshake.md)

### [DMEM handshake logic](./docs/DM_Handshake.md)