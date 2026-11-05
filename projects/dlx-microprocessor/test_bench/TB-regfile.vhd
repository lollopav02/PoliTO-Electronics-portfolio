--------------------------------------------------------------------------------
-- TB_register_file
-- Testbench of the register file (a.b.a-register_file_v1.vhd).
-- The expected values are written in the comments, to be checked on the
-- waveform. Clock period 2 ns, reset active low.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity TB_register_file is
end TB_register_file;

architecture test of TB_register_file is

  component register_file is
    generic (
      BIT_WIDTH  : natural := 32;
      ADDR_WIDTH : natural := 5;
      REG_NUMBER : natural := 32);
    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      ENABLE  : in  std_logic;
      WR      : in  std_logic;
      ADD_WR  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      ADD_RD1 : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      ADD_RD2 : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      DATAIN  : in  std_logic_vector(BIT_WIDTH - 1 downto 0);
      OUT1    : out std_logic_vector(BIT_WIDTH - 1 downto 0);
      OUT2    : out std_logic_vector(BIT_WIDTH - 1 downto 0));
  end component;

  signal CLK     : std_logic := '0';
  signal RESET   : std_logic := '0';
  signal ENABLE  : std_logic := '1';
  signal WR      : std_logic := '0';
  signal ADD_WR  : std_logic_vector(4 downto 0)  := "00000";
  signal ADD_RD1 : std_logic_vector(4 downto 0)  := "00000";
  signal ADD_RD2 : std_logic_vector(4 downto 0)  := "00000";
  signal DATAIN  : std_logic_vector(31 downto 0) := (others => '0');
  signal OUT1    : std_logic_vector(31 downto 0);
  signal OUT2    : std_logic_vector(31 downto 0);

begin

  DUT: register_file
    generic map (BIT_WIDTH => 32, ADDR_WIDTH => 5, REG_NUMBER => 32)
    port map (CLK => CLK, RESET => RESET, ENABLE => ENABLE, WR => WR,
              ADD_WR => ADD_WR, ADD_RD1 => ADD_RD1, ADD_RD2 => ADD_RD2,
              DATAIN => DATAIN, OUT1 => OUT1, OUT2 => OUT2);

  CLK <= not CLK after 1 ns;            -- 2 ns period

  stimuli: process
  begin
    -- reset: all registers cleared
    RESET <= '0';
    wait for 5 ns;
    RESET <= '1';

    -- write r5 and r31 (each write happens on the next rising edge)
    WR <= '1'; ADD_WR <= "00101"; DATAIN <= x"12345678"; wait for 2 ns;
    WR <= '1'; ADD_WR <= "11111"; DATAIN <= x"CAFE0031"; wait for 2 ns;
    WR <= '0';

    -- read them back on the two ports
    ADD_RD1 <= "00101"; ADD_RD2 <= "11111"; wait for 4 ns;
    -- OUT1 = 12345678, OUT2 = CAFE0031

    -- write r0: it must still read zero
    WR <= '1'; ADD_WR <= "00000"; DATAIN <= x"FFFFFFFF"; wait for 2 ns;
    WR <= '0';
    ADD_RD1 <= "00000"; wait for 4 ns;
    -- OUT1 = 00000000

    -- bypass: read r7 in the same cycle in which it is written
    ADD_RD1 <= "00111";
    WR <= '1'; ADD_WR <= "00111"; DATAIN <= x"0000BEEF"; wait for 2 ns;
    -- OUT1 = 0000BEEF already before the rising edge
    WR <= '0'; wait for 4 ns;
    -- OUT1 = 0000BEEF, now read from the register

    -- WR = 0: no write and no bypass
    ADD_WR <= "00111"; DATAIN <= x"DEADDEAD"; wait for 4 ns;
    -- OUT1 stays 0000BEEF

    wait;
  end process;

end test;