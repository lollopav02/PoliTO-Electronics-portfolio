#!/bin/bash
# Requires the QuestaSim environment: run setmentor first.
# Compiles all the VHDL files of the DLX in dependency order.
# Run it once before build.sh:   ./compile.sh   then   ./build.sh test_all
vlib work
C=a.b-DataPath.core
for f in 000-globals.vhd \
         $C/a.b.a-register_file_v1.vhd \
         $C/a.b.b.a.b.a.a.a-fa.vhd $C/a.b.b.a.b.a.a-rca.vhd $C/a.b.b.a.b.a.b-mux21_4bit.vhd \
         $C/a.b.b.a.b.a-carry_select_block.vhd $C/a.b.b.a.b-sum_generator.vhd \
         $C/a.b.b.a.a.a-g_block.vhd $C/a.b.b.a.a.b-pg_block.vhd $C/a.b.b.a.a.c-pg_net_block.vhd \
         $C/a.b.b.a.a-carry_generator.vhd $C/a.b.b.a-p4_adder.vhd \
         $C/a.b.b-ALU_v1.vhd $C/a.b.c-mux21_v1.vhd $C/a.b.d-register_v1.vhd \
         a.b-DataPath.vhd a.c-IRAM.vhd a.d-DRAM.vhd a.a-CU_HW.vhd a-DLX.vhd \
         test_bench/TB-*.vhd; do
  echo "== $f"; vcom $f | grep -E "Error|Errors:"
done
