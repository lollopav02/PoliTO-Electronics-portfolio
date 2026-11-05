library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
--use ieee.numeric_std.all;
--use work.all;

entity dlx_cu is

  generic (
    MICROCODE_MEM_SIZE :     integer := 64;  -- Microcode Memory Size
    FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    -- ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
    IR_SIZE            :     integer := 32;  -- Instruction Register Size    
    CW_SIZE            :     integer := 15);  -- Control Word Size
  port (
    Clk                : in  std_logic;  -- Clock
    Rst                : in  std_logic;  -- Reset:Active-Low
    STALL 	       : in std_logic;
    -- Instruction Register
    IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);
    
    -- IF Control Signal
    IR_LATCH_EN        : out std_logic;  -- Instruction Register Latch Enable
    NPC_LATCH_EN       : out std_logic;
                                        -- NextProgramCounter Register Latch Enable
    -- ID Control Signals
    RegA_LATCH_EN      : out std_logic;  -- Register A Latch Enable
    RegB_LATCH_EN      : out std_logic;  -- Register B Latch Enable
    RegIMM_LATCH_EN    : out std_logic;  -- Immediate Register Latch Enable

    -- EX Control Signals
    MUXA_SEL           : out std_logic;  -- MUX-A Sel
    MUXB_SEL           : out std_logic;  -- MUX-B Sel
    ALU_OUTREG_EN      : out std_logic;  -- ALU Output Register Enable
    EQ_COND            : out std_logic;  -- Branch if (not) Equal to Zero
    RF_WE_EX	       : out std_logic;  -- for managing stalls
    -- ALU Operation Code
    ALU_OPCODE         : out aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);
    FLUSH 	       : IN std_logic;
    -- MEM Control Signals
    DRAM_WE            : out std_logic;  -- Data RAM Write Enable
    LMD_LATCH_EN       : out std_logic;  -- LMD Register Latch Enable
    JUMP_EN            : out std_logic;  -- JUMP Enable Signal for PC input MUX
    PC_LATCH_EN        : out std_logic;  -- Program Counte Latch Enable
    RF_WE_MEM	       : out std_logic;  -- for managing stalls

    -- WB Control signals
    WB_MUX_SEL         : out std_logic;  -- Write Back MUX Sel
    RF_WE_WB              : out std_logic);  -- Register File Write Enable

    

end dlx_cu;

architecture dlx_cu_hw of dlx_cu is

  type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);

  constant cw_mem : mem_array := (
	0  => "111100110000101",               -- R-Type (ADD, SUB, AND, OR, XOR, SLL, SRL, SNE, SLE, SGE, SRA, ADDU, SUBU, SEQ, SLT, SGT, SLTU, SGTU, SLEU, SGEU)
        1  => "000000000000000",               -- Unused
        2  => "111011010001100",               -- J    (MUXA=NPC, MUXB=Imm, JUMP_EN=1, PC_EN=1, RF_WE=0)
        3  => "110011010001101",               -- JAL  (as J, but RF_WE=1 in order to save  PC+4 in R31) ----da rivedere
        4  => "111011011001100",               -- BEQZ (RegA, MUXA=NPC, MUXB=Imm, EQ_COND=1, PC_EN=1)
        5  => "111011010001100",               -- BNEZ (as CW of BEQZ)
        18 => "111010010001100",               -- JR   (RegA, MUXA=RegA, MUXB=Imm=0, JUMP_EN=1)
        19 => "111010010001101",               -- JALR (as JR, plus RF_WE=1: R31 = PC + 4)
        6  => "000000000000000",               -- Unused
        7  => "000000000000000",               -- Unused
        8  => "111010010000101",               -- ADDI (I-Type Aritmetic)      
	9  => "111010010000101",               -- ADDUI (I-Type Unsigned Add)
        10 => "111010010000101",               -- SUBI
        11 => "111010010000101",               -- SUBUI (I-Type Unsigned Sub)
        12 => "111010010000101",               -- ANDI
        13 => "111010010000101",               -- ORI
        14 => "111010010000101",               -- XORI
        15 => "111010010000101",               -- LHI  (RegIMM, MUXB=Imm, RF_WE=1: R[rd] = Imm << 16)
        16 => "000000000000000",               -- Unused
        17 => "000000000000000",               -- Unused
        20 => "111010010000101",               -- SLLI
        21 => "000000000000000",               -- NOP / Unused
        22 => "111010010000101",               -- SRLI
        23 => "111010010000101",               -- SRAI (I-Type Arithmetic Right Shift)
        24 => "111010010000101",               -- SEQI (I-Type Set on Equal)
        25 => "111010010000101",               -- SNEI
        26 => "111010010000101",               -- SLTI (I-Type Set on Less Than)
        27 => "111010010000101",               -- SGTI (I-Type Set on Greater Than)
        28 => "111010010000101",               -- SLEI
        29 => "111010010000101",               -- SGEI
        30 => "000000000000000",               -- Unused
        31 => "000000000000000",               -- Unused
        32 => "000000000000000",               -- Unused
        33 => "000000000000000",               -- Unused
        34 => "000000000000000",               -- Unused
        35 => "111010010010111",               -- LW   (Addr=RegA+Imm, DRAM_WE=0, LMD_EN=1, WB_MUX=1, RF_WE=1)
        36 => "000000000000000",               -- Unused
        37 => "000000000000000",               -- Unused
        38 => "000000000000000",               -- Unused
        39 => "000000000000000",               -- Unused
        40 => "000000000000000",               -- Unused
        41 => "000000000000000",               -- Unused
        42 => "000000000000000",               -- Unused
        43 => "111110010100100",               -- SW   (Addr=RegA+Imm, RegB attivo, DRAM_WE=1, RF_WE=0)
        44 to 57 => "000000000000000",         -- Unused
        58 => "111010010000101",               -- SLTUI (I-Type Set on Less Than Unsigned)
        59 => "111010010000101",               -- SGTUI (I-Type Set on Greater Than Unsigned)
        60 => "111010010000101",               -- SLEUI (I-Type Set on Less or Equal Unsigned)
        61 => "111010010000101",               -- SGEUI (I-Type Set on Greater or Equal Unsigned)
        62 => "000000000000000",               -- Remaining positions
	63 => "000000000000000"
  );                     
                         
  signal IR_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR
  signal IR_func : std_logic_vector(FUNC_SIZE - 1 downto 0);   -- Func part of IR when Rtype
  signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem


  -- control word is shifted to the correct stage
  signal cw1 : std_logic_vector(CW_SIZE -1 downto 0); -- first stage
  signal cw2 : std_logic_vector(CW_SIZE - 1 - 2 downto 0); -- second stage
  signal cw3 : std_logic_vector(CW_SIZE - 1 - 5 downto 0); -- third stage
  signal flush_d : std_logic;
  signal aluOpcode_i: aluOp := NOP; -- ALUOP defined in package
  signal aluOpcode: aluOp := NOP;


  
  signal stall_eff : std_logic;                       
  

 
