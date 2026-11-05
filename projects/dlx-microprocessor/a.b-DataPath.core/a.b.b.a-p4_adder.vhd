library ieee;
use ieee.std_logic_1164.all;

entity P4_ADDER is
 generic (
  NBIT : integer := 32
 );
 port (
  A    : in  std_logic_vector(NBIT-1 downto 0);
  B    : in  std_logic_vector(NBIT-1 downto 0);
  Cin  : in  std_logic;
  S    : out std_logic_vector(NBIT-1 downto 0);
  Cout : out std_logic
  );
end P4_ADDER;

architecture STRUCTURAL of P4_ADDER is
 constant NBIT_PER_BLOCK : integer := 4;     -- Setting block size as a architecture internal constant 
 constant NUM_BLOCKS     : integer := NBIT / NBIT_PER_BLOCK;

 component CARRY_GENERATOR        -- Tree Carry Generator
  generic ( NBIT : integer; NBIT_PER_BLOCK : integer );
  port (
   A   : in  std_logic_vector(NBIT-1 downto 0);
   B   : in  std_logic_vector(NBIT-1 downto 0);
   Cin : in  std_logic;
   Co  : out std_logic_vector((NBIT/NBIT_PER_BLOCK)-1 downto 0)
   );
 end component;

 component SUM_GENERATOR        -- Select Carry Adder
  generic ( NBIT_PER_BLOCK : integer; NBLOCKS : integer );
  port (
   A  : in  std_logic_vector(NBIT_PER_BLOCK * NBLOCKS - 1 downto 0);
   B  : in  std_logic_vector(NBIT_PER_BLOCK * NBLOCKS - 1 downto 0);
   Ci : in  std_logic_vector(NBLOCKS - 1 downto 0);
   S  : out std_logic_vector(NBIT_PER_BLOCK * NBLOCKS - 1 downto 0)
   );
 end component;

 signal carry_out_tree : std_logic_vector(NUM_BLOCKS-1 downto 0); -- Internal signal to connect carry generator and sum generator
 signal carry_in_sum   : std_logic_vector(NUM_BLOCKS-1 downto 0);

 begin 
 carry_in_sum(0) <= Cin;       -- connecting carry (C0 to Cin; C4,8,12,etc. to the respective source)
 carry_in_sum(NUM_BLOCKS-1 downto 1) <= carry_out_tree(NUM_BLOCKS-2 downto 0);

 Cout <= carry_out_tree(NUM_BLOCKS-1);     -- the last carry out is given as output

 CG: CARRY_GENERATOR       -- Instance of the carry generator
  generic map (
  NBIT => NBIT,
  NBIT_PER_BLOCK => NBIT_PER_BLOCK
  )
 port map ( 
  A => A, 
  B => B, 
  Cin => Cin, 
  Co => carry_out_tree 
  );

 SG: SUM_GENERATOR       -- Instance of the sum generator
  generic map (
   NBIT_PER_BLOCK => NBIT_PER_BLOCK, 
   NBLOCKS => NUM_BLOCKS
   )
  port map (
   A => A,
   B => B,
   Ci => carry_in_sum,
   S => S
   );

end STRUCTURAL;