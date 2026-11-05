--------------------------------------------------------------------------------
-- MUX21_4BIT: 2-to-1 multiplexer, N bits wide (4 by default).
-- Used in each carry-select block of the P4 adder to choose between the two
-- precomputed sums, once the carry generator provides the real carry-in.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

ENTITY MUX21_4BIT IS 
	generic (N : positive := 4);   -- width of the inputs and of the output
	port (
		A:	in	std_logic_vector(N - 1 downto 0);   -- selected when S = '1' (sum with carry-in 1)
		B:	in	std_logic_vector(N - 1 downto 0);   -- selected when S = '0' (sum with carry-in 0)
		S:	in	std_logic;                          -- select: the carry-in of the block
		Y:	out	std_logic_vector(N - 1 downto 0));  -- selected sum
end MUX21_4BIT;


architecture BEHAVIORAL of MUX21_4BIT is
begin
	Y <= A when S='1' else B;   -- select A when S is high, B otherwise
end BEHAVIORAL;
