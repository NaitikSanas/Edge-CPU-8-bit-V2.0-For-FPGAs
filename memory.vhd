library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity Memory is
port (
	DI : IN std_logic_vector(7 downto 0);
	DO : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
   address	: in std_logic_vector(7 downto 0);
	clk, WR, E:  in std_logic
);
end Memory;

architecture Behavioral of Memory is
type data_mem is array(0 to 255) of std_logic_vector(7 downto 0 );
signal data : data_mem;
signal ptr : integer range 0 to 255;
begin

ptr <= conv_integer(address);

Write_read_data : process(clk, wr, e)
begin 
if e = '1' then
if WR = '1' then
	
if falling_edge(clk) then
      data(ptr) <= di;
		END IF;
		
end if;
end if;
end  process;

read_data : process(clk,wr, e)
begin
if e = '1' then
if wr = '0' then
if rising_edge(clk) then
			do <= data(ptr);
end if;
end if;
end if;		

end process;

end Behavioral;

