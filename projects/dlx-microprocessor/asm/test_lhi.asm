lhi  r1, #4660       ; r1 = 12340000
ori  r1, r1, #22136  ; r1 = 12345678, r1 from forwarding
lhi  r2, #32768      ; r2 = 80000000
addi r3, r2, #1      ; r3 = 80000001
lhi  r4, #1          ; r4 = 00010000
add  r5, r1, r4      ; r5 = 12355678
nop
nop
nop
nop
