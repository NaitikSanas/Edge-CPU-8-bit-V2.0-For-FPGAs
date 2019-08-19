library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity IO_PORT is
PORT ( 
	PORT_A : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0); --PHYSICAL PORT
	PORT_B : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0); --PHYSICAL PORT
	
   DI : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
	DO : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	CLK, WR, AB, EN : STD_LOGIC
	
 );
end IO_PORT;

architecture Behavioral of IO_PORT is

begin
PROCESS(CLK,EN)
BEGIN
IF EN = '1' THEN 
	IF RISING_EDGE(CLK) THEN
			
			IF WR = '0' THEN --READ
			
				IF AB = '0' THEN 
					DO <= PORT_A; --READ_PORT A
				ELSIF AB = '1' THEN
					DO <= PORT_B; --READ_PORT B;
				END IF;
				
			ELSIF WR = '1' THEN --WRITE
				IF AB = '0' THEN 
					PORT_A <= DI; --WRITE PORT A
			   ELSIF AB = '1' THEN 
					PORT_B <= DI; --WRITE PORT B
				END IF;
			
			END IF;
	END IF;
END IF;

					
END PROCESS;

end Behavioral;