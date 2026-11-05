; test_jal: jal jumps, flushes the two following instructions and writes
; the return address into r31 (8, the address after the jal).
addi r1, r0, #5       ; r1 = 5
jal  sub1             ; r31 = 8
addi r2, r0, #99      ; flushed
addi r3, r0, #99      ; flushed
done:
addi r4, r0, #7       ; skipped by the jal
sub1:
addi r5, r0, #3       ; called routine: r5 = 3
stop:
j    stop             ; stops the processor
nop
nop
