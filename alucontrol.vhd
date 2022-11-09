library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALUControl is
-- Functionality should match truth table shown in Figure 4.13 in the textbook.
-- Check table on page2 of ISA.pdf on canvas. Pay attention to opcode of operations and type of operations. 
-- If an operation doesn't use ALU, you don't need to check for its case in the ALU control implemenetation.	
--  To ensure proper functionality, you must implement the "don't-care" values in the funct field,
-- for example when ALUOp = '00", Operation must be "0010" regardless of what Funct is.
port(
     ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
     Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
     Operation : out STD_LOGIC_VECTOR(3 downto 0)
    );
end ALUControl;
architecture beh of ALUControl is
begin

-- declarative part: empty
vv : process(ALUOp,Opcode)

begin

if (ALUOp = "00") then
	Operation <= "0010";

elsif (ALUOp(1) = '1') and (Opcode = "10001011000") then --ADD
	Operation <= "0010";
elsif (ALUOp(1) = '1') and (Opcode = "10010001000") then --ADDI
	Operation <= "0010";
elsif (ALUOp(1) = '1') and (Opcode = "11001011000") then -- SUB
	Operation <= "0110";
elsif (ALUOp(1) = '1') and (Opcode(10 downto 1) = "1101000100") then -- SUBI
	Operation <= "0110";
elsif (ALUOp(1) = '1') and (Opcode = "10001010000") then --AND
	Operation <= "0000";
elsif (ALUOp(1) = '1') and (Opcode = "10101010000") then --ORR
	Operation <= "0001";
elsif (ALUOp(0) = '1') then
	Operation <= "0111";
else
	Operation <= "0000";
end if;

end process vv;
end beh;