
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:42:01 07/19/2019 
-- Design Name: 
-- Module Name:    mux - Behavioral 
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

entity mux is
port (
a : in std_logic_vector(7 downto 0);
b : in std_logic_vector(7 downto 0);
c : in std_logic_vector(7 downto 0);
d : in std_logic_vector(7 downto 0);

sel: in std_logic_vector(1 downto 0);
y : out std_logic_vector(7 downto 0)
);
end mux;

architecture Behavioral of mux is

begin
with sel select y <= a when "00", b when "01", c when "10" , d when "11" ;
end Behavioral;

