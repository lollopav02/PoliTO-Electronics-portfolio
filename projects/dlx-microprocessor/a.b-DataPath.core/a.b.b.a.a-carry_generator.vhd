library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CARRY_GENERATOR is
    generic (
        NBIT           : integer := 32;
        NBIT_PER_BLOCK : integer := 4
    );
    port (
        A   : in  std_logic_vector(NBIT-1 downto 0);
        B   : in  std_logic_vector(NBIT-1 downto 0);
        Cin : in  std_logic;
        Co  : out std_logic_vector((NBIT/NBIT_PER_BLOCK)-1 downto 0)
    );
end CARRY_GENERATOR;

architecture STRUCTURAL of CARRY_GENERATOR is

    component PG_NET_BLOCK
        port ( A, B : in std_logic; p, g : out std_logic );
    end component;

    component G_BLOCK
        port ( Pik, Gik, Gkj : in std_logic; Gij : out std_logic );
    end component;

    component PG_BLOCK
        port ( Pik, Gik, Pkj, Gkj : in std_logic; Pij, Gij : out std_logic );
    end component;

    type SignalVector is array (NBIT downto 0) of std_logic_vector(NBIT downto 0);
 
    signal P_matrix : SignalVector;        -- Propagation Matrix
    signal G_matrix : SignalVector;        -- Generation Matrix
 
begin
 
    rows: for row in 0 to NBIT-1 generate

        row0: if row = 0 generate
            columns0: for column in 0 to NBIT generate            
                gen_cin: if column = 0 generate
                    P_matrix(0)(0) <= '0';
                    G_matrix(0)(0) <= Cin;
                end generate;
           
                gen_pg: if column > 0 generate
                    PG_NET: PG_NET_BLOCK port map (
                        A => A(column-1), B => B(column-1),
                        p => P_matrix(0)(column), g => G_matrix(0)(column)
                    );
                end generate;
            end generate columns0;
        end generate row0;
   
        row_n: if row > 0 generate
            tree_active: if (2**(row-1) <= NBIT) generate
                columns: for column in 0 to NBIT generate                    
                    pass_cin: if column = 0 generate
                        P_matrix(row)(0) <= '0';
                        G_matrix(row)(0) <= G_matrix(row-1)(0);
                    end generate;
                    
                    connect: if column > 0 generate                        
                        pass_wire: if column < 2**(row-1) generate
                            P_matrix(row)(column) <= P_matrix(row-1)(column);
                            G_matrix(row)(column) <= G_matrix(row-1)(column);
                        end generate;
                     
                        do_block: if column >= 2**(row-1) generate
                            use_g: if (column - 2**(row-1)) = 0 generate
                                G_INST: G_BLOCK port map (
                                    Pik => P_matrix(row-1)(column),
                                    Gik => G_matrix(row-1)(column),
                                    Gkj => G_matrix(row-1)(0),
                                    Gij => G_matrix(row)(column)
                                );
                                P_matrix(row)(column) <= '0';
                            end generate;
               
                            use_pg: if (column - 2**(row-1)) > 0 generate
                                PG_INST: PG_BLOCK port map (
                                    Pik => P_matrix(row-1)(column),
                                    Gik => G_matrix(row-1)(column),
                                    Pkj => P_matrix(row-1)(column - 2**(row-1)),
                                    Gkj => G_matrix(row-1)(column - 2**(row-1)),
                                    Pij => P_matrix(row)(column),
                                    Gij => G_matrix(row)(column)
                                );
                            end generate;
                        end generate do_block;
                    end generate connect;
                end generate columns;
            end generate tree_active;tree_inactive: if (2**(row-1) > NBIT) generate
                copy_row: for column in 0 to NBIT generate
                    P_matrix(row)(column) <= P_matrix(row-1)(column);
                    G_matrix(row)(column) <= G_matrix(row-1)(column);
                end generate;
            end generate tree_inactive;
        end generate row_n;
    end generate rows;

    output_gen: for i in 0 to (NBIT/NBIT_PER_BLOCK)-1 generate
        Co(i) <= G_matrix(NBIT-1)(((i+1) * NBIT_PER_BLOCK));
    end generate output_gen;

end STRUCTURAL;