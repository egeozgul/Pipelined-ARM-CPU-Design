library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SignExtend is
port(
x : in STD_LOGIC_VECTOR(31 downto 0);
y : out STD_LOGIC_VECTOR(63 downto 0)
);
end SignExtend;

architecture Behavior of SignExtend is
begin

vv : process(x)
begin
		

if    x(31 downto 22) = "1001000100" then  --ADDI
	y <= std_logic_vector(resize(signed(x(21 downto 10)), 64));
elsif    x(31 downto 22) = "1101000100" then  --SUBI
	y <= std_logic_vector(resize(signed(x(21 downto 10)), 64));
elsif    x(31 downto 26) = "000101" then  --branch
	y <= std_logic_vector(resize(signed(x(25 downto 0)), 64));
elsif    x(31 downto 21) = "11111000000" then  --STDUR
	y <= std_logic_vector(resize(signed(x(20 downto 12)), 64));
elsif    x(31 downto 21) = "11111000010" then  --LDUR
	y <= std_logic_vector(resize(signed(x(20 downto 12)), 64));
elsif    x(31 downto 24) = "10110100" then  --CBZ
	y <= std_logic_vector(resize(signed(x(23 downto 5)), 64));
else
	y <= std_logic_vector(resize(signed(x), 64));
end if;

end process vv;

end architecture;

