library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is
-- This component is described in the textbook, starting on section 4.3 
-- The indices of each of the registers can be found on the LEGv8 Green Card
-- Keep in mind that register 0(zero) has a constant value of 0 and cannot be overwritten

-- This should only write on the negative edge of Clock when RegWrite is asserted.
-- Reads should be purely combinatorial, i.e. they don't depend on Clock
-- HINT: Use the provided dmem.vhd as a starting point
port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
     RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
     WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
     WD       : in  STD_LOGIC_VECTOR (63 downto 0);
     RegWrite : in  STD_LOGIC;
     Clock    : in  STD_LOGIC;

     RD1      : out STD_LOGIC_VECTOR (63 downto 0);
     RD2      : out STD_LOGIC_VECTOR (63 downto 0);
     --Probe ports used for testing.
     -- Notice the width of the port means that you are 
     --      reading only part of the register file. 
     -- This is only for debugging
     -- You are debugging a sebset of registers here
     -- Temp registers: $X9 & $X10 & X11 & X12 
     -- 4 refers to number of registers you are debugging
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     -- Saved Registers X19 & $X20 & X21 & X22 
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end registers;

architecture Behavior of registers is
type t_Memory is array (0 to 31) of std_logic_vector(63 downto 0);
signal r_Mem : t_Memory := (others => (others => '0'));
 signal first: STD_LOGIC:= '1';
begin
    
    RD1 <= r_Mem(to_integer(unsigned(RR1)));
    RD2 <= r_Mem(to_integer(unsigned(RR2)));

    process(Clock,RegWrite,WD,WR)
    begin
	if first = '1' then
	r_Mem(9)  <= x"0000000000000010";
	r_Mem(10) <= x"0000000000000008";
	r_Mem(11) <= x"0000000000000002";
	r_Mem(12) <= x"0000000000000008";
	r_Mem(19) <= x"00000000CEA4126C";
	r_Mem(20) <= x"000000001009AC83";
	r_Mem(21) <= x"0000000000000000";
	r_Mem(22) <= x"0000000000000000";
	
	first <= '0';
	end if;	
    

        if falling_edge(Clock) and RegWrite = '1' AND WR /= "11111" then
        r_Mem(to_integer(unsigned(WR))) <= WD;
        end if;

    end process;
    
DEBUG_TMP_REGS <= r_Mem(9) & r_Mem(10) & r_Mem(11) & r_Mem(12); --DMEM(28)
DEBUG_SAVED_REGS <= r_Mem(19) & r_Mem(20) & r_Mem(21) & r_Mem(22); --DMEM(24)

end Behavior;
