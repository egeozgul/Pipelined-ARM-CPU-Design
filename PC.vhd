library ieee;
use ieee.std_logic_1164.all;
use IEEE.Numeric_STD.all;


entity PC is
port(
	clk 		 : in STD_LOGIC;
	write_enable : in STD_LOGIC;
	rst 		 : in STD_LOGIC;
	AddressIn 	 : in STD_LOGIC_VECTOR(63 downto 0);
	AddressOut 	 : out STD_LOGIC_VECTOR(63 downto 0)
);
end PC;

architecture Behavior of PC is
signal counter : STD_LOGIC_VECTOR(63 downto 0) := x"0000000000000000";
begin

process(clk,rst,AddressIn,counter) is 
begin
    if rst = '1' then
        counter <= x"0000000000000000";
    end if;
    
	if rising_edge(clk)  then
		if(write_enable = '1') then
			counter <= AddressIn;
		else 
    			counter <= std_logic_vector( (unsigned(counter) + 1 ) mod (x"FFFFFFFFFFFFFFFF")) ;			
		end if;
		
	end if;
AddressOut <= counter;
end process;
end Behavior;