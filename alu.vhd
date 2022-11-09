library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ALU is
-- Implement: AND, OR, ADD (signed), SUBTRACT (signed)
--    as described in Section 4.4 in the textbook.
-- The functionality of each instruction can be found on the 'ARM Reference Data' sheet at the
--    front of the textbook (or the ISA pdf on Canvas).
port(
     in0       : in     STD_LOGIC_VECTOR(63 downto 0);
     in1       : in     STD_LOGIC_VECTOR(63 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : out STD_LOGIC_VECTOR(63 downto 0);
     zero      : out STD_LOGIC;
     overflow  : out STD_LOGIC
    );
end ALU;

architecture Behavior of ALU is
signal temp : STD_LOGIC_VECTOR(64 downto 0);
begin


-- declarative part: empty
vv : process(in0,in1,operation,temp)
begin

if operation = "0000" then
	result <= in0 and in1;
	temp <= ('0' & in0) and ('0' & in1);
   	if temp="00000000000000000000000000000000000000000000000000000000000000000" then
    		zero <= '1' ;
    	else
    		zero <= '0' ;
    	end if;
	overflow <= temp(64);

elsif operation = "0001" then
	result <= in0 or in1;
	temp <= ('0' & in0) or ('0' & in1);
    	if temp="00000000000000000000000000000000000000000000000000000000000000000" then
   		zero <= '1' ;
    	else
    		zero <= '0' ;
    	end if;
	overflow <= temp(64);

elsif operation = "0110" then
	result <= in0 - in1;
	temp <= ('0' & in0) - ('0' & in1);
    	if temp="00000000000000000000000000000000000000000000000000000000000000000" then
    		zero <= '1' ;
    	else
    		zero <= '0' ;
    	end if;

	if(in0(63)='0' and in1(63)='1' and temp(63)='1') then
		overflow <= '1';
	elsif(in0(63)='1' and in1(63)='0' and temp(63)='0') then
		overflow <= '1';
	else
		overflow <= '0';
	end if;

elsif operation = "0010" then
	result <= in0 + in1;
	temp <= ('0' & in0) + ('0' & in1);
    	if temp="00000000000000000000000000000000000000000000000000000000000000000" then
    		zero <= '1' ;
    	else
    		zero <= '0' ;
	end if;

	if(in0(63)='1' and in1(63)='1' and temp(63)='0') then
		overflow <= '1';
	elsif(in0(63)='0' and in1(63)='0' and temp(63)='1') then
		overflow <= '1';
	else
		overflow <= '0';
	end if;
else
	overflow <= '0';
end if;


end process vv;
end Behavior;
