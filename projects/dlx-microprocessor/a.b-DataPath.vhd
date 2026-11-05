library ieee;
use ieee.std_logic_1164.all;
use WORK.myTypes.all;


entity DataPath is

generic (N : integer := numBit);

port(
	Clk                : IN  std_logic;  -- Clock
   	Rst                : IN  std_logic;  -- Reset:Active-Low
	DIN		   : IN std_logic_vector(N -1 downto 0); -- DRAM data
	IR		   : IN std_logic_vector(N -1 downto 0);   --instruction register content to be decoded
	NPC_IN		   : IN std_logic_vector(N -1 downto 0);	
	--fetch phase done in the DLX file
	--decode
	RegA_LATCH_EN      : IN std_logic;  -- Register A Latch Enable
    	RegB_LATCH_EN      : IN std_logic;  -- Register B Latch Enable
    	RegIMM_LATCH_EN    : IN std_logic;  -- Immediate Register Latch Enable
	--execute
	MUXA_SEL           : IN std_logic;  -- MUX-A Sel
    	MUXB_SEL           : IN std_logic;  -- MUX-B Sel
    	ALU_OUTREG_EN      : IN std_logic;  -- ALU Output Register Enable
	EQ_COND            : IN std_logic;  -- Branch if (not) Equal to Zero
	ALU_OPCODE         : IN aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);
	RF_WE_EX  	   : IN std_logic;
    	--memory
    	LMD_LATCH_EN       : IN std_logic;  -- LMD Register Latch Enable
    	JUMP_EN            : IN std_logic;  -- JUMP Enable Signal for PC input MUX
    	RF_WE_MEM 	   : IN std_logic;
	--writeback
	WB_MUX_SEL         : IN std_logic;  -- Write Back MUX Sel
    	RF_WE              : IN std_logic;  -- Register File Write Enable
	

		
	DADDR		   : OUT std_logic_vector(N -1 downto 0); --DRAM address
	DOUT		   : OUT std_logic_vector(N -1 downto 0); --DRAM data	   
	PC_OUT		   : OUT std_logic_vector(N -1 downto 0); --Next PC value
	FLUSH 		   : OUT std_logic;			 --flush for CU for correct branch prediction
	STALL		   : OUT std_logic
);




end entity;


