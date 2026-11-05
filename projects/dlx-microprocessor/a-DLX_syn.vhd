library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.myTypes.all;

-- DLX top level for synthesis: same as DLX but without IRAM and DRAM,
-- which are left outside as ports.

entity DLX_SYN is
  generic (
    IR_SIZE : integer := 32;
    PC_SIZE : integer := 32);
  port (
    Clk       : in  std_logic;
    Rst       : in  std_logic;                                  -- active low
    IRAM_ADDR : out std_logic_vector(PC_SIZE - 1 downto 0);     -- to instruction memory
    IRAM_IN   : in  std_logic_vector(IR_SIZE - 1 downto 0);     -- from instruction memory
    DRAM_ADDR : out std_logic_vector(31 downto 0);              -- to data memory
    DRAM_DIN  : out std_logic_vector(31 downto 0);              -- data written to memory
    DRAM_IN   : in  std_logic_vector(31 downto 0);              -- data read from memory
    DRAM_WE   : out std_logic);
end DLX_SYN;


architecture dlx_rtl of DLX_SYN is

  -- Datapath
  component DataPath is
    generic (N : integer := numBit);
    port (
      Clk             : IN  std_logic;
      Rst             : IN  std_logic;
      DIN             : IN  std_logic_vector(N-1 downto 0);
      IR              : IN  std_logic_vector(N-1 downto 0);
      NPC_IN          : IN  std_logic_vector(N-1 downto 0);
      RegA_LATCH_EN   : IN  std_logic;
      RegB_LATCH_EN   : IN  std_logic;
      RegIMM_LATCH_EN : IN  std_logic;
      MUXA_SEL        : IN  std_logic;
      MUXB_SEL        : IN  std_logic;
      ALU_OUTREG_EN   : IN  std_logic;
      EQ_COND         : IN  std_logic;
      ALU_OPCODE      : IN  aluOp;
      RF_WE_EX        : IN  std_logic;
      LMD_LATCH_EN    : IN  std_logic;
      JUMP_EN         : IN  std_logic;
      RF_WE_MEM       : IN  std_logic;
      WB_MUX_SEL      : IN  std_logic;
      RF_WE           : IN  std_logic;
      DADDR           : OUT std_logic_vector(N-1 downto 0);
      DOUT            : OUT std_logic_vector(N-1 downto 0);
      PC_OUT          : OUT std_logic_vector(N-1 downto 0);
      FLUSH           : OUT std_logic;
      STALL           : OUT std_logic);
  end component;

  -- Control Unit
  component dlx_cu
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

  -- fetch registers
  signal IR : std_logic_vector(IR_SIZE - 1 downto 0);
  signal PC : std_logic_vector(PC_SIZE - 1 downto 0);
  signal NPC : std_logic_vector(PC_SIZE - 1 downto 0);
  signal PC_BUS : std_logic_vector(PC_SIZE - 1 downto 0);

  -- control signals
  signal IR_LATCH_EN_i, NPC_LATCH_EN_i, PC_LATCH_EN_i : std_logic;
  signal RegA_LATCH_EN_i, RegB_LATCH_EN_i, RegIMM_LATCH_EN_i : std_logic;
  signal MUXA_SEL_i, MUXB_SEL_i, ALU_OUTREG_EN_i, EQ_COND_i : std_logic;
  signal ALU_OPCODE_i : aluOp;
  signal DRAM_WE_i, LMD_LATCH_EN_i, JUMP_EN_i : std_logic;
  signal WB_MUX_SEL_i, RF_WE_i, RF_WE_EX_i, RF_WE_MEM_i : std_logic;
  signal FLUSH_i, STALL_i : std_logic;

  -- memory buses
  signal IRam_DOut : std_logic_vector(IR_SIZE - 1 downto 0);
  signal DRAM_Dout : std_logic_vector(31 downto 0);
  signal DP_DADDR  : std_logic_vector(31 downto 0);
  signal DP_DOUT   : std_logic_vector(31 downto 0);

begin

  NPC <= PC + 4;

  -- memory interface: the memories are outside the synthesized block
  IRAM_ADDR <= PC;
  IRam_DOut <= IRAM_IN;
  DRAM_ADDR <= DP_DADDR;
  DRAM_DIN  <= DP_DOUT;
  DRAM_Dout <= DRAM_IN;
  DRAM_WE   <= DRAM_WE_i;

  IR_P: process (Clk, Rst)
  begin
    if Rst = '0' then
      IR <= (others => '0');
    elsif Clk'event and Clk = '1' then
      if IR_LATCH_EN_i = '1' then
        IR <= IRam_DOut;
      end if;
    end if;
  end process IR_P;

  PC_P: process (Clk, Rst)
  begin
    if Rst = '0' then
      PC <= (others => '0');
    elsif Clk'event and Clk = '1' then
      if PC_LATCH_EN_i = '1' then
        PC <= PC_BUS;
      end if;
    end if;
  end process PC_P;

  CU_I: dlx_cu
    port map (
      Clk             => Clk,
      Rst             => Rst,
      STALL           => STALL_i,
      IR_IN           => IR,
      IR_LATCH_EN     => IR_LATCH_EN_i,
      NPC_LATCH_EN    => NPC_LATCH_EN_i,
      RegA_LATCH_EN   => RegA_LATCH_EN_i,
      RegB_LATCH_EN   => RegB_LATCH_EN_i,
      RegIMM_LATCH_EN => RegIMM_LATCH_EN_i,
      MUXA_SEL        => MUXA_SEL_i,
      MUXB_SEL        => MUXB_SEL_i,
      ALU_OUTREG_EN   => ALU_OUTREG_EN_i,
      EQ_COND         => EQ_COND_i,
      RF_WE_EX        => RF_WE_EX_i,
      ALU_OPCODE      => ALU_OPCODE_i,
      FLUSH           => FLUSH_i,
      DRAM_WE         => DRAM_WE_i,
      LMD_LATCH_EN    => LMD_LATCH_EN_i,
      JUMP_EN         => JUMP_EN_i,
      PC_LATCH_EN     => PC_LATCH_EN_i,
      RF_WE_MEM       => RF_WE_MEM_i,
      WB_MUX_SEL      => WB_MUX_SEL_i,
      RF_WE_WB        => RF_WE_i);

  DP_I: DataPath
    port map (
      Clk             => Clk,
      Rst             => Rst,
      DIN             => DRAM_Dout,
      IR              => IR,
      NPC_IN          => NPC,
      RegA_LATCH_EN   => RegA_LATCH_EN_i,
      RegB_LATCH_EN   => RegB_LATCH_EN_i,
      RegIMM_LATCH_EN => RegIMM_LATCH_EN_i,
      MUXA_SEL        => MUXA_SEL_i,
      MUXB_SEL        => MUXB_SEL_i,
      ALU_OUTREG_EN   => ALU_OUTREG_EN_i,
      EQ_COND         => EQ_COND_i,
      ALU_OPCODE      => ALU_OPCODE_i,
      RF_WE_EX        => RF_WE_EX_i,
      LMD_LATCH_EN    => LMD_LATCH_EN_i,
      JUMP_EN         => JUMP_EN_i,
      RF_WE_MEM       => RF_WE_MEM_i,
      WB_MUX_SEL      => WB_MUX_SEL_i,
      RF_WE           => RF_WE_i,
      DADDR           => DP_DADDR,
      DOUT            => DP_DOUT,
      PC_OUT          => PC_BUS,
      FLUSH           => FLUSH_i,
      STALL           => STALL_i);

end dlx_rtl;