; test_all: every basic instruction in one program, with forwarding,
; load-use stall, flushes after branches and jumps, jal and a loop.
; Each instruction that must be cancelled by a flush writes r27:
; r27 = 0 at the end proves that every flush worked.
addi r1, r0, #12      ; r1 = 0x0C
addi r2, r0, #5       ; r2 = 0x05
add  r3, r1, r2       ; r3 = 0x11   r2 forwarded from MEM, r1 from WB
sub  r4, r3, r2       ; r4 = 0x0C
and  r5, r1, r2       ; r5 = 0x04
or   r6, r1, r2       ; r6 = 0x0D
xor  r7, r1, r2       ; r7 = 0x09
sll  r8, r2, r2       ; r8 = 0xA0
srl  r9, r8, r2       ; r9 = 0x05
subi r10, r1, #2      ; r10 = 0x0A
andi r11, r1, #6      ; r11 = 0x04
ori  r12, r1, #3      ; r12 = 0x0F
xori r13, r1, #15     ; r13 = 0x03
slli r14, r2, #3      ; r14 = 0x28
srli r15, r14, #2     ; r15 = 0x0A
addi r16, r0, #-3     ; r16 = 0xFFFFFFFD
sge  r17, r1, r2      ; 12 >= 5  -> 1
sle  r18, r2, r1      ; 5 <= 12  -> 1
sne  r19, r1, r2      ; 12 != 5  -> 1
sle  r20, r16, r2     ; -3 <= 5  -> 1   (it would be 0 with an unsigned comparison)
slei r21, r16, #-3    ; -3 <= -3 -> 1
sgei r22, r1, #12     ; 12 >= 12 -> 1
snei r23, r2, #4      ; 5 != 4   -> 1
sw   0(r0), r3        ; DRAM[0] = 17
sw   4(r0), r16       ; DRAM[1] = -3
lw   r24, 0(r0)       ; r24 = 17
add  r24, r24, r1     ; r24 = 0x1D   load-use: one stall cycle
lw   r25, 4(r0)       ; r25 = 0xFFFFFFFD
sw   8(r0), r24       ; DRAM[2] = 29
beqz r0, l1           ; taken
addi r27, r0, #99     ; flushed
addi r27, r0, #98     ; flushed
l1:
bnez r25, l2          ; taken
addi r27, r0, #99     ; flushed
addi r27, r0, #98     ; flushed
l2:
beqz r1, l3           ; NOT taken
addi r26, r0, #1      ; executed -> r26 = 1
l3:
jal  func             ; r31 = 0x98, the return address
addi r27, r0, #99     ; flushed
addi r27, r0, #98     ; flushed
func:
addi r28, r0, #7      ; r28 = 7
addi r29, r0, #3      ; loop counter
loop:
add  r30, r30, r29    ; r30 = 3 + 2 + 1 = 6
subi r29, r29, #1
bnez r29, loop        ; depends on the subi just before: forwarding to the zero test
done:
j    done             ; stops the processor
nop
nop
