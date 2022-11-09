library ieee;
use ieee.std_logic_1164.all;


entity CPUControl is
-- Functionality should match the truth table shown in Figure 4.22 of the textbook, inlcuding the
--    output 'X' values.
-- The truth table in Figure 4.22 omits the unconditional branch instruction:
--    UBranch = '1'
--    MemWrite = RegWrite = '0'
--    all other outputs = 'X'	
port(Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
     RegDst   : out STD_LOGIC;
     CBranch  : out STD_LOGIC;  --conditional
     MemRead  : out STD_LOGIC;
     MemtoReg : out STD_LOGIC;
     MemWrite : out STD_LOGIC;
     ALUSrc   : out STD_LOGIC;
     RegWrite : out STD_LOGIC;
     UBranch  : out STD_LOGIC; -- This is unconditional
     ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
);
end CPUControl;


architecture Behavior of CPUControl is

begin


-- declarative part: empty
vv : process(Opcode)
begin



if    Opcode(10 downto 5) = "000101" then  --B format
UBranch <='1';
RegDst  <='0';
ALUSrc  <='0';
MemtoReg<='0';
RegWrite<='0';
MemRead <='0';
MemWrite<='0';
CBranch <='0';
ALUOp(1)<='0';
ALUOp(0)<='0';

elsif Opcode(10 downto 3) = "10110100" then  --CBZ
UBranch <='0';
RegDst  <='1';
ALUSrc  <='0';
MemtoReg<='0';
RegWrite<='0';
MemRead <='0';
MemWrite<='0';
CBranch <='1';
ALUOp(1)<='0';
ALUOp(0)<='0';

elsif    Opcode(10 downto 1) = "1001000100" or Opcode(10 downto 1) = "1101000100" then  --ADDI, SUBI works
UBranch <='0';
RegDst  <='0';
ALUSrc  <='1';
MemtoReg<='0';
RegWrite<='1';
MemRead <='0';
MemWrite<='0';
CBranch <='0';
ALUOp(1)<='1';
ALUOp(0)<='0';


elsif    Opcode(10 downto 0) = "10101010000" or Opcode(10 downto 0) = "10001010000" or Opcode(10 downto 0) = "10001011000" or Opcode(10 downto 0) = "11001011000" then  --ADD,SUB, ORR ,AND works 
UBranch <='0';
RegDst  <='0';
ALUSrc  <='0';
MemtoReg<='0';
RegWrite<='1';
MemRead <='0';
MemWrite<='0';
CBranch <='0';
ALUOp(1)<='1';
ALUOp(0)<='0';

elsif    Opcode(10 downto 0) = "11111000000" then  -- STUR works 
UBranch <='0';
RegDst  <='1';
ALUSrc  <='1';
MemtoReg<='0';
RegWrite<='0';
MemRead <='0';
MemWrite<='1';
CBranch <='0';
ALUOp(1)<='0';
ALUOp(0)<='0';

elsif    Opcode(10 downto 0) = "11111000010" then  -- LDUR works 
UBranch <='0';
RegDst  <='0';
ALUSrc  <='1';
MemtoReg<='1';
RegWrite<='1';
MemRead <='1';
MemWrite<='0';
CBranch <='0';
ALUOp(1)<='0';
ALUOp(0)<='0';

else
UBranch <='0';
RegDst  <='0';
ALUSrc  <='0';
MemtoReg<='0';
RegWrite<='0';
MemRead <='0';
MemWrite<='0';
CBranch <='0';
ALUOp(1)<='0';
ALUOp(0)<='0';
end if;

end process vv;
end Behavior;