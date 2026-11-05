; test_stalls: forwarding at distance 1 needs no stall, the load-use case
; costs exactly one stall cycle.
addi r2, r0, #1       ; r2 = 1 (address 1 = word 0: the two low bits are ignored)
addi r4, r0, #12      ; r4 = 12
sw   0(r2), r4        ; DRAM[0] = 12   r4 forwarded from the instruction just before
lw   r1, 0(r2)        ; r1 = 12
subi r3, r1, #5       ; r3 = 7         load-use: one stall cycle
nop
nop
nop
nop
nop
