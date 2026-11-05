library ieee;
use ieee.std_logic_1164.all;

entity PG_BLOCK is
    port (
        Pik : in  std_logic;
        Gik : in  std_logic;
        Pkj : in  std_logic;
        Gkj : in  std_logic;
        Pij : out std_logic;
        Gij : out std_logic
    );
end PG_BLOCK;

architecture BEHAVIORAL of PG_BLOCK is
begin
    -- Formule: 
    -- G_i:j = G_i:k + (P_i:k * G_k-1:j)
    -- P_i:j = P_i:k * P_k-1:j
    Gij <= Gik or (Pik and Gkj);
    Pij <= Pik and Pkj;
end BEHAVIORAL;