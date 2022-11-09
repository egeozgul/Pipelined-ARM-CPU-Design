library ieee;
use ieee.std_logic_1164.all;

entity AND2 is
port(
in0 : in STD_LOGIC; -- sel == 0
in1 : in STD_LOGIC; -- sel == 1
output : out STD_LOGIC
);
end AND2;


architecture Behavior of AND2 is
begin
	output <= in0 and in1;
end Behavior;