begin  -- dlx_cu_rtl

  IR_opcode(5 downto 0) <= IR_IN(31 downto 26);
  IR_func(10 downto 0)  <= IR_IN(FUNC_SIZE - 1 downto 0);

  cw <= cw_mem(conv_integer(IR_opcode));


  -- stage one control signals
  IR_LATCH_EN  <= not stall_eff;			--fetch always enabled
  NPC_LATCH_EN <= not stall_eff;
  
  -- stage two control signals
  RegA_LATCH_EN   <= cw(CW_SIZE - 3);
  RegB_LATCH_EN   <= cw(CW_SIZE - 4);
  RegIMM_LATCH_EN <= cw(CW_SIZE - 5);
  
  -- stage three control signals
  MUXA_SEL      <= cw1(CW_SIZE - 6);
  MUXB_SEL      <= cw1(CW_SIZE - 7);
  ALU_OUTREG_EN <= cw1(CW_SIZE - 8);
  EQ_COND       <= cw1(CW_SIZE - 9);
  RF_WE_EX      <= cw1(CW_SIZE - 15);
  -- stage four control signals
  DRAM_WE       <= cw2(CW_SIZE - 10);
  LMD_LATCH_EN  <= cw2(CW_SIZE - 11);
  JUMP_EN       <= cw1(CW_SIZE - 12);
  PC_LATCH_EN   <= not stall_eff;
  RF_WE_MEM     <= cw2(CW_SIZE - 15);
  -- stage five control signals
  WB_MUX_SEL    <= cw3(CW_SIZE - 14);
  RF_WE_WB      <= cw3(CW_SIZE - 15);


  stall_eff <= STALL and not FLUSH and not flush_d;   

  -- process to pipeline control words
  CW_PIPE: process (Clk, Rst)
  begin  -- process Clk
    
    if Rst = '0' then                   -- asynchronous reset (active low)
      cw1 <= (others => '0');
      cw2 <= (others => '0');
      cw3 <= (others => '0');
      flush_d <= '0';
      aluOpcode <= NOP;
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      if FLUSH = '1' or flush_d = '1' or stall_eff = '1' then
    	cw1 <= (others => '0');
    	cw2 <= cw1(CW_SIZE - 1 - 2 downto 0);
	cw3 <= cw2(CW_SIZE - 1 - 5 downto 0);
       else
	    cw1 <= cw;
	    cw2 <= cw1(CW_SIZE - 1 - 2 downto 0);
	    cw3 <= cw2(CW_SIZE - 1 - 5 downto 0);
      end if;  
      aluOpcode <= aluOpcode_i;
      flush_d <= FLUSH;
    end if;
  end process CW_PIPE;

  ALU_OPCODE <= aluOpcode
