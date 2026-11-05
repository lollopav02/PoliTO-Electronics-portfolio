library IEEE;
use IEEE.std_logic_1164.all;

entity MUX21_GENERIC is
  Generic (NBIT: integer:= 16; -- parameter for the number of bits
           DELAY_MUX: time := 3 ns);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NBIT-1 downto 0));
end MUX21_GENERIC;

architecture behavioural of MUX21_GENERIC is -- no components used in the behavioral arch
begin


                   Y <= A when SEL = '1' else B;

end behavioural;


architecture structural of MUX21_GENERIC is
    
  signal s_sel : std_logic; -- mux selector signal
  signal s_and_a, s_and_b: std_logic_vector(NBIT-1 downto 0); -- mux input signals

  begin
  s_sel<=SEL;
  str_mux_gen :  for i in 0 to NBIT-1 generate -- mux syntax for nbits configuration

      s_and_a(i)<=A(i) and s_sel;
      s_and_b(i)<=B(i) and (not(s_sel));
    
      Y(i)<= s_and_a(i) or s_and_b(i);

 end generate str_mux_gen;

end structural;
  

-- configuration defininitions for the testbench

configuration CFG_MUX21_BEHAVIOURAL of MUX21_GENERIC is
	for behavioural
	end for;
end CFG_MUX21_BEHAVIOURAL;

configuration CFG_MUX21_STRUCTURAL of MUX21_GENERIC is
	for structural
	end for;
end CFG_MUX21_STRUCTURAL;
