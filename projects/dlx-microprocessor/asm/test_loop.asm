; test_loop: writes 1..5 in memory, then a loop reads them back and adds
; them; the sum, 15, is stored in DRAM[5].
addi r1, r0, #1
sw   0(r0), r1        ; DRAM[0] = 1
addi r1, r0, #2
sw   4(r0), r1        ; DRAM[1] = 2
addi r1, r0, #3
sw   8(r0), r1        ; DRAM[2] = 3
addi r1, r0, #4
sw   12(r0), r1       ; DRAM[3] = 4
addi r1, r0, #5
sw   16(r0), r1       ; DRAM[4] = 5
addi r2, r0, #0       ; address of the current word
addi r3, r0, #5       ; loop counter
addi r4, r0, #0       ; sum
loop:
lw   r5, 0(r2)        ; next word
add  r4, r4, r5       ; sum += word   load-use: one stall cycle
addi r2, r2, #4       ; next address
subi r3, r3, #1
bnez r3, loop         ; depends on the subi just before: forwarding to the zero test
sw   20(r0), r4       ; DRAM[5] = 15
done:
j    done             ; stops the processor
nop
nop
