; test_cmp: signed set-on-condition instructions, R-type and immediate.
; The result is 1 if the condition is true, 0 otherwise.
addi r1, r0, #12      ; r1 = 12
addi r2, r0, #5       ; r2 = 5
addi r3, r0, #-3      ; r3 = -3 (0xFFFFFFFD)
sge  r4, r1, r2       ; 12 >= 5   -> 1
sle  r5, r1, r2       ; 12 <= 5   -> 0
sne  r6, r1, r2       ; 12 != 5   -> 1
sge  r7, r3, r2       ; -3 >= 5   -> 0  (signed comparison)
sle  r8, r3, r2       ; -3 <= 5   -> 1
sne  r9, r1, r1       ; 12 != 12  -> 0
sgei r10, r1, #12     ; 12 >= 12  -> 1
slei r11, r3, #-3     ; -3 <= -3  -> 1
snei r12, r2, #5      ; 5 != 5    -> 0
nop
nop
nop
nop
nop
