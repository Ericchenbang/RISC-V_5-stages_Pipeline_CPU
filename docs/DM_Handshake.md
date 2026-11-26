# DMEM Handshake Logic
## Finite State Machine
```
           MemRW != 0                   
        |------------->|           |------------->|
DM_Standby             DM_Read_Write             DM_Wait_Valid
    |                                               |
    |                                               |
    |<----------------------------------------------|
                        dm_valid == 1
```



