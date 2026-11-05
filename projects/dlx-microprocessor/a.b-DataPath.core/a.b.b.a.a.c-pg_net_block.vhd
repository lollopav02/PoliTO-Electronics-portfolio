library ieee;
use ieee.std_logic_1164.all;

entity PG_NET_BLOCK is
    port (
        A : in  std_logic;
        B : in  std_logic;
        p : out std_logic;
        g : out std_logic
    );
end PG_NET_BLOCK;

architecture BEHAVIORAL of PG_NET_BLOCK is
begin
    			-- Basic Logic:
    p <= A xor B;	-- p_i = a_i xor b_i
    g <= A and B;	-- g_i = a_i and b_i
end BEHAVIORAL;