--------------------------------------------------------------------------------
-- TB_ALU
-- Testbench of the ALU (a.b.b-ALU_v1.vhd).
-- Every operation of aluOp (20, lhi included) is applied for 5 ns; the expected output is
-- written in the comment next to each step, to be checked on the waveform.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity TB_ALU is
end TB_ALU;

architecture test of TB_ALU is

  component ALU is
    generic (N : integer := numBit);
    port (
      FUNC   : in  aluOp;
      DATA1  : in  std_logic_vector(N-1 downto 0);
      DATA2  : in  std_logic_vector(N-1 downto 0);
      OUTALU : out std_logic_vector(N-1 downto 0));
  end component;

  signal FUNC   : aluOp := NOP;
  signal DATA1  : std_logic_vector(31 downto 0) := (others => '0');
  signal DATA2  : std_logic_vector(31 downto 0) := (others => '0');
  signal OUTALU : std_logic_vector(31 downto 0);

begin

  DUT: ALU
    generic map (N => 32)
    port map (FUNC => FUNC, DATA1 => DATA1, DATA2 => DATA2, OUTALU => OUTALU);

  stimuli: process
  begin
    -- arithmetic and logic, operands 12 and 5
    DATA1 <= x"0000000C"; DATA2 <= x"00000005";
    FUNC <= ADDS;  wait for 5 ns;   -- 00000011  (12 + 5)
    FUNC <= SUBS;  wait for 5 ns;   -- 00000007  (12 - 5)
    FUNC <= ANDS;  wait for 5 ns;   -- 00000004
    FUNC <= ORS;   wait for 5 ns;   -- 0000000D
    FUNC <= XORS;  wait for 5 ns;   -- 00000009
    FUNC <= LLS;   wait for 5 ns;   -- 00000180  (12 << 5)

    -- negative result
    DATA1 <= x"00000005"; DATA2 <= x"0000000C";
    FUNC <= SUBS;  wait for 5 ns;   -- FFFFFFF9  (5 - 12 = -7)

    -- right shifts of -3 by 1: logical vs arithmetic
    DATA1 <= x"FFFFFFFD"; DATA2 <= x"00000001";
    FUNC <= LRS;   wait for 5 ns;   -- 7FFFFFFE  (logical)
    FUNC <= ARS;   wait for 5 ns;   -- FFFFFFFE  (arithmetic, sign kept)

    -- comparisons between -3 and 5: signed vs unsigned
    DATA1 <= x"FFFFFFFD"; DATA2 <= x"00000005";
    FUNC <= SLTS;  wait for 5 ns;   -- 00000001  (-3 < 5, signed)
    FUNC <= SGTS;  wait for 5 ns;   -- 00000000
    FUNC <= SGES;  wait for 5 ns;   -- 00000000
    FUNC <= SNES;  wait for 5 ns;   -- 00000001
    FUNC <= SLTUS; wait for 5 ns;   -- 00000000  (0xFFFFFFFD is large, unsigned)
    FUNC <= SGTUS; wait for 5 ns;   -- 00000001
    FUNC <= SGEUS; wait for 5 ns;   -- 00000001

    -- equal operands
    DATA1 <= x"00000005"; DATA2 <= x"00000005";
    FUNC <= SEQS;  wait for 5 ns;   -- 00000001
    FUNC <= SLES;  wait for 5 ns;   -- 00000001
    FUNC <= SLEUS; wait for 5 ns;   -- 00000001

    -- lhi: the immediate (low half of DATA2) goes to the upper half
    DATA1 <= x"00000000"; DATA2 <= x"00001234";
    FUNC <= LHIS;  wait for 5 ns;   -- 12340000

    -- no operation
    FUNC <= NOP;   wait for 5 ns;   -- 00000000

    wait;
  end process;

end test;