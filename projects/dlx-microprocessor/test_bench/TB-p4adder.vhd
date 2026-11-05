--------------------------------------------------------------------------------
-- TB_P4_ADDER
-- Testbench of the P4 adder (a.b.b.a-p4_adder.vhd), used by the ALU for both
-- addition and subtraction (A - B = A + not(B) + 1, with Cin = '1').
-- Each step lasts 10 ns; the expected S and Cout are written in the comments,
-- to be checked on the waveform. The operands are chosen so that the carry
-- has to cross the boundaries of the 4-bit blocks of the carry generator.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity TB_P4_ADDER is
end TB_P4_ADDER;

architecture test of TB_P4_ADDER is

  component P4_ADDER is
    generic (NBIT : integer := 32);
    port (A    : in  std_logic_vector(NBIT-1 downto 0);
          B    : in  std_logic_vector(NBIT-1 downto 0);
          Cin  : in  std_logic;
          S    : out std_logic_vector(NBIT-1 downto 0);
          Cout : out std_logic);
  end component;

  signal A, B, S  : std_logic_vector(31 downto 0) := (others => '0');
  signal Cin      : std_logic := '0';
  signal Cout     : std_logic;

begin

  DUT: P4_ADDER
    generic map (NBIT => 32)
    port map (A => A, B => B, Cin => Cin, S => S, Cout => Cout);

  stimuli: process
  begin
    -- simple addition
    A <= x"0000000C"; B <= x"00000005"; Cin <= '0'; wait for 10 ns;
                                    -- S = 00000011, Cout = 0   (12 + 5)

    -- subtraction as done by the ALU: B inverted, Cin = 1
    A <= x"0000000C"; B <= x"FFFFFFFA"; Cin <= '1'; wait for 10 ns;
                                    -- S = 00000007, Cout = 1   (12 - 5)
    A <= x"00000005"; B <= x"FFFFFFF3"; Cin <= '1'; wait for 10 ns;
                                    -- S = FFFFFFF9, Cout = 0   (5 - 12 = -7)

    -- carry input alone
    A <= x"00000000"; B <= x"00000000"; Cin <= '1'; wait for 10 ns;
                                    -- S = 00000001, Cout = 0

    -- carry crossing one block boundary and several blocks
    A <= x"0000000F"; B <= x"00000001"; Cin <= '0'; wait for 10 ns;
                                    -- S = 00000010, Cout = 0
    A <= x"0000FFFF"; B <= x"00000001"; Cin <= '0'; wait for 10 ns;
                                    -- S = 00010000, Cout = 0

    -- carry through all the 32 bits
    A <= x"FFFFFFFF"; B <= x"00000001"; Cin <= '0'; wait for 10 ns;
                                    -- S = 00000000, Cout = 1
    A <= x"7FFFFFFF"; B <= x"00000001"; Cin <= '0'; wait for 10 ns;
                                    -- S = 80000000, Cout = 0   (signed overflow)

    -- generic operands, no carry between blocks
    A <= x"12345678"; B <= x"87654321"; Cin <= '0'; wait for 10 ns;
                                    -- S = 99999999, Cout = 0

    -- generic operands with carries in every block
    A <= x"89ABCDEF"; B <= x"76543211"; Cin <= '0'; wait for 10 ns;
                                    -- S = 00000000, Cout = 1
    wait;
  end process;

end test;