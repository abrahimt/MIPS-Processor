-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/19/2024
-- tb_alu.vhd
-- Testbench for the ALU (Arithmetic Logic Unit) component used in a 
-- processor.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE std.textio.ALL; -- For basic I/O

ENTITY tb_alu IS
	GENERIC (gCLK_HPER : TIME := 10 ns); -- Generic for half of the clock cycle period
END tb_alu;

ARCHITECTURE structure OF tb_alu IS

	-- Define the total clock period time
	CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

	COMPONENT alu IS
		PORT (
			i_RS : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_RT : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_Imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			i_ALUSrc : IN STD_LOGIC;
			i_bne : IN STD_LOGIC;
			i_beq : IN STD_LOGIC;
			i_shiftDir : IN STD_LOGIC;
			i_shiftType : IN STD_LOGIC;
			i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_addSub : IN STD_LOGIC;
			i_signed : IN STD_LOGIC;
			i_lui : IN STD_LOGIC;
			o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_overflow : OUT STD_LOGIC;
			o_zero : OUT STD_LOGIC);
	END COMPONENT;

	SIGNAL s_ALUOp : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_shamt : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL s_RS, s_RT, s_Imm, s_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_CLK, s_ALUSrc, s_bne, s_beq, s_shiftDir, s_shiftType, s_addSub, s_signed, s_overflow, s_zero, s_lui : STD_LOGIC;
BEGIN

	DUT0 : alu
	PORT MAP(
		i_RS => s_RS,
		i_RT => s_RT,
		i_Imm => s_Imm,
		i_ALUOp => s_ALUOp,
		i_ALUSrc => s_ALUSrc,
		i_bne => s_bne,
		i_beq => s_beq,
		i_shiftDir => s_shiftDir,
		i_shiftType => s_shiftType,
		i_shamt => s_shamt,
		i_addSub => s_addSub,
		i_signed => s_signed,
		i_lui => s_lui,
		o_result => s_result,
		o_overflow => s_overflow,
		o_zero => s_zero);
	-- This process sets the clock value (low for gCLK_HPER, then high
	-- for gCLK_HPER). Absent a "wait" command, processes restart 
	-- at the beginning once they have reached the final statement.
	P_CLK : PROCESS
	BEGIN
		s_CLK <= '0';
		WAIT FOR gCLK_HPER;
		s_CLK <= '1';
		WAIT FOR gCLK_HPER;
	END PROCESS;


