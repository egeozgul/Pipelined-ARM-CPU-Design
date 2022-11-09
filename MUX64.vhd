
library ieee;
use ieee.std_logic_1164.all;

entity MUX64 is -- Two by one mux with 32 bit inputs/outputs
port(
in0 : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
in1 : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 1
sel : in STD_LOGIC; -- selects in0 or in1
output : out STD_LOGIC_VECTOR(63 downto 0)
);
end MUX64;


architecture Behavior of MUX64 is
begin
process(sel, in0, in1) is
	begin
		if (sel = '0') then
			output <= in0;
		else
			output <= in1;
		end if;
end process;
end Behavior;




