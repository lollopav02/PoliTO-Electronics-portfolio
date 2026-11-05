; test_branch: every branch and jump, taken and not taken. Every instruction
; writing r10..r17 follows a taken branch or jump, so they all stay 0.
addi r1, r0, #3       ; r1 = 3
addi r2, r0, #0       ; r2 = 0
beqz r2, l1           ; taken
addi r10, r0, #99     ; flushed
addi r11, r0, #99     ; flushed
l1:
bnez r1, l2           ; taken
addi r12, r0, #99     ; flushed
addi r13, r0, #99     ; flushed
l2:
beqz r1, l3           ; NOT taken: r1 != 0
addi r3, r0, #1       ; executed -> r3 = 1
l3:
j    l4               ; taken
addi r14, r0, #99     ; flushed
addi r15, r0, #99     ; flushed
l4:
jal  func             ; r31 = 0x38, the return address
addi r16, r0, #99     ; flushed
addi r17, r0, #99     ; flushed
func:
addi r4, r0, #2       ; called routine: r4 = 2
stop:
j    stop             ; stops the processor
nop
nop
nop
nop
nop
