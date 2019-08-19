library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity Graphics_buffer is
port (
 
data_in  : in std_logic_vector(7 downto 0);
address  : in std_logic_vector(7 downto 0);
clk,display_clk, en , we: in std_logic;
PDO : out  std_logic_vector(7 downto 0);
hs, vs : out std_logic
);
end Graphics_buffer;

architecture Behavioral of Graphics_buffer is
type graphics_buffer is array(0 to 16383) of  std_logic_vector(7 downto 0);
signal pixel_data : graphics_buffer;

signal regR, regG:  std_logic_vector(2 downto 0);
signal  regB :  std_logic_vector(1 downto 0);

signal pixel_location, pointer: integer range 0 to 16383;
signal X_loc, Y_loc : integer range 0 to 127;

signal clk_25 : std_logic:='0';
signal H_cnt  : integer RANGE 0 TO 800 := 0; 
signal  x  : integer RANGE 0 TO 800 := 0; 
signal  y : integer RANGE 0 TO 127:= 0; 
signal  V_cnt : integer RANGE 0 TO 600 := 0; 
begin
--r_debug<= regR;
process(clk,en)
--variable x_start ,y_start : integer range 0 to 255;
begin
if falling_edge(clk) then
if en = '1' then
if address  = "11111111" then 
regR<= data_in(7 downto 5);
regG<= data_in(4 downto 2);
regB<= data_in(1 downto 0);


elsif address = "11111101" then x_loc <= conv_integer(data_in);
elsif address = "11111110" then y_loc <= conv_integer(data_in);

end if;
end if;
end if;


end process;

process(clk, we, en)
begin
if en = '1' then
	if we = '1' then
	if falling_edge(clk) then
	pixel_location <= 128*X_loc + y_loc;
	end if;
	end if;
	end if;
if rising_edge(clk) then
	pixel_data(pixel_location) <= regR & regG & regB;
	end if;
end process;

process(display_clk)
begin
if rising_edge(display_clk) then
			clk_25 <= not clk_25;
			end if;
end process;


process(clk_25)
begin
if rising_edge(clk_25) then
		h_cnt <= h_cnt + 1;
		if h_cnt = 800 then
				h_cnt <= 0;
				V_cnt <= v_cnt + 1;
				end if;
				
		if v_cnt = 521 then v_cnt <= 0;
		end if;
		
		x <= h_cnt - 143;
		y <= v_cnt - 31;
		
		if h_cnt < 96 then HS <= '0';
		else HS <= '1';
		end if;
		
		if v_cnt < 2 then vs <= '0'; 
		else vs <= '1' ;
		end if;

			pointer <= 128*y + x;
			PDO <= pixel_data(pointer);
	end if;
end process;
end Behavioral;
