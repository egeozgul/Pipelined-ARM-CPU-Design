library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- STD_LOGIC and STD_LOGIC_VECTOR
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity MEM_WB_REG_tb is
--port();
end MEM_WB_REG_tb;

architecture behavioral of MEM_WB_REG_tb is

signal readEnable   : STD_LOGIC:='0';
signal writeEnable  : STD_LOGIC:='0';
signal clk          : STD_LOGIC:='0';
	 
signal A_in         : STD_LOGIC := '0';
signal A_out    	: STD_LOGIC := '0';
	 
signal B_in     	: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal B_out    	: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
	 
signal C_in     	: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal C_out    	: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
	 
signal D_in     	: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
signal D_out    	: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
	 	
		

begin

   regg: entity work.MEM_WB_REG 
   PORT MAP(readEnable,writeEnable,clk,A_in,A_out,B_in,B_out,C_in,C_out,D_in,D_out);

   process
   begin
		clk <= not clk;
		wait for 10 ns;
   end process;

	process
	begin
	readEnable <= '0';
	writeEnable <= '1';
	
	A_in <= '1';
	D_in <= "11111";
	
	wait for 50 ns;
	
	writeEnable <= '0';
	
	A_in <= '0';
	D_in <= "00000";
	
	wait for 50 ns;
	
	readEnable <= '1';
	wait for 50 ns;
	end process;


end behavioral;