architecture behavior of Datapath is

	component ALU is
	  generic (N : integer := numBit);
	  port ( 
	    FUNC   : IN  aluOp;
	    DATA1  : IN  std_logic_vector(N-1 downto 0);
	    DATA2  : IN  std_logic_vector(N-1 downto 0);
	    OUTALU : OUT std_logic_vector(N-1 downto 0)
	  );
	end component;
	
	component register_file is
	    generic (
		BIT_WIDTH    : natural := 32;
		ADDR_WIDTH   : natural := 5;
		REG_NUMBER   : natural := 32
	    );
	    port ( 
		CLK     : IN  std_logic;
		RESET   : IN  std_logic;
		ENABLE  : IN  std_logic;
		WR      : IN  std_logic;
		ADD_WR  : IN  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		ADD_RD1 : IN  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		ADD_RD2 : IN  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		DATAIN  : IN  std_logic_vector(BIT_WIDTH - 1 downto 0);
		OUT1    : OUT std_logic_vector(BIT_WIDTH - 1 downto 0);
		OUT2    : OUT std_logic_vector(BIT_WIDTH - 1 downto 0)
	    );
	end component;
	
	component REG is
		Generic(numBit: integer);
		Port (	D:	In	std_logic_vector(numBit-1 downto 0);
			EN: 	In	std_logic;
			CK:	In	std_logic;
			RESET:	In	std_logic;
			Q:	Out	std_logic_vector(numBit-1 downto 0));
	end component;


	component MUX21_GENERIC is
		Generic (NBIT: integer:= 16); -- parameter for the number of bits
			 
		Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
			B:	In	std_logic_vector(NBIT-1 downto 0);
			SEL:	In	std_logic;
			Y:	Out	std_logic_vector(NBIT-1 downto 0));

	end component;
	
	

	--fields extraction from IR instruction
	signal opcode 	   : std_logic_vector(5 downto 0);
	signal rs1 	   : std_logic_vector(4 downto 0);
	signal rs2 	   : std_logic_vector(4 downto 0);
	signal rd_i 	   : std_logic_vector(4 downto 0);
	signal rd_r 	   : std_logic_vector(4 downto 0);
	signal immediate_i : std_logic_vector(15 downto 0);
	signal immediate_j : std_logic_vector(25 downto 0);
	--used in decode stage
	signal wr_addr     :std_logic_vector(4 downto 0);
	signal wr_data     :std_logic_vector(numBit-1 downto 0);
	signal regrd_ex    : std_logic_vector(4 downto 0);
	signal regrd_mem   : std_logic_vector(4 downto 0);
	signal regrd_wb	   : std_logic_vector(4 downto 0);
	signal sel_muxRD   : std_logic;
	signal sel_muxIMM  : std_logic;
	signal rf_out1     : std_logic_vector(numBit-1 downto 0);	
	signal rf_out2     : std_logic_vector(numBit-1 downto 0);
	signal sign_ext    : std_logic_vector(numBit-1 downto 0);
	signal regA_out    : std_logic_vector(numBit-1 downto 0);
	signal regB_out    : std_logic_vector(numBit-1 downto 0);
	signal regIMM_out  : std_logic_vector(numBit-1 downto 0);
	signal regA_zero   : std_logic;
	signal take_branch : std_logic;
	signal is_jump     : std_logic;
	signal npc_id      : std_logic_vector(numBit-1 downto 0);			--NPC propagated to EX for branch target computation
	signal is_jal 	   : std_logic;
	signal stall_int   : std_logic;
	signal npc_en      : std_logic;
	signal is_load	   : std_logic;
	signal is_load_ex  : std_logic;
	--execute
	signal muxA_out: std_logic_vector(numBit-1 downto 0);
	signal muxB_out: std_logic_vector(numBit-1 downto 0);
	signal alu_out: std_logic_vector(numBit-1 downto 0);
	signal regAlu_out: std_logic_vector(numBit-1 downto 0);
	signal is_jump_ex : std_logic;
	signal cond       : std_logic;
	signal cond_mem   : std_logic;
	signal npc_ex      : std_logic_vector(numBit-1 downto 0);
	signal is_jal_ex  : std_logic;
	signal rs1_ex, rs2_ex : std_logic_vector(4 downto 0);
	signal fwdA, fwdB     : std_logic_vector(numBit-1 downto 0);
	--memory
	signal regB_mem: std_logic_vector(numBit-1 downto 0);
	signal LMD_out: std_logic_vector(numBit-1 downto 0);
	signal is_jal_mem	   : std_logic;
	signal npc_mem     : std_logic_vector(numBit-1 downto 0);
	
	
	--writeback
	signal imm_i_ext : std_logic_vector(numBit-1 downto 0);
	signal imm_j_ext : std_logic_vector(numBit-1 downto 0);
	signal fill_i 	 : std_logic_vector(15 downto 0);	
	signal fill_j 	 : std_logic_vector(5 downto 0);
	signal regAlu_wb : std_logic_vector(numBit-1 downto 0);
	signal is_jal_wb : std_logic;
	signal npc_wb    : std_logic_vector(numBit-1 downto 0);
	signal wb_out     : std_logic_vector(numBit-1 downto 0);
	signal wr_addr_wb : std_logic_vector(4 downto 0);
	signal wr_addr_to_ex : std_logic_vector(4 downto 0);