TEST_CASES : PROCESS

	BEGIN

		-- There are a total of 23 tests (each one waits a clock cycle)

		--addi
		s_RS <= x"00000000"; -- $0
		s_Imm <= x"00000001"; -- 1
		s_ALUOp <= "0010";
		s_ALUSrc <= '1';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '1';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"00000001" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000001"

		--subu
		s_RS <= x"00080000";
		s_RT <= x"00000001";
		s_ALUOp <= "0010";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '1';
		s_signed <= '1';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"0007FFFF" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000004"

		--or 
		s_RS <= x"ABC12300";
		s_RT <= x"00000000";
		s_ALUOp <= "0111";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"ABC12300" REPORT "Error: result mismatch" SEVERITY error; --expect result = x"ABC12300"

		--ori
		s_RS <= x"AB012300";
		s_Imm <= x"FF0FFFFF";
		s_ALUOp <= "0111";
		s_ALUSrc <= '1';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"FF0FFFFF" REPORT "Error: result mismatch" SEVERITY error; --expect result = x"FFFFFFFF"
		--and
		s_RS <= x"ABC12300";
		s_RT <= x"00000000";
		s_ALUOp <= "0011";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"00000000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000000"
		--xori
		s_RS <= x"0000000F";
		s_Imm <= x"FFF0FFFF";
		s_ALUOp <= "0110";
		s_ALUSrc <= '1';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"FFF0FFF0" REPORT "Error: result mismatch" SEVERITY error; --Expect all bits of o_result to be inverted
		--nor
		s_RS <= x"ABC12300";
		s_RT <= x"FFFFFFFF";
		s_ALUOp <= "0101";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"00000000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000000"

		--add
		s_RS <= x"7FFFFFFF";
		s_RT <= x"00000001";
		s_ALUOp <= "0010";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '1';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"80000000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"80000000" and overflow flag should be set to 1
		--addu
		s_RS <= x"7FFFFFFF";
		s_RT <= x"00000001";
		s_Imm <= x"00000008";
		s_ALUOp <= "0010";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"80000000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"80000000" and overflow flag should not be raised
		--addi
		s_RS <= x"00000004";
		s_RT <= x"00000000";
		s_Imm <= x"00000008";
		s_ALUOp <= "0010";
		s_ALUSrc <= '1';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '1';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"0000000C" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"0000000C"
		--subu
		s_RS <= x"00000008";
		s_RT <= x"00000004";
		s_Imm <= x"FFFFFFFF";
		s_ALUOp <= "0010";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '1';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"00000004" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000004"
		--beq (branch)
		s_RS <= x"00000008";
		s_RT <= x"00000008";
		s_Imm <= x"FFFFFFFF";
		s_ALUOp <= "0000";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '1';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"00000000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000000" (not written to a register), branch = '1'
		--beq (don't branch)
		s_RS <= x"00000008";
		s_RT <= x"00000005";
		s_Imm <= x"FFFFFFFF";
		s_ALUOp <= "0000";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '1';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"00000000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000000" (not written to a register), branch = '0'
		--bne (branch)
		s_RS <= x"00000008";
		s_RT <= x"00000005";
		s_Imm <= x"FFFFFFFF";
		s_ALUOp <= "0000";
		s_ALUSrc <= '0';
		s_bne <= '1';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"00000000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000000" (not written to a register), branch = '1'
		--bne (don't branch)
		s_RS <= x"00000008";
		s_RT <= x"00000008";
		s_Imm <= x"FFFFFFFF";
		s_ALUOp <= "0000";
		s_ALUSrc <= '0';
		s_bne <= '1';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"00000000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000000" (not written to a register), branch = '0'

		--sll 
		s_RS <= x"00000000";
		s_RT <= x"0000FFFF";
		s_Imm <= x"FFFFFFFF";
		s_ALUOp <= "1001";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '1';
		s_shiftType <= '0';
		s_shamt <= "00001";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"0001FFFE" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"0001FFFE" 

		--srl 
		s_RS <= x"00000000";
		s_RT <= x"FFFF0000";
		s_Imm <= x"FFFFFFFF";
		s_ALUOp <= "1001";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00001";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"7FFF8000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"7FFF8000" 
		--sra 
		s_RS <= x"00000000";
		s_RT <= x"FFFF0000";
		s_Imm <= x"FFFFFFFF";
		s_ALUOp <= "1001";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '1';
		s_shamt <= "00001";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"FFFF8000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"FFFF8000" 
		--lui 
		s_RS <= x"00000000";
		s_RT <= x"00000000";
		s_Imm <= x"0000FFFF";
		s_ALUOp <= "1001";
		s_ALUSrc <= '1';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '1';
		s_shiftType <= '0';
		s_shamt <= "00001";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '1';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"FFFF0000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"FFFF0000" 
		--lui 
		s_RS <= x"00000000";
		s_RT <= x"00000000";
		s_Imm <= x"00000004";
		s_ALUOp <= "1001";
		s_ALUSrc <= '1';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '1';
		s_shiftType <= '0';
		s_shamt <= "00001";
		s_addSub <= '0';
		s_signed <= '0';
		s_lui <= '1';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"00040000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00040000" 
		--slt (true case)
		s_RS <= x"00000008";
		s_RT <= x"00000009";
		s_Imm <= x"00000008";
		s_ALUOp <= "1000";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '1';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"00000001" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000001"
		--slt (false case)
		s_RS <= x"00000009";
		s_RT <= x"00000008";
		s_Imm <= x"00000008";
		s_ALUOp <= "1000";
		s_ALUSrc <= '0';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '1';
		s_lui <= '0';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_result = x"00000000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000000"
		--slti (edgy case)
		s_RS <= x"00000009";
		s_RT <= x"0000000C";
		s_Imm <= x"00000009";
		s_ALUOp <= "1000";
		s_ALUSrc <= '1';
		s_bne <= '0';
		s_beq <= '0';
		s_shiftDir <= '0';
		s_shiftType <= '0';
		s_shamt <= "00000";
		s_addSub <= '0';
		s_signed <= '1';
		s_lui <= '0';
		WAIT;
		ASSERT s_result = x"00000000" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000000"
	END PROCESS;

END structure;