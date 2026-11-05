# Lorenzo Pavone · Electronics Portfolio

Projects and lab work from my Electronic Engineering studies at **Politecnico di Torino**:
RF hardware design, digital ASIC synthesis, FPGA and microcontroller-based embedded systems.

> Every folder has its own README with goals, methods, results and how to reproduce them.

## Projects

| Project | Area | Tools | Highlights |
|---|---|---|---|
| [Microstrip low-pass filter](projects/microstrip-lowpass-filter) | RF / microwave | MATLAB, AWR Microwave Office, AXIEM, VNA | Full flow from specification to fabricated PCB and VNA measurement; 2.4 GHz cut-off, ~35 dB rejection at 4.8 GHz |
| [Low-power synthesis of a SHA-256 core](projects/sha256-low-power-synthesis) | Digital IC design | Synopsys Design Compiler, PrimeTime, Tcl | 65 nm synthesis at 333 MHz; clock gating + multi-Vt reduce area by 19% vs. baseline; custom PrimeTime timing-path report |
| [Tetris on the LandTiger board](projects/tetris-landtiger) | Embedded C | NXP LPC1768 (Cortex-M3), Keil µVision | Interrupt-driven game with LCD, joystick, ADC-controlled speed, DAC sound, power-ups; host-side unit and fuzz tests |
| [DLX microprocessor](projects/dlx-microprocessor) | Digital IC design / computer architecture | VHDL, QuestaSim, Synopsys Design Compiler, Cadence Innovus | 5-stage pipelined DLX with forwarding, 50 instructions and P4 adder; 588 MHz and 15.1k µm² after place & route (NanGate 45 nm) |

## Labs

| Course | Platform | Topics |
|---|---|---|
| [Electronics for Embedded Systems](labs/electronics-for-embedded-systems) (2025/26) | Intel Cyclone V FPGA (DE1-SoC), Nios II, breadboard analog circuits | FPGA flow and timing, software vs. hardware UART, **SAR ADC** design and characterization, BJT switching with PWM |
| [Digital Systems Electronics](labs/digital-systems-electronics) (2023/24) | FPGA (VHDL), STM32 Nucleo-F401RE | Combinational and sequential VHDL, FSMs, **FIR filter datapath + control unit**, bare-metal STM32 GPIO, timers, interrupts, PWM, DMA |
| [Microelectronic Systems](labs/microelectronic-systems) (2025/26) | Synopsys Design Compiler, Cadence Innovus, SPICE | Pentium 4 adder, windowed register file, hardwired / FSM / microprogrammed control units, transistor-level cell characterization, place & route |

## Skills

**Languages:** C (embedded), VHDL, Verilog, Tcl, MATLAB  
**Tools:** Intel Quartus Prime, ModelSim, Synopsys Design Compiler & PrimeTime, Cadence Innovus, QuestaSim, Keil µVision, STM32CubeIDE, AWR Microwave Office  
**Lab instruments:** oscilloscope, vector network analyzer, waveform generator, power supply

## Notes

All projects and labs were carried out in student teams; teammates are credited in each README.
Files provided by the courses (templates, board libraries) are marked as such, and proprietary
technology libraries are not included.

## Contacts
LinkedIn: https://www.linkedin.com/in/lorenzo-pavone-46259a1b9/ · E-mail: lollopav02@gmail.com 
