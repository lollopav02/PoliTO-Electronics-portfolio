--------------------------------------------------------------------------------
-- TB_CU
-- Testbench of the hardwired control unit (a.a-CU_HW.vhd).
--
-- One instruction per clock cycle is applied to IR_IN, as the instruction
-- register would do. An instruction applied in cycle n drives:
--   ID  signals in cycle n   (RegA/RegB/RegIMM_LATCH_EN, from cw)
--   EX  signals in cycle n+1 (MUXA/MUXB_SEL, ALU_OUTREG_EN, EQ_COND,
--                             JUMP_EN, RF_WE_EX, ALU_OPCODE, from cw1)
--   MEM signals in cycle n+2 (DRAM_WE, LMD_LATCH_EN, RF_WE_MEM, from cw2)
--   WB  signals in cycle n+3 (WB_MUX_SEL, RF_WE_WB, from cw3)
-- Then a FLUSH and a STALL are applied, to show the bubbles.
-- Clock period 2 ns, reset active low.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity TB_CU is
end TB_CU;

architecture test of TB_CU is

  component dlx_cu is
    generic (
      MICROCODE_MEM_SIZE : integer := 64;
      FUNC_SIZE          : integer := 11;
      OP_CODE_SIZE       : integer := 6;
      IR_SIZE            : integer := 32;
      CW_SIZE            : integer := 15);
    port (
      Clk             : in  std_logic;
      Rst             : in  std_logic;
      STALL           : in  std_logic;
      IR_IN           : in  std_logic_vector(IR_SIZE - 1 downto 0);
      IR_LATCH_EN     : out std_logic;
      NPC_LATCH_EN    : out std_logic;
      RegA_LATCH_EN   : out std_logic;
      RegB_LATCH_EN   : out std_logic;
      RegIMM_LATCH_EN : out std_logic;
      MUXA_SEL        : out std_logic;
      MUXB_SEL        : out std_logic;
      ALU_OUTREG_EN   : out std_logic;
      EQ_COND         : out std_logic;
      RF_WE_EX        : out std_logic;
      ALU_OPCODE      : out aluOp;
      FLUSH           : in  std_logic;
      DRAM_WE         : out std_logic;
      LMD_LATCH_EN    : out std_logic;
      JUMP_EN         : out std_logic;
      PC_LATCH_EN     : out std_logic;
      RF_WE_MEM       : out std_logic;
      WB_MUX_SEL      : out std_logic;
      RF_WE_WB        : out std_logic);
  end component;

  signal Clk, Rst, STALL, FLUSH : std_logic := '0';
  signal IR_IN : std_logic_vector(31 downto 0) := (others => '0');
  signal IR_LATCH_EN, NPC_LATCH_EN, PC_LATCH_EN : std_logic;
  signal RegA_LATCH_EN, RegB_LATCH_EN, RegIMM_LATCH_EN : std_logic;
  signal MUXA_SEL, MUXB_SEL, ALU_OUTREG_EN, EQ_COND, JUMP_EN, RF_WE_EX : std_logic;
  signal ALU_OPCODE : aluOp;
  signal DRAM_WE, LMD_LATCH_EN, RF_WE_MEM : std_logic;
  signal WB_MUX_SEL, RF_WE_WB : std_logic;

  -- instruction words (hexadecimal encoding of the DLX formats)
  constant I_ADDI : std_logic_vector(31 downto 0) := x"2001000C";  -- addi r1, r0, #12
  constant I_ADD  : std_logic_vector(31 downto 0) := x"00221820";  -- add  r3, r1, r2
  constant I_SUB  : std_logic_vector(31 downto 0) := x"00221822";  -- sub  r3, r1, r2
  constant I_SLT  : std_logic_vector(31 downto 0) := x"0022182A";  -- slt  r3, r1, r2
  constant I_LW   : std_logic_vector(31 downto 0) := x"8C040000";  -- lw   r4, 0(r0)
  constant I_SW   : std_logic_vector(31 downto 0) := x"AC010000";  -- sw   0(r0), r1
  constant I_BEQZ : std_logic_vector(31 downto 0) := x"10200008";  -- beqz r1, +8
  constant I_J    : std_logic_vector(31 downto 0) := x"08000010";  -- j    +16
  constant I_JAL  : std_logic_vector(31 downto 0) := x"0C000010";  -- jal  +16
  constant I_JR   : std_logic_vector(31 downto 0) := x"4BE00000";  -- jr   r31
  constant I_JALR : std_logic_vector(31 downto 0) := x"4D400000";  -- jalr r10
  constant I_LHI  : std_logic_vector(31 downto 0) := x"3C011234";  -- lhi  r1, #0x1234
  constant I_NOP  : std_logic_vector(31 downto 0) := x"54000000";  -- nop

