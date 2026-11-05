view wave
delete wave *
add wave -divider "IF"
add wave -radix hex /tb_dlx/U1/PC
add wave -radix hex /tb_dlx/U1/IRam_DOut
add wave -radix hex /tb_dlx/U1/NPC
add wave -divider "ID"
add wave -radix hex /tb_dlx/U1/IR
add wave -radix hex /tb_dlx/U1/CU_I/cw
add wave -radix hex /tb_dlx/U1/DP_I/rs1
add wave -radix hex /tb_dlx/U1/DP_I/rs2
add wave -radix hex /tb_dlx/U1/DP_I/wr_addr
add wave -radix hex /tb_dlx/U1/DP_I/rf_out1
add wave -radix hex /tb_dlx/U1/DP_I/rf_out2
add wave -radix hex /tb_dlx/U1/DP_I/sign_ext
add wave -divider "EX"
add wave -radix hex /tb_dlx/U1/DP_I/muxA_out
add wave -radix hex /tb_dlx/U1/DP_I/muxB_out
add wave            /tb_dlx/U1/DP_I/ALU_OPCODE
add wave -radix hex /tb_dlx/U1/DP_I/alu_out
add wave            /tb_dlx/U1/DP_I/cond
add wave -divider "MEM"
add wave -radix hex /tb_dlx/U1/DP_DADDR
add wave -radix hex /tb_dlx/U1/DP_DOUT
add wave            /tb_dlx/U1/DRAM_WE_i
add wave -radix hex /tb_dlx/U1/DRAM_Dout
add wave            /tb_dlx/U1/DP_I/take_branch
add wave -divider "WB"
add wave -radix hex /tb_dlx/U1/DP_I/regrd_wb
add wave -radix hex /tb_dlx/U1/DP_I/wr_data
add wave            /tb_dlx/U1/DP_I/RF_WE
add wave -divider "HAZARDS"
add wave            /tb_dlx/U1/STALL_i
add wave            /tb_dlx/U1/FLUSH_i
add wave            /tb_dlx/U1/CU_I/flush_d
add wave -radix hex /tb_dlx/U1/DP_I/fwdA
add wave -radix hex /tb_dlx/U1/DP_I/fwdB
add wave -divider "STATE"
add wave -radix hex /tb_dlx/U1/DP_I/REG_FILE/REGISTERS
add wave            /tb_dlx/U1/DRAM_I/DRAM_mem
run 60 ns
wave zoom full