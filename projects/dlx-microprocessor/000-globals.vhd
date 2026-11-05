library ieee;
use ieee.std_logic_1164.all;

package myTypes is

    -- ALU operation types
    type aluOp is (NOP, ADDS, SUBS, ANDS, ORS, XORS, LLS, LRS, ARS,SGES, SLES, SNES,
		 SEQS, SLTS, SGTS,SGEUS, SLEUS, SLTUS, SGTUS, LHIS);

    -- Control Unit input field sizes
    constant OP_CODE_SIZE : integer := 6;   -- OPCODE field size
    constant FUNC_SIZE    : integer := 11;  -- FUNC field size

    constant numBit 	  : integer := 32;  --ALU size 
    

    -- R-Type instructions (FUNC field)
    constant RTYPE_ADD : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100000"; -- R[RC] = R[RA] + R[RB]
    constant RTYPE_SUB : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100010"; -- R[RC] = R[RA] - R[RB]
    constant RTYPE_AND : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100100"; -- R[RC] = R[RA] AND R[RB]
    constant RTYPE_OR  : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100101"; -- R[RC] = R[RA] OR R[RB]
    constant RTYPE_XOR : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100110"; -- R[RC] = R[RA] XOR R[RB]
    constant RTYPE_SLL : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000000100"; -- R[RC] = R[RA] SLL R[RB]
    constant RTYPE_SRL : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000000110"; -- R[RC] = R[RA] SRL R[RB]
    constant RTYPE_SNE : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000101001"; -- R[RC] = (R[RA] /= R[RB])
    constant RTYPE_SLE : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000101100"; -- R[RC] = (R[RA] <= R[RB])
    constant RTYPE_SGE : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000101101"; -- R[RC] = (R[RA] >= R[RB])
    constant RTYPE_SRA  : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000000111"; -- 0x07
    constant RTYPE_ADDU : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100001"; -- 0x21
    constant RTYPE_SUBU : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100011"; -- 0x23
    constant RTYPE_SEQ  : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000101000"; -- 0x28
    constant RTYPE_SLT  : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000101010"; -- 0x2A
    constant RTYPE_SGT  : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000101011"; -- 0x2B
    constant RTYPE_SLTU : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000111010"; -- 0x3A
    constant RTYPE_SGTU : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000111011"; -- 0x3B
    constant RTYPE_SLEU : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000111100"; -- 0x3C
    constant RTYPE_SGEU : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000111101"; -- 0x3D
    -- Base OPCODE for Register-to-Register operations
    constant RTYPE     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000000";

    -- I-Type & J-Type instructions (OPCODE field)
    constant ITYPE_NOP  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010101"; -- No operation
    constant ITYPE_J    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000010"; -- PC = Target
    constant ITYPE_JAL  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000011"; -- R[31] = PC + 4; PC = Target
    constant ITYPE_BEQZ : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000100"; -- if (R[RA] == 0) PC = PC + Offset
    constant ITYPE_BNEZ : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000101"; -- if (R[RA] /= 0) PC = PC + Offset
    constant ITYPE_JR   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010010"; -- PC = R[RA]
    constant ITYPE_JALR : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010011"; -- R[31] = PC + 4; PC = R[RA]
    constant ITYPE_LHI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001111"; -- R[RB] = Imm << 16
    constant ITYPE_ADDI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001000"; -- R[RA] = R[RB] + INP1
    constant ITYPE_SUBI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001010"; -- R[RA] = R[RB] - INP1
    constant ITYPE_ANDI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001100"; -- R[RA] = R[RB] AND INP1
    constant ITYPE_ORI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001101"; -- R[RA] = R[RB] OR INP1
    constant ITYPE_XORI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001110"; -- R[RA] = R[RB] XOR INP1
    constant ITYPE_SLLI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010100"; -- R[RA] = R[RB] SLL INP1
    constant ITYPE_SRLI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010110"; -- R[RA] = R[RB] SRL INP1
    constant ITYPE_SNEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011001"; -- R[RA] = (R[RB] /= INP1)
    constant ITYPE_SLEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011100"; -- R[RA] = (R[RB] <= INP1)
    constant ITYPE_SGEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011101"; -- R[RA] = (R[RB] >= INP1)
    constant ITYPE_LW   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "100011"; -- R[RA] = MEM[R[RB] + INP1]
    constant ITYPE_SW   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "101011"; -- MEM[R[RB] + INP1] = R[RA]
    constant ITYPE_ADDUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001001"; -- 0x09
    constant ITYPE_SUBUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001011"; -- 0x0B
    constant ITYPE_SRAI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010111"; -- 0x17
    constant ITYPE_SEQI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011000"; -- 0x18
    constant ITYPE_SLTI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011010"; -- 0x1A
    constant ITYPE_SGTI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011011"; -- 0x1B
    constant ITYPE_SLTUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "111010"; -- 0x3A
    constant ITYPE_SGTUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "111011"; -- 0x3B
    constant ITYPE_SLEUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "111100"; -- 0x3C
    constant ITYPE_SGEUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "111101"; -- 0x3D
end myTypes;