;		--ALU command instruction assigned here

  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : IR_i
  -- outputs: aluOpcode

   ALU_OP_CODE_P : process (IR_opcode, IR_func)
   begin  -- process ALU_OP_CODE_P

	case conv_integer(unsigned(IR_opcode)) is

	        -- case of R type requires analysis of FUNC
		when 0 =>
			case conv_integer(unsigned(IR_func)) is			--func code converted to integer
				when 4  => aluOpcode_i <= LLS; -- sll according to instruction set coding
				when 6  => aluOpcode_i <= LRS; -- srl
				when 7  => aluOpcode_i <= ARS; -- sra (Arithmetic Right Shift)
				when 32 => aluOpcode_i <= ADDS;
				when 33 => aluOpcode_i <= ADDS; -- addu (Unsigned Add, same bitwise operation)
				when 34 => aluOpcode_i <= SUBS;
				when 35 => aluOpcode_i <= SUBS; -- subu (Unsigned Sub, same bitwise operation)
				when 36 => aluOpcode_i <= ANDS;
				when 37 => aluOpcode_i <= ORS;
				when 38 => aluOpcode_i <= XORS;
				when 40 => aluOpcode_i <= SEQS; -- seq (Set on Equal)
				when 41 => aluOpcode_i <= SNES;
				when 42 => aluOpcode_i <= SLTS; -- slt (Set on Less Than, Signed)
				when 43 => aluOpcode_i <= SGTS; -- sgt (Set on Greater Than, Signed)
				when 44 => aluOpcode_i <= SLES;
				when 45 => aluOpcode_i <= SGES;
				when 58 => aluOpcode_i <= SLTUS; -- sltu (Set on Less Than, Unsigned)
				when 59 => aluOpcode_i <= SGTUS; -- sgtu (Set on Greater Than, Unsigned)
				when 60 => aluOpcode_i <= SLEUS; -- sleu (Set on Less or Equal, Unsigned)
				when 61 => aluOpcode_i <= SGEUS; -- sgeu (Set on Greater or Equal, Unsigned)
				when others => aluOpcode_i <= NOP;
		end case;

		when 2  => aluOpcode_i <= ADDS; -- j
		when 3  => aluOpcode_i <= ADDS; -- jal
		when 4  => aluOpcode_i <= ADDS;
		when 5  => aluOpcode_i <= ADDS;		
		when 18 => aluOpcode_i <= ADDS; -- jr: target = R[RA] + 0
		when 19 => aluOpcode_i <= ADDS; -- jalr
		when 15 => aluOpcode_i <= LHIS; -- lhi
		when 8  => aluOpcode_i <= ADDS; -- addi
		when 9  => aluOpcode_i <= ADDS; -- addui (I-Type Unsigned Add)
		when 10 => aluOpcode_i <= SUBS;
		when 11 => aluOpcode_i <= SUBS; -- subui (I-Type Unsigned Sub)
		when 12 => aluOpcode_i <= ANDS;
		when 13 => aluOpcode_i <= ORS;
		when 14 => aluOpcode_i <= XORS;
		when 20 => aluOpcode_i <= LLS;
		when 22 => aluOpcode_i <= LRS;
		when 23 => aluOpcode_i <= ARS;  -- srai (I-Type Arithmetic Right Shift)
		when 24 => aluOpcode_i <= SEQS; -- seqi (I-Type Set on Equal)
		when 25 => aluOpcode_i <= SNES;
		when 26 => aluOpcode_i <= SLTS; -- slti (I-Type Set on Less Than, Signed)
		when 27 => aluOpcode_i <= SGTS; -- sgti (I-Type Set on Greater Than, Signed)
		when 28 => aluOpcode_i <= SLES;
		when 29 => aluOpcode_i <= SGES;
		when 35 => aluOpcode_i <= ADDS;
		when 43 => aluOpcode_i <= ADDS;
		when 58 => aluOpcode_i <= SLTUS; -- sltui (I-Type Set on Less Than, Unsigned)
		when 59 => aluOpcode_i <= SGTUS; -- sgtui (I-Type Set on Greater Than, Unsigned)
		when 60 => aluOpcode_i <= SLEUS; -- sleui (I-Type Set on Less or Equal, Unsigned)
		when 61 => aluOpcode_i <= SGEUS; -- sgeui (I-Type Set on Greater or Equal, Unsigned)
		when others => aluOpcode_i <= NOP;
	 end case;
	end process ALU_OP_CODE_P;


end dlx_cu_hw;
