; test_ext: the instructions of the extended (pro) set: signed and unsigned
; comparisons, arithmetic right shifts, unsigned add and subtract.
; Every comparison is true, so r4..r18 = 1 at the end.
addi  r1, r0, #12       ; r1 = 12
addi  r2, r0, #5        ; r2 = 5
addi  r3, r0, #-3       ; r3 = -3 (0xFFFFFFFD)
seq   r4, r1, r1        ; 12 == 12             -> 1
slt   r5, r2, r1        ; 5 < 12               -> 1
sgt   r6, r1, r2        ; 12 > 5               -> 1
slt   r7, r3, r2        ; -3 < 5 signed        -> 1  (unsigned it would be 0)
sltu  r8, r2, r3        ; 5 < 0xFFFFFFFD       -> 1  (signed it would be 0)
sgtu  r9, r3, r2        ; 0xFFFFFFFD > 5       -> 1  (signed it would be 0)
sleu  r10, r2, r2       ; 5 <= 5               -> 1
sgeu  r11, r3, r1       ; 0xFFFFFFFD >= 12     -> 1
seqi  r12, r2, #5       ; 5 == 5               -> 1
slti  r13, r3, #0       ; -3 < 0               -> 1
sgti  r14, r1, #-1      ; 12 > -1              -> 1
sltui r15, r2, #6       ; 5 < 6                -> 1
sgtui r16, r3, #100     ; 0xFFFFFFFD > 100     -> 1
sleui r17, r2, #5       ; 5 <= 5               -> 1
sgeui r18, r1, #12      ; 12 >= 12             -> 1
sra   r19, r3, r2       ; -3 >> 5 arithmetic   -> 0xFFFFFFFF
srai  r20, r3, #1       ; -3 >> 1 arithmetic   -> 0xFFFFFFFE
addu  r21, r1, r2       ; 12 + 5               -> 0x11
subu  r22, r1, r2       ; 12 - 5               -> 0x07
addui r23, r2, #40000   ; 5 + 0x9C40           -> 0x9C45 (with sign extension: 0xFFFF9C45)
subui r24, r1, #2       ; 12 - 2               -> 0x0A
ori   r25, r0, #32768   ; 0 | 0x8000           -> 0x8000 (with sign extension: 0xFFFF8000)
nop
nop
nop
nop
nop
