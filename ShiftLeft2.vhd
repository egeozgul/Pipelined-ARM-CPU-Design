library ieee;
use ieee.std_logic_1164.all;

entity ShiftLeft2 is -- Two by one mux with 5 bit inputs/outputs
port(
x : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
y : out STD_LOGIC_VECTOR(63 downto 0) -- sel == 1
);
end ShiftLeft2;


architecture Behavior of ShiftLeft2 is
begin

y <= x(61 downto 0) & "00";

end Behavior;

