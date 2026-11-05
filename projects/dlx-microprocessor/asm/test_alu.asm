; test_alu: arithmetic, logic and shift operations, R-type and immediate,
; on the operands 12 and 5. Each operand comes from the instructions just before.
addi r1, r0, #12      ; r1 = 0x0C
addi r2, r0, #5       ; r2 = 0x05
add  r3, r1, r2       ; r3 = 0x11  (12 + 5)
sub  r4, r3, r2       ; r4 = 0x0C  (17 - 5)
and  r5, r1, r2       ; r5 = 0x04
or   r6, r1, r2       ; r6 = 0x0D
xor  r7, r1, r2       ; r7 = 0x09
subi r8, r1, #2       ; r8 = 0x0A  (12 - 2)
andi r9, r1, #6       ; r9 = 0x04
ori  r10, r1, #3      ; r10 = 0x0F
xori r11, r1, #15     ; r11 = 0x03
sll  r12, r2, r2      ; r12 = 0xA0 (5 << 5)
srl  r13, r12, r2     ; r13 = 0x05 (0xA0 >> 5)
slli r14, r2, #3      ; r14 = 0x28 (5 << 3)
srli r15, r14, #2     ; r15 = 0x0A (0x28 >> 2)
nop
nop
nop
nop
nop
