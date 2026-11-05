--------------------------------------------------------------------------------
-- TB_REG
-- Testbench of the generic register with enable (a.b.d-register_v1.vhd).
-- Reset asynchronous, active low; load on the rising edge only when EN = '1'.
-- The enable is what keeps an instruction in its stage during a stall.
-- Clock period 2 ns.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity TB_REG is
end TB_REG;

architecture test of TB_REG is

  component REG is
    generic (numBit : integer);
    port (D     : in  std_logic_vector(numBit-1 downto 0);
          EN    : in  std_logic;
          CK    : in  std_logic;
          RESET : in  std_logic;
          Q     : out std_logic_vector(numBit-1 downto 0));
  end component;

  signal D, Q  : std_logic_vector(31 downto 0) := (others => '0');
  signal EN    : std_logic := '0';
  signal CK    : std_logic := '0';
  signal RESET : std_logic := '0';

begin

  DUT: REG
    generic map (numBit => 32)
    port map (D => D, EN => EN, CK => CK, RESET => RESET, Q => Q);

  CK <= not CK after 1 ns;            -- 2 ns period

  stimuli: process
  begin
    RESET <= '0'; D <= x"12345678"; EN <= '1';
    wait for 5 ns;                    -- Q = 00000000 while reset is active
    RESET <= '1';
    wait for 4 ns;                    -- Q = 12345678 from the next rising edge

    D <= x"CAFE0001";
    wait for 4 ns;                    -- Q = CAFE0001

    EN <= '0'; D <= x"DEADDEAD";
    wait for 6 ns;                    -- Q stays CAFE0001: register frozen (stall)

    EN <= '1';
    wait for 4 ns;                    -- Q = DEADDEAD

    RESET <= '0';
    wait for 1.5 ns;                  -- Q = 00000000 at once, without waiting for the clock
    RESET <= '1';
    wait;
  end process;

end test;