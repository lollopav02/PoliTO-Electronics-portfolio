; test_jump2: a taken bnez and an unconditional j; the two instructions
; after each of them are flushed. r2, r3, r5, r6 stay 0.
addi r1, r0, #5       ; r1 = 5
nop
nop
nop
bnez r1, target1      ; taken: r1 != 0
addi r2, r0, #99      ; flushed
addi r3, r0, #99      ; flushed
target1:
addi r4, r0, #1       ; target: r4 = 1
j target2             ; always taken
addi r5, r0, #99      ; flushed
addi r6, r0, #99      ; flushed
target2:
addi r7, r0, #2       ; target: r7 = 2
nop
nop
nop
nop
nop
