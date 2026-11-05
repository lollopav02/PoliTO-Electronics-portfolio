--------------------------------------------------------------------------------
-- TB_IRAM
-- Testbench of the instruction memory (a.c-IRAM.vhd).
-- While Rst = '0' (active low) the memory loads the program from the file
-- test.asm.mem, in the simulation directory. The read is combinational and
-- the address is a byte address: Addr(31 downto 2) selects the word.
--
-- The expected values in the comments refer to test_all.asm, the last program
-- assembled by build.sh (check with:  head -3 test.asm.mem):
--   word 0: addi r1, r0, #12  -> 2001000C
--   word 1: addi r2, r0, #5   -> 20020005
--   word 2: add  r3, r1, r2   -> 00221820
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity TB_IRAM is
end TB_IRAM;

architecture test of TB_IRAM is

  component IRAM is
    generic (RAM_DEPTH : integer := 48;
             I_SIZE    : integer := 32);
    port (Rst  : in  std_logic;
          Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
          Dout : out std_logic_vector(I_SIZE - 1 downto 0));
  end component;

  signal Rst  : std_logic := '0';
  signal Addr : std_logic_vector(31 downto 0) := (others => '0');
  signal Dout : std_logic_vector(31 downto 0);

begin

  DUT: IRAM
    port map (Rst => Rst, Addr => Addr, Dout => Dout);

  stimuli: process
  begin
    Rst <= '0'; wait for 5 ns;          -- program loaded from test.asm.mem
    Rst <= '1';

    Addr <= x"00000000"; wait for 5 ns; -- Dout = 2001000C  (word 0)
    Addr <= x"00000004"; wait for 5 ns; -- Dout = 20020005  (word 1)
    Addr <= x"00000008"; wait for 5 ns; -- Dout = 00221820  (word 2)

    -- the two least significant bits are discarded
    Addr <= x"00000005"; wait for 5 ns; -- Dout = 20020005, same word as address 4
    Addr <= x"00000007"; wait for 5 ns; -- Dout = 20020005

    -- addresses beyond the 48 words wrap around (modulo RAM_DEPTH)
    Addr <= x"000000C0"; wait for 5 ns; -- 192 = word 48 -> word 0: Dout = 2001000C

    -- a second reset reloads the program from the beginning
    Rst <= '0'; wait for 5 ns;
    Rst <= '1';
    Addr <= x"00000000"; wait for 5 ns; -- Dout = 2001000C again
    wait;
  end process;

end test;