begin

  DUT: dlx_cu
    port map (
      Clk => Clk, Rst => Rst, STALL => STALL, IR_IN => IR_IN,
      IR_LATCH_EN => IR_LATCH_EN, NPC_LATCH_EN => NPC_LATCH_EN,
      RegA_LATCH_EN => RegA_LATCH_EN, RegB_LATCH_EN => RegB_LATCH_EN,
      RegIMM_LATCH_EN => RegIMM_LATCH_EN, MUXA_SEL => MUXA_SEL,
      MUXB_SEL => MUXB_SEL, ALU_OUTREG_EN => ALU_OUTREG_EN, EQ_COND => EQ_COND,
      RF_WE_EX => RF_WE_EX, ALU_OPCODE => ALU_OPCODE, FLUSH => FLUSH,
      DRAM_WE => DRAM_WE, LMD_LATCH_EN => LMD_LATCH_EN, JUMP_EN => JUMP_EN,
      PC_LATCH_EN => PC_LATCH_EN, RF_WE_MEM => RF_WE_MEM,
      WB_MUX_SEL => WB_MUX_SEL, RF_WE_WB => RF_WE_WB);

  Clk <= not Clk after 1 ns;          -- 2 ns period

  stimuli: process
  begin
    Rst <= '0'; IR_IN <= I_NOP;
    wait for 5 ns;                    -- every control output at 0 during reset
    Rst <= '1';

    -- one instruction per cycle; what to observe:
    IR_IN <= I_ADDI; wait for 2 ns;   -- RegIMM enable; next cycle ALU_OPCODE = ADDS; WB: RF_WE_WB = 1
    IR_IN <= I_ADD;  wait for 2 ns;   -- RegA and RegB enables; EX: ADDS; WB: RF_WE_WB = 1
    IR_IN <= I_SUB;  wait for 2 ns;   -- EX: ALU_OPCODE = SUBS (decoded from func)
    IR_IN <= I_SLT;  wait for 2 ns;   -- EX: ALU_OPCODE = SLTS
    IR_IN <= I_LW;   wait for 2 ns;   -- MEM: LMD_LATCH_EN = 1; WB: WB_MUX_SEL = 1, RF_WE_WB = 1
    IR_IN <= I_SW;   wait for 2 ns;   -- MEM: DRAM_WE = 1; WB: RF_WE_WB = 0
    IR_IN <= I_BEQZ; wait for 2 ns;   -- EX: JUMP_EN = 1, EQ_COND = 1; no register written
    IR_IN <= I_J;    wait for 2 ns;   -- EX: JUMP_EN = 1, EQ_COND = 0
    IR_IN <= I_JAL;  wait for 2 ns;   -- EX: JUMP_EN = 1; WB: RF_WE_WB = 1 (return address in r31)
    IR_IN <= I_JR;   wait for 2 ns;   -- RegA enable; EX: JUMP_EN = 1, MUXA_SEL = 0 (register), ADDS
    IR_IN <= I_JALR; wait for 2 ns;   -- as jr; WB: RF_WE_WB = 1 (return address in r31)
    IR_IN <= I_LHI;  wait for 2 ns;   -- RegIMM enable; EX: ALU_OPCODE = LHIS; WB: RF_WE_WB = 1
    IR_IN <= I_NOP;  wait for 8 ns;   -- all control words drain to zero

    -- FLUSH: a branch is taken in EX; the next two control words become bubbles
    IR_IN <= I_ADD;  wait for 2 ns;   -- add enters ID normally
    FLUSH <= '1';
    IR_IN <= I_ADDI; wait for 2 ns;   -- FLUSH: cw1 = 0 in the next cycle instead of addi
    FLUSH <= '0';
    IR_IN <= I_SUB;  wait for 2 ns;   -- flush_d: cw1 = 0 again instead of sub
    IR_IN <= I_NOP;  wait for 8 ns;   -- only the add reaches WB with RF_WE_WB = 1

    -- STALL: load-use hazard detected in ID
    IR_IN <= I_ADD;  STALL <= '1';
    wait for 2 ns;                    -- IR_LATCH_EN = NPC_LATCH_EN = PC_LATCH_EN = 0;
                                      -- next cycle cw1 = 0 (bubble in EX)
    STALL <= '0';     wait for 2 ns;  -- enables back to 1; the add proceeds
    IR_IN <= I_NOP;  wait for 8 ns;

    wait;
  end process;

end test;