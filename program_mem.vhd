library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Program_mem is
port (
address: in std_logic_vector(3 downto 0);
data_out : out std_logic_vector(7 downto 0)
);
end Program_mem;

architecture Behavioral of Program_mem is
type program  is array(0 to 15) of std_logic_vector(7 downto 0);
constant nop : std_logic_vector(7 downto 0):= "00000000";
--------------------moving    data  ----------------
constant move_PRG_mem_acc : std_logic_vector(7 downto 0):= "00011101";
constant move_acc_dmem : std_logic_vector(7 downto 0):= "00001010";
constant move_dmem_acc : std_logic_vector(7 downto 0):= "00000001";
constant move_acc_iop_b : std_logic_vector(7 downto 0):= "00001100";
constant move_prg_mem_regB : std_logic_vector(7 downto 0):= "00100010";
constant move_prg_mem_rega : std_logic_vector(7 downto 0):=  "00100101";

------------------operations on data-----------------
constant inc_acc : std_logic_vector(7 downto 0):= "00011010";
constant alu_div : std_logic_vector(7 downto 0):= "00010011";
constant alu_add_AccA : std_logic_vector(7 downto 0):=  "00010001";
constant alu_NOT_ACC : std_logic_vector(7 downto 0):= "00011000";
constant alu_inc_regA : std_logic_vector(7 downto 0):= "00101011";
-----------------controlling flow of program-------
constant CMP_ACCeqB: std_logic_vector(7 downto 0):= "00100001";
constant goto : std_logic_vector(7 downto 0):= "00011111";
constant goto_begin: std_logic_vector(7 downto 0):= "00011100";
constant  for_i : std_logic_vector(7 downto 0):=  "00101010" ;

---------blocking siganls --------------------
constant block_iop: std_logic_vector(7 downto 0):= "00001110";
constant block_alu: std_logic_vector(7 downto 0):= "00001111";

--------------data pointers and RAM operations----------
constant inc_dptr : std_logic_vector(7 downto 0):=  "00100111";
constant dec_dptr : std_logic_vector(7 downto 0):=  "00101000";
constant push_data : std_logic_vector(7 downto 0):=  "00001101";
constant pop_data : std_logic_vector(7 downto 0):= "00101001";


constant pixel_data : std_logic_vector(7 downto 0):= "00101100";
constant location_x: std_logic_vector(7 downto 0):= "00101101";
constant location_y: std_logic_vector(7 downto 0):= "00101110";
constant jump: std_logic_vector(7 downto 0):= "00101111";

------------UART operations---------------
constant TX_Data : std_logic_vector(7 downto 0):= "00110000"; 
constant RX_Data : std_logic_vector(7 downto 0):= "00110001"; 

constant instruction_set : program := (
--transmit data
move_prg_mem_acc, "01100001",
block_alu,
TX_data,
--recieve data loop
RX_data,
move_acc_IOP_b,
block_iop,
goto, "00000100",
------------empty sector----------

nop,
nop,
nop,
nop,
nop,
nop,
nop
);

begin
process(address)
begin
data_out <= instruction_set( conv_integer(address));
end process;
end Behavioral;