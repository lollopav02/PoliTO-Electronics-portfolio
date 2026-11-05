library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity CARRY_SELECT_BLOCK is
    generic (
        NBIT : positive := 4 -- default dimension of the block
    );
    port (
        A   : in  std_logic_vector(NBIT - 1 downto 0);
        B   : in  std_logic_vector(NBIT - 1 downto 0);
        Ci  : in  std_logic;    -- Real Carry in that act as the MUX selector
        S   : out std_logic_vector(NBIT - 1 downto 0)
    );
end CARRY_SELECT_BLOCK;

architecture STRUCTURAL of CARRY_SELECT_BLOCK is
    component RCA
        generic (
            NBIT  : positive
        );
        port (
            A  : in  std_logic_vector(NBIT - 1 downto 0);
            B  : in  std_logic_vector(NBIT - 1 downto 0);
            Ci : in  std_logic;
            S  : out std_logic_vector(NBIT - 1 downto 0);
            Co : out std_logic
        );
    end component;
 
    component MUX21_4BIT
        generic (N : positive := 4);
        port (
            A:  in  std_logic_vector(N - 1 downto 0);
            B:  in  std_logic_vector(N - 1 downto 0);
            S:  in  std_logic;
            Y:  out std_logic_vector(N - 1 downto 0)
        );
    end component;

    signal sum_low  : std_logic_vector(NBIT - 1 downto 0);
    signal sum_high : std_logic_vector(NBIT - 1 downto 0);
begin

    RCA_LOW: RCA    -- RCA with Carry-in = '0' 
        generic map (NBIT => NBIT)
        port map (
            A  => A,
            B  => B,
            Ci => '0',
            S  => sum_low,
            Co => open
        );

    RCA_HIGH: RCA    -- RCA with Carry-in = '1' 
        generic map (NBIT => NBIT)
        port map (
            A  => A,
            B  => B,
            Ci => '1',
            S  => sum_high,
            Co => open
        );

    MUX_INST: MUX21_4BIT   -- MUX: Map 'sum_high' on 'A' because MUX Y <= A when S='1'
        generic map (N => NBIT)
        port map (
            A => sum_high,
            B => sum_low,
            S => Ci,
            Y => S
        );
end STRUCTURAL;