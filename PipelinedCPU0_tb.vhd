library ieee;
use ieee.std_logic_1164.all;


entity  PipelinedCPU0_tb  is
end PipelinedCPU0_tb ;

Architecture Behavior of PipelinedCPU0_tb is

signal     clk : STD_LOGIC:= '0';
signal     rst : STD_LOGIC:= '1';
    	 --Probe ports used for testing
   	  --The current address (AddressOut from the PC)
signal     DEBUG_PC :  STD_LOGIC_VECTOR(63 downto 0);
   	  --The current instruction (Instruction output of IMEM)
signal     DEBUG_INSTRUCTION :  STD_LOGIC_VECTOR(31 downto 0);
	     --DEBUG ports from other components
signal     DEBUG_TMP_REGS :  STD_LOGIC_VECTOR(64*4 - 1 downto 0);
signal     DEBUG_SAVED_REGS :  STD_LOGIC_VECTOR(64*4 - 1 downto 0);
signal     DEBUG_MEM_CONTENTS :  STD_LOGIC_VECTOR(64*4 - 1 downto 0);
begin
	uut: entity work.PipelinedCPU0 PORT MAP(clk,rst,DEBUG_PC ,DEBUG_INSTRUCTION , DEBUG_TMP_REGS, DEBUG_SAVED_REGS, DEBUG_MEM_CONTENTS);
	
	
	process
	begin
		clk <= not clk;
		wait for 10 ns;
	end process;--

	process
	begin
		wait for 1 ns;
		rst <= '0';
		wait for 1000 ns;
		
	end process;

end Behavior;










