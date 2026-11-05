--------------------------------------------------------------------------------
-- TB_MUX21
-- Testbench of the generic 2-to-1 multiplexer (a.b.c-mux21_v1.vhd).
-- SEL = '1' selects A, SEL = '0' selects B (convention used in the
-- datapath, e.g. MUXJUMP takes the jump target on A when the branch is taken).
-- The output follows the inputs after DELAY_MUX.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity TB_MUX21 is
end TB_MUX21;

architecture test of TB_MUX21 is

  component MUX21_GENERIC is
    generic (NBIT : integer := 16; DELAY_MUX : time := 3 ns);
    port (A   : in  std_logic_vector(NBIT-1 downto 0);
          B   : in  std_logic_vector(NBIT-1 downto 0);
          SEL : in  std_logic;
          Y   : out std_logic_vector(NBIT-1 downto 0));
  end component;

  signal A, B, Y : std_logic_vector(31 downto 0) := (others => '0');
  signal SEL     : std_logic := '0';

begin

  DUT: MUX21_GENERIC
    generic map (NBIT => 32)
    port map (A => A, B => B, SEL => SEL, Y => Y);

  stimuli: process
  begin
    A <= x"AAAAAAAA"; B <= x"55555555";
    SEL <= '1'; wait for 10 ns;   -- Y = AAAAAAAA
    SEL <= '0'; wait for 10 ns;   -- Y = 55555555
    B <= x"12345678";  wait for 10 ns;   -- Y = 12345678, follows B
    SEL <= '1'; wait for 10 ns;   -- Y = AAAAAAAA
    A <= x"0000BEEF";  wait for 10 ns;   -- Y = 0000BEEF, follows A
    wait;
  end process;

end test;