library ieee;
use ieee.std_logic_1164.all;
--provide ee126 lab4 add.vhd dmem.vhd MUX5.vhd alucontrol.vhd EX_MEM_REG.vhd MUX64.vhd alu.vhd ID_EX_REG.vhd newCPU.vhd registers.vhd AND2.vhd IF_ID_REG.vhd PC.vhd ShiftLeft2.vhd cpucontrol.vhd imem.vhd PipelinedCPU0_tb.vhd SignExtend.vhd dmem_le.vhd MEM_WB_REG.vhd PipelinedCPU0.vhd ee126 README Lab_Report#4.pdf

entity PipelinedCPU0 is
port(
clk : in STD_LOGIC;
rst : in STD_LOGIC;
--Probe ports used for testing
--The current address (AddressOut from the PC)
DEBUG_PC : out STD_LOGIC_VECTOR(63 downto 0);
--The current instruction (Instruction output of IMEM)
DEBUG_INSTRUCTION : out STD_LOGIC_VECTOR(31 downto 0);
--DEBUG ports from other components
DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end PipelinedCPU0;

architecture behavioral of PipelinedCPU0 is
  --signal clk : STD_LOGIC:='0';
  --signal rst : STD_LOGIC:='1';

signal ALUControl_ALUOp     :   STD_LOGIC_VECTOR(1 downto 0);
signal ALUControl_Opcode    :   STD_LOGIC_VECTOR(10 downto 0);
signal ALUControl_Operation :  STD_LOGIC_VECTOR(3 downto 0);

signal ALU_in0       :      STD_LOGIC_VECTOR(63 downto 0);
signal ALU_in1       :      STD_LOGIC_VECTOR(63 downto 0);
signal ALU_operation :      STD_LOGIC_VECTOR(3 downto 0);
signal ALU_result    :  STD_LOGIC_VECTOR(63 downto 0);
signal ALU_zero      :  STD_LOGIC;
signal ALU_overflow  :  STD_LOGIC;

signal ADD_in0 :  STD_LOGIC_VECTOR(63 downto 0);
signal ADD_in1 :  STD_LOGIC_VECTOR(63 downto 0);
signal ADD_output : STD_LOGIC_VECTOR(63 downto 0);

signal ADDB_in0 :  STD_LOGIC_VECTOR(63 downto 0);
signal ADDB_in1 :  STD_LOGIC_VECTOR(63 downto 0);
signal ADDB_output : STD_LOGIC_VECTOR(63 downto 0);

signal DMEM_WriteData : STD_LOGIC_VECTOR(63 downto 0);
signal DMEM_Address : STD_LOGIC_VECTOR(63 downto 0);
signal DMEM_MemRead  : STD_LOGIC;
signal DMEM_MemWrite  : STD_LOGIC;
signal DMEM_Clock  : STD_LOGIC;
signal DMEM_ReadData  : STD_LOGIC_VECTOR(63 downto 0);
signal DMEM_DEBUG_MEM_CONTENTS  : STD_LOGIC_VECTOR(255 downto 0);

signal IMEM_Address : STD_LOGIC_VECTOR(63 downto 0);
signal IMEM_ReadData : STD_LOGIC_VECTOR(31 downto 0);

signal MUX64_in0: STD_LOGIC_VECTOR(63 downto 0);
signal MUX64_in1: STD_LOGIC_VECTOR(63 downto 0);
signal MUX64_sel: std_logic;
signal MUX64_output: std_logic_vector(63 downto 0);

signal MUXB64_in0: STD_LOGIC_VECTOR(63 downto 0);
signal MUXB64_in1: STD_LOGIC_VECTOR(63 downto 0);
signal MUXB64_sel: std_logic;
signal MUXB64_output: std_logic_vector(63 downto 0);

signal MUXC64_in0: STD_LOGIC_VECTOR(63 downto 0);
signal MUXC64_in1: STD_LOGIC_VECTOR(63 downto 0);
signal MUXC64_sel: std_logic;
signal MUXC64_output: std_logic_vector(63 downto 0);


signal MUX5_in0: STD_LOGIC_VECTOR(4 downto 0);
signal MUX5_in1: STD_LOGIC_VECTOR(4 downto 0);
signal MUX5_sel: std_logic;
signal MUX5_output: std_logic_vector(4 downto 0);

signal PC_clk 		 	 : STD_LOGIC:='0';
signal PC_write_enable  : STD_LOGIC:='0';
signal PC_rst 		 	 : STD_LOGIC:='0';
signal PC_AddressIn 	 : STD_LOGIC_VECTOR(63 downto 0):=x"0000000000000000";
signal PC_AddressOut 	 : STD_LOGIC_VECTOR(63 downto 0):=x"0000000000000000";

signal ShiftLeft2_x : STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
signal ShiftLeft2_y : STD_LOGIC_VECTOR(63 downto 0); -- sel == 1

signal SignExtend_x: STD_LOGIC_VECTOR(31 downto 0);
signal SignExtend_y: STD_LOGIC_VECTOR(63 downto 0);

--signal AND2_in0 :  STD_LOGIC; -- sel == 0
--signal AND2_in1 :  STD_LOGIC; -- sel == 1
--signal AND2_output : STD_LOGIC;

signal    REGISTERS_RR1      :  STD_LOGIC_VECTOR (4 downto 0); 
 signal    REGISTERS_RR2      :  STD_LOGIC_VECTOR (4 downto 0); 
 signal    REGISTERS_WR       :  STD_LOGIC_VECTOR (4 downto 0); 
 signal    REGISTERS_WD       :  STD_LOGIC_VECTOR (63 downto 0);
 signal    REGISTERS_RegWrite :  STD_LOGIC;
 signal    REGISTERS_Clock    :  STD_LOGIC;
 signal    REGISTERS_RD1      :  STD_LOGIC_VECTOR (63 downto 0);
 signal    REGISTERS_RD2      : STD_LOGIC_VECTOR (63 downto 0);
 signal    REGISTERS_DEBUG_TMP_REGS :  STD_LOGIC_VECTOR(64*4 - 1 downto 0);
 signal    REGISTERS_DEBUG_SAVED_REGS : STD_LOGIC_VECTOR(64*4 - 1 downto 0);

signal CPUControl_Opcode   :  STD_LOGIC_VECTOR(10 downto 0):="00000000000";
signal CPUControl_RegDst   :  STD_LOGIC:='0';
signal CPUControl_CBranch  :  STD_LOGIC:='0';  --conditional
signal CPUControl_MemRead  :  STD_LOGIC:='0';
signal CPUControl_MemtoReg :  STD_LOGIC:='0';
signal CPUControl_MemWrite :  STD_LOGIC:='0';
signal CPUControl_ALUSrc   :  STD_LOGIC:='0';
signal CPUControl_RegWrite :  STD_LOGIC:='0';
signal CPUControl_UBranch  :  STD_LOGIC:='0'; -- This is unconditional
signal CPUControl_ALUOp    :  STD_LOGIC_VECTOR(1 downto 0):="00";

--pipeline register signals
 
 signal pipelineRead : STD_LOGIC := '0';
 signal pipelineWrite: STD_LOGIC := '0';
 signal pipelineClk			 : STD_LOGIC := '0';
 
 --signal IF_ID_REG_ALUop_in: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
 --signal IF_ID_REG_ALUop_out: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
 --signal IF_ID_REG_Control_in: STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
 --signal IF_ID_REG_Control_out: STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
 signal IF_ID_REG_A_in: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal IF_ID_REG_A_out: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal IF_ID_REG_B_in: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
 signal IF_ID_REG_B_out: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
 
 signal ID_EX_REG_Control_in: STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
 signal ID_EX_REG_Control_out: STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
 signal ID_EX_REG_ALUop_in : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
 signal ID_EX_REG_ALUop_out: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
 signal ID_EX_REG_A_in: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal ID_EX_REG_A_out: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal ID_EX_REG_B_in: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal ID_EX_REG_B_out: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal ID_EX_REG_C_in: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal ID_EX_REG_C_out: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal ID_EX_REG_D_in: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal ID_EX_REG_D_out: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal ID_EX_REG_E_in: STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
 signal ID_EX_REG_E_out: STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
 signal ID_EX_REG_F_in: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
 signal ID_EX_REG_F_out : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
 
 signal EX_MEM_REG_Control_in: STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
 signal EX_MEM_REG_Control_out: STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
 signal EX_MEM_REG_A_in: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal EX_MEM_REG_A_out: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal EX_MEM_REG_B_in: STD_LOGIC := '0';
 signal EX_MEM_REG_B_out: STD_LOGIC:= '0';
 signal EX_MEM_REG_C_in: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal EX_MEM_REG_C_out: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal EX_MEM_REG_D_in: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal EX_MEM_REG_D_out: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal EX_MEM_REG_E_in: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
 signal EX_MEM_REG_E_out: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
 
 signal MEM_WB_REG_Control_in: STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
 signal MEM_WB_REG_Control_out: STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
 signal MEM_WB_REG_A_in: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal MEM_WB_REG_A_out: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal MEM_WB_REG_B_in: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal MEM_WB_REG_B_out: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 signal MEM_WB_REG_C_in: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
 signal MEM_WB_REG_C_out: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
  

begin
ALUControl: entity work.ALUControl PORT MAP(ALUControl_ALUOp,ALUControl_Opcode,ALUControl_Operation);
CPUControl: entity work.CPUControl PORT MAP(CPUControl_Opcode,CPUControl_RegDst,CPUControl_CBranch,CPUControl_MemRead,CPUControl_MemtoReg,CPUControl_MemWrite,CPUControl_ALUSrc,CPUControl_RegWrite,CPUControl_UBranch,CPUControl_ALUOp);
ALU: entity work.ALU PORT MAP(ALU_in0,ALU_in1,ALU_operation,ALU_result,ALU_zero,ALU_overflow);
ADD: entity work.ADD PORT MAP(ADD_in0,ADD_in1,ADD_output);
ADDB: entity work.ADD PORT MAP(ADDB_in0,ADDB_in1,ADDB_output);

DMEM: entity work.DMEM PORT MAP(DMEM_WriteData, DMEM_Address, DMEM_MemRead, DMEM_MemWrite, DMEM_Clock, DMEM_ReadData, DMEM_DEBUG_MEM_CONTENTS);
IMEM: entity work.IMEM PORT MAP(IMEM_Address, IF_ID_REG_B_in); -- IMEM_ReadData removed
MUX64: entity work.MUX64 PORT MAP(MUX64_in0, MUX64_in1, MUX64_sel, MUX64_output);
MUXB64: entity work.MUX64 PORT MAP(MUXB64_in0, MUXB64_in1, MUXB64_sel, MUXB64_output);
MUXC64: entity work.MUX64 PORT MAP(MUXC64_in0, MUXC64_in1, MUXC64_sel, MUXC64_output);

MUX5: entity work.MUX5 PORT MAP(MUX5_in0, MUX5_in1, MUX5_sel, MUX5_output);
PC: entity work.PC PORT MAP(PC_clk, PC_write_enable, PC_rst, PC_AddressIn, PC_AddressOut);
SHIFTLEFT2: entity work.ShiftLeft2 PORT MAP(ShiftLeft2_x,ShiftLeft2_y);
SIGNEXTEND: entity work.SignExtend PORT MAP(SignExtend_x,SignExtend_y);
--AND2: entity work.AND2 PORT MAP(AND2_in0,AND2_in1,AND2_output);
REGISTERS: entity work.REGISTERS PORT MAP(REGISTERS_RR1,REGISTERS_RR2,REGISTERS_WR,REGISTERS_WD,REGISTERS_RegWrite,REGISTERS_Clock,REGISTERS_RD1,REGISTERS_RD2,REGISTERS_DEBUG_TMP_REGS,REGISTERS_DEBUG_SAVED_REGS);

--IF_ID_REG_Control_in <= ;
IF_ID_REG_A_in <= PC_AddressOut;
--IF_ID_REG_B_in <= IMEM_ReadData;
IF_ID_REG:  entity work.IF_ID_REG  PORT MAP(pipelineRead,pipelineWrite, pipelineClk,IF_ID_REG_A_in,IF_ID_REG_A_out,IF_ID_REG_B_in,IF_ID_REG_B_out);
IMEM_ReadData <= IF_ID_REG_B_out;
--IF_ID_REG_Control_out
--IF_ID_REG_A_out <= ;**
--IF_ID_REG_B_out <= ;
--IMEM_ReadData <= IF_ID_REG_B_out;

ID_EX_REG_Control_in(0) <= CPUControl_RegDst;
ID_EX_REG_Control_in(1) <= CPUControl_UBranch;
ID_EX_REG_Control_in(2) <= CPUControl_CBranch;
ID_EX_REG_Control_in(3) <= CPUControl_MemRead;
ID_EX_REG_Control_in(4) <= CPUControl_MemtoReg;
ID_EX_REG_ALUop_in <= CPUControl_ALUOp;
--ID_EX_REG_Control_in(5) <= CPUControl_ALUOp;
ID_EX_REG_Control_in(6) <= CPUControl_MemWrite;
ID_EX_REG_Control_in(7) <= CPUControl_ALUSrc;
ID_EX_REG_Control_in(8) <= CPUControl_RegWrite;
ID_EX_REG_A_in <= IF_ID_REG_A_out;
ID_EX_REG_B_in <= REGISTERS_RD1;
ID_EX_REG_C_in <= REGISTERS_RD2;
ID_EX_REG_D_in <= SignExtend_y;
ID_EX_REG_E_in <= IMEM_ReadData(31 downto 21);
ID_EX_REG_F_in <= IMEM_ReadData(4 downto 0);
ID_EX_REG:  entity work.ID_EX_REG  PORT MAP(pipelineRead,pipelineWrite, pipelineClk,ID_EX_REG_ALUop_in,ID_EX_REG_ALUop_out,ID_EX_REG_Control_in,ID_EX_REG_Control_out,ID_EX_REG_A_in,ID_EX_REG_A_out,ID_EX_REG_B_in,ID_EX_REG_B_out,ID_EX_REG_C_in,ID_EX_REG_C_out,ID_EX_REG_D_in,ID_EX_REG_D_out,ID_EX_REG_E_in,ID_EX_REG_E_out,ID_EX_REG_F_in,ID_EX_REG_F_out);
--ID_EX_REG_ALUop_in
--ID_EX_REG_Control_out
--ID_EX_REG_A_out <= ;**
--ID_EX_REG_B_out <= ;**
--ID_EX_REG_C_out <= ;
--ID_EX_REG_D_out <= ;**
--ID_EX_REG_E_out <= ;
--ID_EX_REG_F_out <= ;**
--ID_EX_REG_G_out <= ;**
--ID_EX_REG_H_out <= ;**
--ID_EX_REG_J_out <= ;

EX_MEM_REG_Control_in <= ID_EX_REG_Control_out;
EX_MEM_REG_A_in <= ADDB_output;
EX_MEM_REG_B_in <= ALU_zero;
EX_MEM_REG_C_in <= ALU_result;
EX_MEM_REG_D_in <= ID_EX_REG_C_out;
EX_MEM_REG_E_in <= ID_EX_REG_F_out;
EX_MEM_REG: entity work.EX_MEM_REG PORT MAP(pipelineRead,pipelineWrite, pipelineClk,EX_MEM_REG_Control_in,EX_MEM_REG_Control_out,EX_MEM_REG_A_in,EX_MEM_REG_A_out,EX_MEM_REG_B_in,EX_MEM_REG_B_out,EX_MEM_REG_C_in,EX_MEM_REG_C_out,EX_MEM_REG_D_in,EX_MEM_REG_D_out,EX_MEM_REG_E_in,EX_MEM_REG_E_out);
--EX_MEM_REG_Control_out
--EX_MEM_REG_A_out <= ;**
--EX_MEM_REG_B_out <= ;
--EX_MEM_REG_C_out <= ;
--EX_MEM_REG_D_out <= ;
--EX_MEM_REG_E_out <= ;**
--EX_MEM_REG_F_out <= ;
--EX_MEM_REG_G_out <= ;**

MEM_WB_REG_Control_in <= EX_MEM_REG_Control_out;
MEM_WB_REG_A_in <= DMEM_ReadData;
MEM_WB_REG_B_in <= EX_MEM_REG_C_out;
MEM_WB_REG_C_in <= EX_MEM_REG_E_out;
MEM_WB_REG: entity work.MEM_WB_REG PORT MAP(pipelineRead,pipelineWrite, pipelineClk,MEM_WB_REG_Control_in,MEM_WB_REG_Control_out,MEM_WB_REG_A_in, MEM_WB_REG_A_out,MEM_WB_REG_B_in,MEM_WB_REG_B_out,MEM_WB_REG_C_in,MEM_WB_REG_C_out);
--MEM_WB_REG_Control_out;
--MEM_WB_REG_A_out <= ;
--MEM_WB_REG_B_out <= ;
--MEM_WB_REG_C_out <= ;
--MEM_WB_REG_D_out <= ;




DMEM_Clock <= clk;
CPUControl_Opcode <= IMEM_ReadData(31 downto 21);
IMEM_Address  <= PC_AddressOut;


MUX5_in0 <= IMEM_ReadData(20 downto 16);
MUX5_in1 <= IMEM_ReadData(4 downto 0);
MUX5_sel <= IMEM_ReadData(28);--CPUControl_RegDst;

REGISTERS_RR1 <= IMEM_ReadData(9 downto 5);
REGISTERS_RR2 <= MUX5_output;
REGISTERS_WR <= MEM_WB_REG_C_out;
REGISTERS_WD <= MUXB64_output;

REGISTERS_RegWrite <= MEM_WB_REG_Control_out(8);--CPUControl_RegWrite;
REGISTERS_Clock <= clk;


SignExtend_x <= IMEM_ReadData(31 downto 0);


ALUControl_ALUOp <= ID_EX_REG_ALUop_out;
ALUControl_Opcode <= ID_EX_REG_E_out;


MUX64_in0 <= ID_EX_REG_C_out;--REGISTERS_RD2;
MUX64_in1 <= ID_EX_REG_D_out;--SignExtend_y;
MUX64_sel <= ID_EX_REG_Control_out(7);


ALU_in0 <= ID_EX_REG_B_out;
ALU_in1 <= MUX64_output;
ALU_operation <= ALUControl_Operation;

--ALU_overflow

DMEM_WriteData <= EX_MEM_REG_D_out;
DMEM_Address <= EX_MEM_REG_C_out;
DMEM_MemRead <= EX_MEM_REG_Control_out(3);-- CPUControl_MemRead;
DMEM_MemWrite <= EX_MEM_REG_Control_out(6);-- CPUControl_MemWrite;
DMEM_Clock <= clk;

MUXB64_in0 <= MEM_WB_REG_B_out;
MUXB64_in1 <= MEM_WB_REG_A_out;
MUXB64_sel <= MEM_WB_REG_Control_out(4);-- CPUControl_MemtoReg;

ADD_in0 <= PC_AddressOut;
ADD_in1 <= x"0000000000000004";


PC_clk <= clk;
PC_write_enable  <= '1';
PC_rst <= rst;
PC_AddressIn <= MUXC64_output;

MUXC64_in0 <= ADD_output;
MUXC64_in1 <= EX_MEM_REG_A_out;
MUXC64_sel <= EX_MEM_REG_B_out and EX_MEM_REG_Control_out(2); 
--CPUControl_UBranch or (ALU_zero and CPUControl_CBranch);

ADDB_in0 <= ID_EX_REG_A_out;
ADDB_in1 <= ShiftLeft2_y;


ShiftLeft2_x <= ID_EX_REG_D_out;--SignExtend_y;

DEBUG_INSTRUCTION <= IMEM_ReadData;
DEBUG_PC <= PC_AddressOut;



--DEBUG ports from other components
--DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
--DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
--DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)

DEBUG_TMP_REGS <= REGISTERS_DEBUG_TMP_REGS;
DEBUG_SAVED_REGS <= REGISTERS_DEBUG_SAVED_REGS;
DEBUG_MEM_CONTENTS <= DMEM_DEBUG_MEM_CONTENTS;

pipelineRead <= '1';
pipelineWrite  <= '1';--clk;
pipelineClk <= clk;

--	process
--	begin
--		clk <= not clk;
--		wait for 10 ns;
--	end process;--

--	process
--	begin
--		wait for 1 ns;
--		rst <= '0';
--		wait for 1000 ns;
--		
--	end process;

end behavioral;










