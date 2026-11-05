###################################################################

# Created by write_sdc on Tue Oct  6 11:03:43 2026

###################################################################
set sdc_version 2.1

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current mA
set_wire_load_model -name 5K_hvratio_1_4 -library NangateOpenCellLibrary
create_clock [get_ports Clk]  -name CLK  -period 1.7  -waveform {0 0.85}
set_max_delay 1.7  -from [list [get_ports Clk] [get_ports Rst] [get_ports {IRAM_IN[31]}]         \
[get_ports {IRAM_IN[30]}] [get_ports {IRAM_IN[29]}] [get_ports {IRAM_IN[28]}]  \
[get_ports {IRAM_IN[27]}] [get_ports {IRAM_IN[26]}] [get_ports {IRAM_IN[25]}]  \
[get_ports {IRAM_IN[24]}] [get_ports {IRAM_IN[23]}] [get_ports {IRAM_IN[22]}]  \
[get_ports {IRAM_IN[21]}] [get_ports {IRAM_IN[20]}] [get_ports {IRAM_IN[19]}]  \
[get_ports {IRAM_IN[18]}] [get_ports {IRAM_IN[17]}] [get_ports {IRAM_IN[16]}]  \
[get_ports {IRAM_IN[15]}] [get_ports {IRAM_IN[14]}] [get_ports {IRAM_IN[13]}]  \
[get_ports {IRAM_IN[12]}] [get_ports {IRAM_IN[11]}] [get_ports {IRAM_IN[10]}]  \
[get_ports {IRAM_IN[9]}] [get_ports {IRAM_IN[8]}] [get_ports {IRAM_IN[7]}]     \
[get_ports {IRAM_IN[6]}] [get_ports {IRAM_IN[5]}] [get_ports {IRAM_IN[4]}]     \
[get_ports {IRAM_IN[3]}] [get_ports {IRAM_IN[2]}] [get_ports {IRAM_IN[1]}]     \
[get_ports {IRAM_IN[0]}] [get_ports {DRAM_IN[31]}] [get_ports {DRAM_IN[30]}]   \
[get_ports {DRAM_IN[29]}] [get_ports {DRAM_IN[28]}] [get_ports {DRAM_IN[27]}]  \
[get_ports {DRAM_IN[26]}] [get_ports {DRAM_IN[25]}] [get_ports {DRAM_IN[24]}]  \
[get_ports {DRAM_IN[23]}] [get_ports {DRAM_IN[22]}] [get_ports {DRAM_IN[21]}]  \
[get_ports {DRAM_IN[20]}] [get_ports {DRAM_IN[19]}] [get_ports {DRAM_IN[18]}]  \
[get_ports {DRAM_IN[17]}] [get_ports {DRAM_IN[16]}] [get_ports {DRAM_IN[15]}]  \
[get_ports {DRAM_IN[14]}] [get_ports {DRAM_IN[13]}] [get_ports {DRAM_IN[12]}]  \
[get_ports {DRAM_IN[11]}] [get_ports {DRAM_IN[10]}] [get_ports {DRAM_IN[9]}]   \
[get_ports {DRAM_IN[8]}] [get_ports {DRAM_IN[7]}] [get_ports {DRAM_IN[6]}]     \
[get_ports {DRAM_IN[5]}] [get_ports {DRAM_IN[4]}] [get_ports {DRAM_IN[3]}]     \
[get_ports {DRAM_IN[2]}] [get_ports {DRAM_IN[1]}] [get_ports {DRAM_IN[0]}]]  -to [list [get_ports {IRAM_ADDR[31]}] [get_ports {IRAM_ADDR[30]}] [get_ports  \
{IRAM_ADDR[29]}] [get_ports {IRAM_ADDR[28]}] [get_ports {IRAM_ADDR[27]}]       \
[get_ports {IRAM_ADDR[26]}] [get_ports {IRAM_ADDR[25]}] [get_ports             \
{IRAM_ADDR[24]}] [get_ports {IRAM_ADDR[23]}] [get_ports {IRAM_ADDR[22]}]       \
[get_ports {IRAM_ADDR[21]}] [get_ports {IRAM_ADDR[20]}] [get_ports             \
{IRAM_ADDR[19]}] [get_ports {IRAM_ADDR[18]}] [get_ports {IRAM_ADDR[17]}]       \
[get_ports {IRAM_ADDR[16]}] [get_ports {IRAM_ADDR[15]}] [get_ports             \
{IRAM_ADDR[14]}] [get_ports {IRAM_ADDR[13]}] [get_ports {IRAM_ADDR[12]}]       \
[get_ports {IRAM_ADDR[11]}] [get_ports {IRAM_ADDR[10]}] [get_ports             \
{IRAM_ADDR[9]}] [get_ports {IRAM_ADDR[8]}] [get_ports {IRAM_ADDR[7]}]          \
[get_ports {IRAM_ADDR[6]}] [get_ports {IRAM_ADDR[5]}] [get_ports               \
{IRAM_ADDR[4]}] [get_ports {IRAM_ADDR[3]}] [get_ports {IRAM_ADDR[2]}]          \
[get_ports {IRAM_ADDR[1]}] [get_ports {IRAM_ADDR[0]}] [get_ports               \
{DRAM_ADDR[31]}] [get_ports {DRAM_ADDR[30]}] [get_ports {DRAM_ADDR[29]}]       \
[get_ports {DRAM_ADDR[28]}] [get_ports {DRAM_ADDR[27]}] [get_ports             \
{DRAM_ADDR[26]}] [get_ports {DRAM_ADDR[25]}] [get_ports {DRAM_ADDR[24]}]       \
[get_ports {DRAM_ADDR[23]}] [get_ports {DRAM_ADDR[22]}] [get_ports             \
{DRAM_ADDR[21]}] [get_ports {DRAM_ADDR[20]}] [get_ports {DRAM_ADDR[19]}]       \
[get_ports {DRAM_ADDR[18]}] [get_ports {DRAM_ADDR[17]}] [get_ports             \
{DRAM_ADDR[16]}] [get_ports {DRAM_ADDR[15]}] [get_ports {DRAM_ADDR[14]}]       \
[get_ports {DRAM_ADDR[13]}] [get_ports {DRAM_ADDR[12]}] [get_ports             \
{DRAM_ADDR[11]}] [get_ports {DRAM_ADDR[10]}] [get_ports {DRAM_ADDR[9]}]        \
[get_ports {DRAM_ADDR[8]}] [get_ports {DRAM_ADDR[7]}] [get_ports               \
{DRAM_ADDR[6]}] [get_ports {DRAM_ADDR[5]}] [get_ports {DRAM_ADDR[4]}]          \
[get_ports {DRAM_ADDR[3]}] [get_ports {DRAM_ADDR[2]}] [get_ports               \
{DRAM_ADDR[1]}] [get_ports {DRAM_ADDR[0]}] [get_ports {DRAM_DIN[31]}]          \
[get_ports {DRAM_DIN[30]}] [get_ports {DRAM_DIN[29]}] [get_ports               \
{DRAM_DIN[28]}] [get_ports {DRAM_DIN[27]}] [get_ports {DRAM_DIN[26]}]          \
[get_ports {DRAM_DIN[25]}] [get_ports {DRAM_DIN[24]}] [get_ports               \
{DRAM_DIN[23]}] [get_ports {DRAM_DIN[22]}] [get_ports {DRAM_DIN[21]}]          \
[get_ports {DRAM_DIN[20]}] [get_ports {DRAM_DIN[19]}] [get_ports               \
{DRAM_DIN[18]}] [get_ports {DRAM_DIN[17]}] [get_ports {DRAM_DIN[16]}]          \
[get_ports {DRAM_DIN[15]}] [get_ports {DRAM_DIN[14]}] [get_ports               \
{DRAM_DIN[13]}] [get_ports {DRAM_DIN[12]}] [get_ports {DRAM_DIN[11]}]          \
[get_ports {DRAM_DIN[10]}] [get_ports {DRAM_DIN[9]}] [get_ports {DRAM_DIN[8]}] \
[get_ports {DRAM_DIN[7]}] [get_ports {DRAM_DIN[6]}] [get_ports {DRAM_DIN[5]}]  \
[get_ports {DRAM_DIN[4]}] [get_ports {DRAM_DIN[3]}] [get_ports {DRAM_DIN[2]}]  \
[get_ports {DRAM_DIN[1]}] [get_ports {DRAM_DIN[0]}] [get_ports DRAM_WE]]
