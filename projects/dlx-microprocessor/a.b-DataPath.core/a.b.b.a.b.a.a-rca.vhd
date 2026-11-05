library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity RCA is 
	generic (
		 NBIT  :	positive
		);
	Port (	A:	In	std_logic_vector(NBIT - 1 downto 0);
		B:	In	std_logic_vector(NBIT - 1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(NBIT - 1 downto 0);
		Co:	Out	std_logic);
end RCA; 

architecture STRUCTURAL of RCA is

  signal STMP : std_logic_vector(NBIT - 1 downto 0);
  signal CTMP : std_logic_vector(NBIT downto 0);

  component FA 
  
  Port ( A:	In	std_logic;
	 B:	In	std_logic;
	 Ci:	In	std_logic;
	 S:	Out	std_logic;
	 Co:	Out	std_logic);
  end component; 

begin

  CTMP(0) <= Ci;
  S <= STMP;
  Co <= CTMP(NBIT);
  
  ADDER1: for I in 1 to NBIT generate 					-- FA instance (considering delays) for each stage of the RCA
    FAI : FA 
	  
	  Port Map (A(I-1), B(I-1), CTMP(I-1), STMP(I-1), CTMP(I)); 
  end generate;

end STRUCTURAL;


architecture BEHAVIORAL of RCA is
	signal c_tmp: std_logic_vector(NBIT downto 0);
	begin
	c_tmp(0)<=Ci; 							-- the first carry (carry-in) is initialized at the value 0 
									-- because the first stage of the RCA is a half-adder

	ADDER_BITS: for i in 0 to NBIT - 1  generate
			S(i) <= A(i) xor B(i) xor c_tmp(i);
			c_tmp(i+1) <= (A(i) and B(i)) or (B(i) and c_tmp(i)) or (A(i) and c_tmp(i)) ;
		    end generate;

		Co<=c_tmp(NBIT);					-- the last carryout exceeds by 1 the original nbit index range (temporary signal for the carry)

end BEHAVIORAL;

configuration CFG_RCA_STRUCTURAL of RCA is				-- definition of str/beh configurations for the RCA
  for STRUCTURAL 
    for ADDER1
      for all : FA
        use configuration WORK.CFG_FA_BEHAVIORAL;
      end for;
    end for;
  end for;
end CFG_RCA_STRUCTURAL;

configuration CFG_RCA_BEHAVIORAL of RCA is
  for BEHAVIORAL 
  end for;
end CFG_RCA_BEHAVIORAL;
