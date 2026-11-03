# FPU Logic
> Current FPU only support `FADD.S`, `FSUB.S`, `FMIN.S` and `FMAX.S`. `FLW` and `FSW` will do the address addition in ALU.
The floating point number is IEEE-754 standard.

FPU instantiate FPU_Adder and FPU_Comp. The former one implement addition of two floating point number, and the latter one implement comparison of two floating point number.