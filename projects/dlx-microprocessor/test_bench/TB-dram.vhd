--------------------------------------------------------------------------------
-- TB_DRAM
-- Testbench of the data memory (a.d-DRAM.vhd).
-- Byte addresses, word organized: the two least significant bits of addr
-- are discarded (address 4 is the second word).
-- Writing is synchronous (rising edge, DRAM_WE = '1'), reading combinational.
-- Clock period 2 ns, reset active low.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity TB_DRAM is
end TB_DRAM;

architecture test of TB_DRAM is

  component DRAM is
    generic (RAM_DEPTH : integer := numBit*2;
             D_SIZE    : integer := numBit);
    port (Clk     : in  std_logic;
          Rst     : in  std_logic;
          DRAM_WE : in  std_logic;
          Din     : in  std_logic_vector(D_SIZE - 1 downto 0);
          addr    : in  std_logic_vector(D_SIZE - 1 downto 0);
          Dout    : out std_logic_vector(D_SIZE - 1 downto 0));
  end component;

  signal Clk     : std_logic := '0';
  signal Rst     : std_logic := '0';
  signal DRAM_WE : std_logic := '0';
  signal Din     : std_logic_vector(31 downto 0) := (others => '0');
  signal addr    : std_logic_vector(31 downto 0) := (others => '0');
  signal Dout    : std_logic_vector(31 downto 0);

begin

  DUT: DRAM
    port map (Clk => Clk, Rst => Rst, DRAM_WE => DRAM_WE,
              Din => Din, addr => addr, Dout => Dout);

  Clk <= not Clk after 1 ns;          -- 2 ns period

  stimuli: process
  begin
    Rst <= '0'; wait for 5 ns;
    Rst <= '1';

    -- three stores, as in test_all: 17, -3, 29 at addresses 0, 4, 8
    DRAM_WE <= '1';
    addr <= x"00000000"; Din <= x"00000011"; wait for 2 ns;
    addr <= x"00000004"; Din <= x"FFFFFFFD"; wait for 2 ns;
    addr <= x"00000008"; Din <= x"0000001D"; wait for 2 ns;
    DRAM_WE <= '0';

    -- loads
    addr <= x"00000000"; wait for 2 ns;   -- Dout = 00000011
    addr <= x"00000004"; wait for 2 ns;   -- Dout = FFFFFFFD, negative value kept
    addr <= x"00000008"; wait for 2 ns;   -- Dout = 0000001D
    addr <= x"00000006"; wait for 2 ns;   -- Dout = FFFFFFFD: same word as address 4

    -- DRAM_WE = '0': nothing is written
    addr <= x"00000000"; Din <= x"DEADDEAD"; wait for 4 ns;
                                          -- Dout stays 00000011
    wait;
  end process;

end test;