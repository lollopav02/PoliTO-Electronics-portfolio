library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.all;

entity register_file is
    generic (
        BIT_WIDTH    : natural := 32;
        ADDR_WIDTH   : natural := 5;
        REG_NUMBER   : natural := 32
    );
    port ( 
        CLK     : IN  std_logic;
        RESET   : IN  std_logic;
        ENABLE  : IN  std_logic;
        --RD1     : IN  std_logic;	--both removed from lab file since CU does not sent these signals
        --RD2     : IN  std_logic;
        WR      : IN  std_logic;
        ADD_WR  : IN  std_logic_vector(ADDR_WIDTH - 1 downto 0);
        ADD_RD1 : IN  std_logic_vector(ADDR_WIDTH - 1 downto 0);
        ADD_RD2 : IN  std_logic_vector(ADDR_WIDTH - 1 downto 0);
        DATAIN  : IN  std_logic_vector(BIT_WIDTH - 1 downto 0);
        OUT1    : OUT std_logic_vector(BIT_WIDTH - 1 downto 0);
        OUT2    : OUT std_logic_vector(BIT_WIDTH - 1 downto 0)
    );
end register_file;

architecture A of register_file is
    type REG_ARRAY is array(0 to REG_NUMBER - 1) of std_logic_vector(BIT_WIDTH - 1 downto 0);
    signal REGISTERS : REG_ARRAY; 		-- is a matrix of 32 registers 32 bits each
begin
	OUT1 <= (others => '0') when ADD_RD1 = "00000" else
       	 	DATAIN          when (WR = '1' and ADD_RD1 = ADD_WR) else	--combinatoral reading in order to have OUT1 and OUT2 								--ready for the next clock cycle
        	REGISTERS(to_integer(unsigned(ADD_RD1)));			--otherwise could keep one more clock cycle with sequential reading

	OUT2 <= (others => '0') when ADD_RD2 = "00000" else			--FORWARDING: data in output either with CU write command enabled or WB address 
										-- from ID phase is uqual to  the input address of RF
        	DATAIN          when (WR = '1' and ADD_RD2 = ADD_WR) else
        	REGISTERS(to_integer(unsigned(ADD_RD2)));

	

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '0' then    						-- synchronous reset
                REGISTERS <= (others => (others => '0'));			-- double others function since we are working on an a matrix	
            elsif ENABLE = '1' then
                if WR = '1' then
                    REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;	--addresses are first used as unsigned binary values,
									--then converted as integers to choose the correct register	
                end if;
           end if;
	end if;

    
    
        
    end process;

end A;

