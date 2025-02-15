-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
-------------------------------------------------------------------------
-- tb_fetchLogic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Testbench for the fetchLogic module.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY tb_fetchLogic IS
END ENTITY tb_fetchLogic;

ARCHITECTURE tb OF tb_fetchLogic IS
        CONSTANT CLOCK_PERIOD : TIME := 20 ns;

        COMPONENT fetchLogic IS
                PORT (
        i_inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Instruction input
        i_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- PC Address input
        i_clk : IN STD_LOGIC; -- clock bit
        i_rst : IN STD_LOGIC; -- reset bit
        i_zero : IN STD_LOGIC; -- zero bit from ALU
        i_branch : in std_logic; -- branch bit from control
        i_jump : IN STD_LOGIC; -- jump bit from control
        i_jr : IN STD_LOGIC; -- jump return bit from control
        i_jal : IN STD_LOGIC; -- jump and link bit from control
	i_rs : in std_logic_vector(31 downto 0);
        o_ra : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Output for $ra Address
        o_newPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Output for PC Address
        END COMPONENT;

        SIGNAL i_clk, i_rst, i_jump, i_jal, i_jr, i_branch, i_zero : STD_LOGIC;
        SIGNAL i_inst, i_PC, i_rs, o_newPC, o_ra : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN

        DUT0 : fetchLogic
        PORT MAP(
                i_clk => i_clk,
                i_rst => i_rst,
                i_jump => i_jump,
                i_jr => i_jr,
                i_jal => i_jal,
                i_branch => i_branch,
                i_inst => i_inst,
                i_PC => i_PC,
		i_rs => i_rs,
                o_newPC => o_newPC,
		i_zero => i_zero,
                o_ra => o_ra);

        -- Clock process
        clk_process : PROCESS
        BEGIN
                i_clk <= '0';
                WAIT FOR CLOCK_PERIOD / 2;
                i_clk <= '1';
                WAIT FOR CLOCK_PERIOD / 2;
        END PROCESS;

        -- Stimulus process
        stim_process : PROCESS
        BEGIN
                -- Initialize inputs
                i_inst <= x"20010001"; -- Program Counter initial value
                i_rst <= '0';
		wait for 5 ns;
		i_rst <= '1';
                WAIT FOR 20 ns;
                i_rst <= '0';
		i_jump <= '0';
                i_jal <= '0';
		i_jr <= '0';
                i_branch <= '0';
		WAIT FOR 15 ns; -- 40 ns

                -- Reset Test
                i_PC <= o_newPC; -- Current PC Address
                i_rst <= '1'; -- Reset signal active
                WAIT FOR CLOCK_PERIOD;  -- 60 ns
                -- Expected result: Next address should remain the same after reset
                ASSERT o_newPC = x"00400000" REPORT "Reset test failed" SEVERITY error;

                -- addi Test
                i_inst <= x"20090032"; -- addi instruction
                i_PC <= o_newPC; -- Current PC Address
                i_rst <= '0'; -- Reset signal active
                WAIT FOR CLOCK_PERIOD;  -- 80 ns
                -- Expected result: Next address should remain the same after reset
                ASSERT o_newPC = x"00400004" REPORT "Addi test failed" SEVERITY error;

                -- Jump test
                i_inst <= x"08100008"; -- Jump instruction
                i_PC <= o_newPC; -- Current PC Address
                i_jump <= '1'; -- Jump signal
                WAIT FOR CLOCK_PERIOD;
                -- Expected result: Next address should be 0x08000000
                ASSERT o_newPC = x"00400020" REPORT "Jump instruction failed" SEVERITY error;

                -- addi Test
                i_inst <= x"200a0032"; -- addi instruction
                i_PC <= o_newPC; -- Current PC Address
                i_jump <= '0'; -- Jump signal
                WAIT FOR CLOCK_PERIOD;
                -- Expected result: Next address should remain the same after reset
                ASSERT o_newPC = x"00400024" REPORT "Addi test failed" SEVERITY error;

                -- Branch Equal Test
                i_inst <= x"116c0001"; -- Branch Equal instruction
                i_PC <= o_newPC; -- Current PC Address
                i_branch <= '1'; -- Branch Equal signal
		i_zero <= '1';
                WAIT FOR CLOCK_PERIOD;
                -- Expected result: Next address should be 0x0040002c (if condition is true)
                ASSERT o_newPC = x"0040002c" REPORT "Branch Equal instruction failed" SEVERITY error;

                -- sub Test
                i_inst <= x"01ad6822"; -- Sub instruction
                i_PC <= o_newPC; -- Current PC Address
                i_branch <= '0'; -- Branch Equal signal
		i_zero <= '0';
                WAIT FOR CLOCK_PERIOD;
                -- Expected result: Next address should be 0x00000014 (if condition is true)
                ASSERT o_newPC = x"00400030" REPORT "Sub instruction failed" SEVERITY error;

                -- Branch Not Equal Test
                i_inst <= x"158d0001"; -- Branch Not Equal instruction
                i_PC <= o_newPC; -- Current PC Address
                i_branch <= '1'; -- Branch Not Equal signal
		i_zero <= '1';
                WAIT FOR CLOCK_PERIOD;
                -- Expected result: Next address should be 0x00000014 (if condition is true)
                ASSERT o_newPC = x"00400038" REPORT "Branch Not Equal instruction failed" SEVERITY error;

                -- jal Test
                i_inst <= x"0c100011"; -- jal instruction
                i_PC <= o_newPC; -- Current PC Address
                i_branch <= '0'; -- Branch Not Equal signal
		i_zero <= '0';
                i_jal <= '1'; -- jal signal
                WAIT FOR CLOCK_PERIOD;
                -- Expected result: Next address should be 0x00000014 (if condition is true)
                ASSERT o_newPC = x"00400044" REPORT "JAL instruction failed" SEVERITY error;

                -- jr Test
                i_inst <= x"03e00008"; -- jr instruction
		i_rs <= x"0040003c";
                i_PC <= x"00400044"; -- Current PC Address
                i_jr <= '1'; -- jr signal
                i_jal <= '0'; -- jal signal
                WAIT FOR CLOCK_PERIOD;
                ASSERT o_newPC = x"0040003c" REPORT "JR instruction failed" SEVERITY error;

                -- addi Test
                i_inst <= x"200d0032"; -- addi instruction
                i_PC <= o_newPC; -- Current PC Address
                i_jr <= '0'; -- jr signal
                WAIT FOR CLOCK_PERIOD;
                -- Expected result: Next address should remain the same after reset
                ASSERT o_newPC = x"00400040" REPORT "Reset test failed" SEVERITY error;
                WAIT;
        END PROCESS;
END ARCHITECTURE tb;