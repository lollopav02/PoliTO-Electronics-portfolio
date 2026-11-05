library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

-- Data memory for DLX
-- Memory filled by data by ALU output register


entity DRAM is
  generic (
    RAM_DEPTH : integer := numBit*2;
    D_SIZE : integer := numBit);
  port (
    Clk		: in std_logic;
    Rst  	: in  std_logic;
    DRAM_WE     : in  std_logic;
    Din 	: in std_logic_vector(D_SIZE - 1 downto 0);
    addr	: in  std_logic_vector(D_SIZE - 1 downto 0);
    Dout 	: out std_logic_vector(D_SIZE - 1 downto 0)
    );

end DRAM;

architecture behaviour of DRAM is

  type RAMtype is array (0 to RAM_DEPTH - 1) of integer;-- std_logic_vector(D_SIZE - 1 downto 0);

  signal DRAM_mem : RAMtype;

begin  -- DRam_Bhe

  --reading process, combinatorial behaviour

  Dout <= conv_std_logic_vector(DRAM_mem(conv_integer(unsigned(addr(D_SIZE-1 downto 2))) mod RAM_DEPTH), D_SIZE);   --data converted and resized to 32 bits
 

  --writing process, sequential behaviour

  FILL_MEM_P: process (Clk,Rst)
   

begin  
     	if rising_edge(Clk) then
	  if (Rst = '0') then
		DRAM_mem <= (others => 0);
		elsif DRAM_WE = '1' then
		 DRAM_mem(conv_integer(unsigned(addr(D_SIZE-1 downto 2))) mod RAM_DEPTH) <= conv_integer(unsigned(Din));       
		--removing the last 2 LSB since we are not storing bytes but entire words    	
	  end if;	
        end if;
end process FILL_MEM_P;

end behaviour;


	