begin

	opcode 		<= IR(numBit-1 downto 26);
	rs1 		<= IR(25 downto 21);
	rs2 		<= IR(20 downto 16);
	rd_i 		<= IR(20 downto 16);		--taking infos on IR
	rd_r 		<= IR(15 downto 11);
	immediate_i 	<= IR(15 downto 0);
	immediate_j 	<= IR(25 downto 0);
	--decode
	sel_muxRD 	<= '1' when opcode="000000" else '0';
	sel_muxIMM    	<= '1' when (opcode=ITYPE_J) or (opcode=ITYPE_JAL) else '0';   -- j and jal 0x02 and 0x03
	
	fill_i <= (others => '0') when (opcode = ITYPE_ANDI  or opcode = ITYPE_ORI   or opcode = ITYPE_XORI  or
                                opcode = ITYPE_ADDUI or opcode = ITYPE_SUBUI or
                                opcode = ITYPE_SLTUI or opcode = ITYPE_SGTUI or
                                opcode = ITYPE_SLEUI or opcode = ITYPE_SGEUI)
          	else (others => immediate_i(15));   											--in order to not lose sign MSB value is taken
	fill_j 		<= (others => immediate_j(25));	   --in order to not lose sign MSB value is taken
	imm_i_ext	<= fill_i & immediate_i;	   --joint to create 32 bit value
	imm_j_ext       <= fill_j & immediate_j;	   --joint to create 32 bit value
	 
	is_load <= '1' when opcode = ITYPE_LW else '0';	
       
	regA_zero <= '1' when fwdA = (fwdA'range => '0') else '0';	--check condition
	is_jump <= '1' when (opcode = ITYPE_J) or (opcode = ITYPE_JAL) or (opcode = ITYPE_JR) or (opcode = ITYPE_JALR) else '0';  -- unconditional jumps
	cond        <= '1' when is_jump_ex = '1' or EQ_COND = regA_zero else '0';   -- EX
	take_branch <= '1' when JUMP_EN = '1' and cond = '1' else '0';           -- MEM
	FLUSH <= take_branch;
	is_jal <= '1' when (opcode = ITYPE_JAL) or (opcode = ITYPE_JALR) else '0';  -- write PC + 4 into r31

	stall_int <= '1' when is_load_ex = '1' and
			((rs1 /= "00000" and rs1 = regrd_ex) or		--stalls when problems happens on rs1 or rs2
			(rs2 /= "00000" and rs2 = regrd_ex))		--if rs1/rs2 reads r0 does not make problems									--hazards occurs when: 
   		 else '0';						--1) instruction wants to write in the register file
									--2) instruction wants to write in the same register which		
									--instruction in decode stage wants to read
   	wr_addr_to_ex <= "00000" when stall_int = '1' else wr_addr;		

	STALL  <= stall_int;
	npc_en <= not stall_int;	
		

	

	fwdA <= regAlu_out when (rs1_ex /= "00000" and rs1_ex = regrd_mem  and RF_WE_MEM = '1') else
        wr_data    when (rs1_ex /= "00000" and rs1_ex = wr_addr_wb and RF_WE     = '1') else
        regA_out;

	fwdB <= regAlu_out when (rs2_ex /= "00000" and rs2_ex = regrd_mem  and RF_WE_MEM = '1') else
		wr_data    when (rs2_ex /= "00000" and rs2_ex = wr_addr_wb and RF_WE     = '1') else
		regB_out;
	
	

	COND_PIPE: process(Clk, Rst)
	begin
	    if Rst = '0' then
		is_jump_ex  <= '0';
		cond_mem    <= '0';
		is_jal_ex   <= '0';
		is_jal_mem  <= '0';
		is_jal_wb   <= '0';
		is_load_ex  <= '0';
		
	    elsif rising_edge(Clk) then
		is_jump_ex <= is_jump;     -- ID -> EX
		cond_mem   <= cond;        -- EX -> MEM
		is_jal_ex  <= is_jal;
		is_jal_mem <= is_jal_ex;
		is_jal_wb  <= is_jal_mem;
		is_load_ex <= is_load;
		
	    end if;
	end process;


	REG_FILE: register_file
	
	port map(
		CLK     =>Clk,
		RESET   =>Rst,
		ENABLE  => '1',
		WR      => RF_WE,
		ADD_WR  => wr_addr_wb,
		ADD_RD1 => rs1,
		ADD_RD2 => rs2,
		DATAIN  => wr_data,
		OUT1    => rf_out1,
		OUT2    => rf_out2

	);

	REGA:  REG
		generic map (numBit => 32)
		port map(	
			D     => rf_out1,
			EN    => RegA_LATCH_EN,
			CK    => Clk,	
			RESET => Rst,	
			Q     => regA_out
			);
	REGB:  REG
		generic map (numBit => 32)
		port map(
			D     => rf_out2,
			EN    => RegB_LATCH_EN,
			CK    => Clk,	
			RESET => Rst,	
			Q     => regB_out
			);

	MUXIMM:  MUX21_GENERIC
		generic map (NBIT => 32)
		port map(
			A   => 	imm_j_ext,
			B   => 	imm_i_ext,
			SEL =>	sel_muxIMM,
			Y   =>	sign_ext
		        );
	
	REGI:  REG
		generic map (numBit => 32)
		port map (
			D     => sign_ext,      --immediate from IR extended to 32 bits
			EN    => RegIMM_LATCH_EN,
			CK    => Clk,
			RESET => Rst,	
			Q     => regIMM_out
			);
	MUXA:  MUX21_GENERIC
		generic map (NBIT => 32)
		port map(
			A   => 	npc_ex,
			B   => 	fwdA,
			SEL =>	MUXA_SEL,
			Y   =>	muxA_out
		        );
	MUXB:  MUX21_GENERIC
		generic map (NBIT => 32)
		port map(
			A   => 	fwdB,
			B   => 	regIMM_out,
			SEL =>	MUXB_SEL,
			Y   =>	muxB_out
		        );
	MUXRD:  MUX21_GENERIC
		generic map (NBIT => 5)
		port map(
			A   => rd_r,
			B   => rd_i,
			SEL => sel_muxRD,
			Y   => wr_addr
		        );

	ALU_i : ALU	
	        generic map (N => 32)
	        port map( 
	        	FUNC  => ALU_OPCODE,
	        	DATA1 =>muxA_out,
	        	DATA2 =>muxB_out ,
	       		OUTALU => alu_out
	  	);

	REGALU:  REG
		generic map (numBit => 32)
		port map(
			D     => alu_out,
			EN    =>ALU_OUTREG_EN,
			CK    => Clk,	
			RESET => Rst,	
			Q     => regAlu_out
			);

	MUXJUMP:  MUX21_GENERIC
		generic map (NBIT => 32)
		port map(
			A   => alu_out,
			B   => NPC_IN,
			SEL => take_branch,
			Y   => PC_OUT
				);
	
	REGALUWB:  REG					--used in order to save the n of the ALU result
			generic map (numBit =>32)
			port map(
				D     => regAlu_out ,
				EN    => '1',
				CK    => Clk,	
				RESET => Rst,	
				Q     => regAlu_wb
				);
	
	REGBPROP:  REG					--used in order to save the value to be stored in the EX stage, and use B REG for other instructions
		generic map (numBit => 32)
		port map(
			D     => fwdB,
			EN    => '1',
			CK    => Clk,	
			RESET => Rst,	
			Q     => regB_mem
			);
	REGLMD:  REG					--used in order to save the data from DRAM during load instructions
		generic map (numBit => 32)
		port map(
			D     => DIN,
			EN    => LMD_LATCH_EN,
			CK    => Clk,	
			RESET => Rst,	
			Q     => LMD_out
			);
			
	MUXWB:  MUX21_GENERIC
		generic map (NBIT => 32)
		port map(
			A   => LMD_out,
			B   => regAlu_wb,
			SEL => WB_MUX_SEL,
			Y   => wb_out
		        );

	
	REGEX:  REG					--used in order to save the n of reg of the destination register
			generic map (numBit => 5)
			port map(
				D     => regrd_ex,
				EN    => '1',
				CK    => Clk,	
				RESET => Rst,	
				Q     => regrd_mem
				);
	REGMEM:  REG					--used in order to save the n of reg of the destination register
			generic map (numBit => 5)
			port map(
				D     => regrd_mem,
				EN    => '1',
				CK    => Clk,	
				RESET => Rst,	
				Q     => regrd_wb
				);
	
	REGWB:  REG					--used in order to save the n of reg of the destination register
			generic map (numBit => 5)
			port map(
				D     => wr_addr_to_ex,
				EN    => '1',
				CK    => Clk,	
				RESET => Rst,	
				Q     =>regrd_ex
				);

	REGNPC_ID: REG
	    generic map (numBit => 32)
	    port map(
		D     => NPC_IN,
		EN    => npc_en,
		CK    => Clk,
		RESET => Rst,
		Q     => npc_id
	    );

	REGNPC_EX: REG
	    generic map (numBit => 32)
	    port map(
		D     => npc_id,
		EN    => '1',
		CK    => Clk,
		RESET => Rst,
		Q     => npc_ex
	    );

	REGNPC_MEM: REG
	    generic map (numBit => 32)
	    port map(
		D     => npc_ex,
		EN    => is_jal_ex,
		CK    => Clk,
		RESET => Rst,
		Q     => npc_mem
	    );

	REGNPC_WB: REG
	    generic map (numBit => 32)
	    port map(
		D     => npc_mem,
		EN    => is_jal_mem,
		CK    => Clk,
		RESET => Rst,
		Q     => npc_wb
	    );
		
	REGRS1:  REG					
			generic map (numBit => 5)
			port map(
				D     => rs1,
				EN    => npc_en,   --not stall_int
				CK    => Clk,	
				RESET => Rst,	
				Q     => rs1_ex
				);		
	REGRS2:  REG					
			generic map (numBit => 5)
			port map(
				D     => rs2,
				EN    => npc_en,
				CK    => Clk,	
				RESET => Rst,	
				Q     => rs2_ex
				);
	
	MUXJAL_DATA:  MUX21_GENERIC
		generic map (NBIT => 32)
	    	port map(
		A   => npc_wb,
		B   => wb_out,
		SEL => is_jal_wb,
		Y   => wr_data
		);

	MUXJAL_ADDR: MUX21_GENERIC
	    generic map (NBIT => 5)
	    port map(
		A   => "11111",
		B   => regrd_wb,
		SEL => is_jal_wb,
		Y   => wr_addr_wb
	    );
		--outputs for DRAM that will be used in the DLX file

	DADDR <= regAlu_out;
	DOUT <= regB_mem;

end architecture;







