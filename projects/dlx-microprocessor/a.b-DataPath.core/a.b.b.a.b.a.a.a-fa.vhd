--------------------------------------------------------------------------------
-- FA: 1-bit full adder.
-- Basic cell of the ripple-carry adders (RCA) used in the carry-select blocks
-- of the P4 adder. It adds the two input bits and the carry-in.
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 

entity FA is 
	
	Port (
		A:	In	std_logic;   -- first operand bit
		B:	In	std_logic;   -- second operand bit
		Ci:	In	std_logic;   -- carry-in
		S:	Out	std_logic;   -- sum bit
		Co:	Out	std_logic);  -- carry-out
end FA; 

architecture BEHAVIORAL of FA is
	begin
	S <= A xor B xor Ci ;                          -- sum: odd number of ones
	Co <= (A and B) or (B and Ci) or (A and Ci) ;  -- carry: at least two ones
end BEHAVIORAL;

-- configuration used by the RCA (CFG_RCA_STRUCTURAL) to bind its full adders
configuration CFG_FA_BEHAVIORAL of FA is	
	for BEHAVIORAL
	end for;
end CFG_FA_BEHAVIORAL;
