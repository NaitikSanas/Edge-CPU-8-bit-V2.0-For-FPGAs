library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.std_logic_arith.all;


entity ALU_INT8 is
PORT(
	  DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	  DATA_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	  status, statusAB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	  FUNCTION_SEL : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	  CLK, IOEN, AB, WR, EXE, LACC, rst_cnt : IN STD_LOGIC;
	  rdy : out std_logic

);
end ALU_INT8;

architecture Behavioral of ALU_INT8 is

SIGNAL ACC, A, B , Cnt:  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL X : INTEGER RANGE  0 TO 255;
SIGNAL Y : INTEGER RANGE  0 TO 255;

begin
X <= CONV_INTEGER(A);
Y <= CONV_INTEGER(ACC);

--WITH WR SELECT DATA_OUT <= ACC WHEN '0',   "00000000" WHEN others;
data_out <= acc;
PROCESS(CLK, IOEN, AB, WR, EXE, LACC)
BEGIN
IF RISING_EDGE(CLK) THEN
-----------DATA IO LOGIC
IF IOEN = '1' THEN
	IF WR = '1' THEN --WRITE
			IF AB = '0' AND LACC = '0' THEN A <= DATA_IN; --LOAD REG 
			ELSIF AB = '1' AND LACC = '0' THEN B <= DATA_IN; -- LOAD REG B
				ELSIF AB = '0' AND LACC = '1' THEN ACC <= DATA_IN; --LOAD ACCUMULATOR	
			END IF;
	END IF;
      
END IF;
if rst_cnt = '1' then cnt <= "00000000"; end if;
----------DATA PROCESSING LOGIC
if EXE = '1' then
		if    function_sel = "0000" then ACC<= A + ACC;
		elsif function_sel = "0001" then ACC <= a - ACC; 
		elsif function_sel = "0010" then ACC <= conv_std_logic_vector (x/y, 8); 
		elsif function_sel = "0011" then ACC <= a AND ACC; 
		elsif function_sel = "0100" then ACC <= a NAND ACC;
		elsif function_sel = "0101" then ACC <= a or ACC; 
		elsif function_sel = "0110" then ACC <= a XOR ACC; 
		elsif function_sel = "0111" then ACC <= not ACC; 
		elsif function_sel = "1000" then 
					if cnt = b then 
						 rdy <= '1';
						 else cnt <= cnt + "00000001";
								acc <= acc + a;
								rdy <= '0';
								end if;
	ELSIF FUNCTION_SEL = "1001" THEN ACC <= A + B;
	 	ELSIF FUNCTION_SEL = "1010" THEN ACC <= A - B;
	ELSIF FUNCTION_SEL = "1011" THEN ACC <= A AND B;
	elsif function_sel = "1100" then acc <= acc + "00000001";
	elsif function_sel = "1101" then acc <= acc  - "00000001";
	elsif function_sel = "1110" then a <= a + "00000001";
	elsif function_sel = "1111" then a <= a - "00000001";
						 
	 end if;
		
END IF;

end if;
if falling_edge(clk) then
if acc > b then status <= "10";
elsif  b > acc then status <= "01";
elsif b = acc then status <= "11";
end if;

if a > b then statusAB  <= "10";
elsif b > a then statusAB <= "01";
elsif a = b then statusAB  <= "11";
end if;

end if;

END PROCESS;

end Behavioral;

