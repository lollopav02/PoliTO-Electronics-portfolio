; test_mem: store and load, also of a negative value, a load-use stall
; and a computed value stored again. Final memory: 7, -2, 16.
addi r1, r0, #7       ; r1 = 7
addi r2, r0, #-2      ; r2 = -2 (0xFFFFFFFE)
sw   0(r0), r1        ; DRAM[0] = 7
sw   4(r0), r2        ; DRAM[1] = -2
lw   r3, 0(r0)        ; r3 = 7
add  r4, r3, r3       ; r4 = 0x0E   load-use: one stall cycle
lw   r5, 4(r0)        ; r5 = -2
sub  r6, r4, r5       ; r6 = 0x10   (14 - (-2) = 16)
sw   8(r0), r6        ; DRAM[2] = 16
nop
nop
nop
nop
nop
