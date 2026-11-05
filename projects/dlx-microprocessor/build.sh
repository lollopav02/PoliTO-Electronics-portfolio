#!/bin/bash
# Assembles a test program, loads it into the instruction memory and starts
# the simulation in QuestaSim. Run ./compile.sh once before this script.
# usage: ./build.sh test_alu        (program asm/test_alu.asm, without .asm)

PROG=$1
if [ -z "$PROG" ]; then
  echo "usage: ./build.sh <program_name>   (without .asm)"
  exit 1
fi

if [ ! -f "asm/$PROG.asm" ]; then
  echo "ERROR: asm/$PROG.asm does not exist"
  exit 1
fi

# normalize Windows (CR+LF) and old Mac (CR) line endings, then assemble the
# program and convert the binary into the text file read by the IRAM
tr '\r' '\n' < "asm/$PROG.asm" > test.asm
./assembler.bin/dlxasm.pl test.asm > /dev/null || { echo "ERROR: assembler failed"; exit 1; }
./assembler.bin/conv2memory test.asm.exe > test.asm.mem
sed -i '/^$/d' test.asm.mem          # remove empty lines from the memory file

# quick check: non-empty source lines vs words in the memory file
# (labels and comment lines are counted too, so a difference is not always an error)
ASM=$(grep -c . "asm/$PROG.asm")
MEM=$(wc -l < test.asm.mem)
echo "program: $PROG"
echo "asm lines: $ASM   instructions in .mem: $MEM"
[ "$ASM" -ne "$MEM" ] && echo ">>> WARNING: the two numbers differ (labels and comments are counted as lines)"
echo "first instructions:"
head -10 test.asm.mem

# start the simulation with the waveform setup
vsim -gui -voptargs=+acc -do waves.do work.cfg_tb &
