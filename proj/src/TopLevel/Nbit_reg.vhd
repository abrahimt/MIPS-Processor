-- Nbit_reg.vhd

library IEEE;
use IEEE.std_logic_1164.all;
use work.MIPS_types.all;

entity Nbit_reg is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_CLK        : in std_logic;     			-- Clock input
       i_RST        : in std_logic;     			-- Reset input
       i_WE         : in std_logic;                             -- Write enable input
       i_D          : in std_logic_vector(N-1 downto 0);	-- 32 bit input
       o_Q          : out std_logic_vector(N-1 downto 0));	-- 32 bit output
end Nbit_reg;


architecture structural of Nbit_reg is

  component dffg is
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic;     -- Data value input
         o_Q          : out std_logic);   -- Data value output
  end component;

begin

-- Instantiate N mux instances.
  G_NBit_Reg: for i in 0 to N-1 generate
    REG: dffg port map(
		i_CLK       => i_CLK,       -- Clock input
    i_RST       => i_RST,       -- Reset input
    i_WE        => i_WE,        -- Write enable input
    i_D         => i_D(i),      -- All instances share the same input.
    o_Q         => o_Q(i));     -- ith instance's data output hooked up to ith data output.
  end generate G_NBit_Reg;
  
end structural;
