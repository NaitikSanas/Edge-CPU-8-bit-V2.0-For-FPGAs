
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:44:14 07/26/2019 
-- Design Name: 
-- Module Name:    clock_divider - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_divider is
port (clk : in std_logic;
		clk_out, display_clk, UART_CLK : out std_logic := '0');
end clock_divider;

architecture Behavioral of clock_divider is
signal count, cnt : integer range 0 to 1000000;
signal dclk,clk_outx, temp0, temp1,temp2 : std_logic;

begin
UART_CLK <= TEMP1;
display_Clk <= dclk;
process(clk)
begin

if rising_edge(clk) then
if count = 10000 then
count <= 0;
else count <= count + 1;
end if;

if count > 0 and count < 10000 then  CLK_OUT <= '1'; else clk_out <= '0';
end if;

dclk <= not dclk;  --50 MHz

end if;

end process;

MHz25:PROCESS(DCLK)
BEGIN
IF RISING_EDGE(DCLK) THEN

TEMP0 <= NOT TEMP0;

END IF;
END PROCESS;

MHz125 : PROCESS(TEMP0)
BEGIN
IF RISING_EDGE(TEMP0) THEN
TEMP1<= NOT TEMP1;
END IF; 
END PROCESS;
end Behavioral;

