; test_jump: a taken beqz; the two instructions after it are flushed.
; r3, r4, r5 stay 0, r6 = 7 is written at the target.
addi r1, r0, #1       ; r1 = 1
addi r2, r0, #0       ; r2 = 0
nop
nop
nop
beqz r2, target       ; taken: r2 = 0
addi r3, r0, #99      ; flushed
addi r4, r0, #99      ; flushed
addi r5, r0, #99      ; never fetched
target:
addi r6, r0, #7       ; target: r6 = 7
nop
nop
nop
nop
nop
