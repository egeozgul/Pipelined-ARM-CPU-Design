library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- STD_LOGIC and STD_LOGIC_VECTOR
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity ID_EX_REG is
port(
	 readEnable         : in  STD_LOGIC:='0';
     writeEnable        : in  STD_LOGIC:='0';
     clk        		: in  STD_LOGIC:='0';
	 
	 ALUop_in         : in  STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
     ALUop_out        : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
	 
	 Control_in     : in  STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
     Control_out    : out STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
	 
	 A_in     : in  STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
     A_out    : out STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
	 
	 B_in     : in  STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
     B_out    : out STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
	 
	 C_in     : in  STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
     C_out    : out STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
	 
	 D_in     : in  STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
     D_out    : out STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
	 
	 E_in     : in  STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
     E_out    : out STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
	 
	 F_in     : in  STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
     F_out    : out STD_LOGIC_VECTOR(4 downto 0)
);
end ID_EX_REG;

architecture behavioral of ID_EX_REG is
signal Control_mem : STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
signal A_mem    : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal B_mem    : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal C_mem    : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal D_mem    : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal E_mem    : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
signal F_mem    : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

signal ALUop_mem    : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
	 
begin
   process(readEnable,writeEnable,clk)
   variable first:boolean := true;
   begin
      
	if(first) then
		 Control_mem <= (others => '0');
        
		 A_mem <= (others => '0');
		 B_mem <= (others => '0');
		 C_mem <= (others => '0');
		 D_mem <= (others => '0');
		 E_mem <= (others => '0');
		 F_mem <= (others => '0');
		 
		 ALUop_mem <= (others => '0');
		 
         first := false;
    end if;
    
	if readEnable='1' then  -- Read on the rising edge of the clock
		--read
		Control_out <= Control_mem;
		ALUop_out <= ALUop_mem;
		A_out <= A_mem;
		B_out <= B_mem;
		C_out <= C_mem;
		D_out <= D_mem;
		E_out <= E_mem;
		F_out <= F_mem;
		
	end if;
	
	if writeEnable='1' then  -- Write on the rising edge of the clock
		--write
		Control_mem <= Control_in;
		ALUop_mem<= ALUop_in;
		A_mem <= A_in;
		B_mem <= B_in;
		C_mem <= C_in;
		D_mem <= D_in;
		E_mem <= E_in;
		F_mem <= F_in;
		
	end if;
	
   end process;
end behavioral;
