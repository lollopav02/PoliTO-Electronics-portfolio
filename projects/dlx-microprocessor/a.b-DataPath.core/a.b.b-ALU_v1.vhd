library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

use WORK.myTypes.all;

entity ALU is
  generic (N : integer := numBit);
  port ( 
    FUNC   : IN  aluOp;
    DATA1  : IN  std_logic_vector(N-1 downto 0);
    DATA2  : IN  std_logic_vector(N-1 downto 0);
    OUTALU : OUT std_logic_vector(N-1 downto 0)
  );
end ALU;

architecture BEHAVIOR of ALU is

  -- P4 adder of lab 6, used for both addition and subtraction:
  -- A - B = A + not(B) + 1
  component P4_ADDER is
    generic (NBIT : integer := 32);
    port (A    : in  std_logic_vector(NBIT-1 downto 0);
          B    : in  std_logic_vector(NBIT-1 downto 0);
          Cin  : in  std_logic;
          S    : out std_logic_vector(NBIT-1 downto 0);
          Cout : out std_logic);
  end component;

  signal b_p4, sum_p4    : std_logic_vector(N-1 downto 0);
  signal cin_p4, cout_p4 : std_logic;
begin

  cin_p4 <= '1' when FUNC = SUBS else '0';          -- +1 for the subtraction
  b_p4   <= not DATA2 when FUNC = SUBS else DATA2;    -- A - B = A + not(B) + 1

  ADDER: P4_ADDER
    generic map (NBIT => N)
    port map (A => DATA1, B => b_p4, Cin => cin_p4, S => sum_p4, Cout => cout_p4);

-- the ALU functions are defined externally inside alu_types file

  PROCESS_ALU: process (FUNC, DATA1, DATA2, sum_p4) -- the sensitivity list includes func (operation type) and the 2 operands
    variable tmp_mult : std_logic_vector((2*N)-1 downto 0); -- moltiplication result (2N bit)
  begin
    case FUNC is

	when NOP => 
            OUTALU <= (others => '0');
      
        when ADDS => 
            OUTALU <= sum_p4;          -- P4 adder 

        when SUBS => 
            OUTALU <= sum_p4;          -- P4 adder with not(DATA2) and Cin = 1

        when ANDS => 
            OUTALU <= DATA1 and DATA2; 

        when ORS => 
            OUTALU <= DATA1 or DATA2;

        when XORS => 
            OUTALU <= DATA1 xor DATA2;
	
	when LLS => 
            OUTALU <= to_StdLogicVector((to_bitvector(DATA1)) sll (conv_integer(DATA2( 4 downto 0))));

	when LRS => 
            OUTALU <= to_StdLogicVector((to_bitvector(DATA1)) srl (conv_integer(DATA2( 4 downto 0))));

	when ARS =>
            OUTALU <= to_StdLogicVector((to_bitvector(DATA1)) sra (conv_integer(DATA2(4 downto 0))));

	when SGES => 
		
		if(signed(DATA1)>=signed(DATA2)) then
		
			OUTALU <= (others => '0'); OUTALU(0) <= '1';	
					
		else
			OUTALU<=(others=>'0');
		end if;

	when SLES =>
		if(signed(DATA1)<=signed(DATA2)) then
		
			OUTALU <= (others => '0'); OUTALU(0) <= '1';	
					
		else
			OUTALU<=(others=>'0');
		end if;

	when SNES =>
		if (signed(DATA1) /= signed(DATA2)) then
			OUTALU <= (others => '0'); OUTALU(0) <= '1';
		else
			OUTALU <= (others => '0');
		end if;

	when SEQS =>
            	if (DATA1 = DATA2) then
                	OUTALU <= (others => '0'); OUTALU(0) <= '1';	
            	else
                	OUTALU <= (others => '0');
            	end if;

	when SLTS =>
            	if (signed(DATA1) < signed(DATA2)) then
                	OUTALU <= (others => '0'); OUTALU(0) <= '1';	
            	else
                	OUTALU <= (others => '0');
            	end if;
	
	when SGTS =>
            	if (signed(DATA1) > signed(DATA2)) then
                OUTALU <= (others => '0'); OUTALU(0) <= '1';	
            	else
                	OUTALU <= (others => '0');
            	end if;

	 when SGEUS =>
            	if (unsigned(DATA1) >= unsigned(DATA2)) then
                	OUTALU <= (others => '0'); OUTALU(0) <= '1';	
            	else
                	OUTALU <= (others => '0');
            	end if;

	 when SLEUS =>
            	if (unsigned(DATA1) <= unsigned(DATA2)) then
                	OUTALU <= (others => '0'); OUTALU(0) <= '1';	
            	else
                	OUTALU <= (others => '0');
            	end if;

	 when SLTUS =>
            	if (unsigned(DATA1) < unsigned(DATA2)) then
                	OUTALU <= (others => '0'); OUTALU(0) <= '1';	
            	else
                	OUTALU <= (others => '0');
            	end if;

	when SGTUS =>
            	if (unsigned(DATA1) > unsigned(DATA2)) then
                	OUTALU <= (others => '0'); OUTALU(0) <= '1';	
            	else
                	OUTALU <= (others => '0');
            	end if;

        when LHIS =>                          -- lhi: immediate in the upper half
                OUTALU(N-1 downto 16) <= DATA2(15 downto 0);
                OUTALU(15 downto 0)   <= (others => '0');
        when others => 
            OUTALU <= (others => '0');

    end case; 
  end process PROCESS_ALU;

end BEHAVIOR;

configuration CFG_ALU_BEHAVIORAL of ALU is
  for BEHAVIOR
  end for;
end CFG_ALU_BEHAVIORAL;