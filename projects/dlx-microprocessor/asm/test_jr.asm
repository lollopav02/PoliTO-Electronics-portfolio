addi r1, r0, #5      ; r1 = 5
jal  func            ; call func, r31 = 8
addi r2, r1, #1      ; after the return: r2 = 11
addi r10, r0, #48    ; r10 = address of func2
jalr r10             ; call through register, r31 = 20
addi r4, r0, #4      ; after the return: r4 = 4
j    done
addi r9, r0, #99     ; flushed
func:
addi r1, r1, #5      ; r1 = 10
jr   r31             ; return to 8
addi r9, r0, #99     ; flushed
addi r9, r0, #98     ; flushed
func2:
addi r3, r0, #3      ; r3 = 3
jr   r31             ; return to 20
addi r9, r0, #99     ; flushed
addi r9, r0, #98     ; flushed
done:
j    done
nop
nop
