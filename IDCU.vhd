LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY IDCU IS
PORT (
Inst_IN : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
CLK, rdy: IN STD_LOGIC;

XALU : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
XIOP : OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
DSS: OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
Status, statusAB:  in  STD_LOGIC_VECTOR(1 DOWNTO 0);

uart_reset, tx_en : out std_logic;

rx_busy, tx_busy, rx_error : in std_logic;

mem_en, mem_wr, gbuffer_we, gbuffer_en: OUT  STD_LOGIC;

 ADDRESS, pcnt, data: OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
fsel : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0)

);
END IDCU;

ARCHITECTURE BEHAVIORAL OF IDCU IS


SIGNAL HOLD_INST : STD_LOGIC;
SIGNAL INSTRUCTION, pcload, jump_pc, address0: STD_LOGIC_VECTOR(7 DOWNTO 0);

--------------------------------REGISTERY CONTROL SETS--------------------------------------------------
---XOP---[WR][AB][EN] IO PORT CONFIGURATION REGISTER
CONSTANT W_PORTA :STD_LOGIC_VECTOR(2 DOWNTO 0):="101"; --WRITE PORT A
CONSTANT W_PORTB :STD_LOGIC_VECTOR(2 DOWNTO 0):= "111";--WRITE PORT B
CONSTANT R_PORTA :STD_LOGIC_VECTOR(2 DOWNTO 0):= "001"; --READ PORT A
CONSTANT R_PORTB : STD_LOGIC_VECTOR(2 DOWNTO 0):="011"; -- READ PORT B  
CONSTANT block_IO : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";-- DISABLE IO PORT

---------------XALU --[RST_CNT][LACC][EXE][WR][AB][IOEN] ALU CONTROL REG
CONSTANT FETCH_A : STD_LOGIC_VECTOR(5 DOWNTO 0):= "000101"; --FETCH VARIABLE AND STORE IN REG A
CONSTANT FETCH_B : STD_LOGIC_VECTOR(5 DOWNTO 0):= "000111"; --FETCH ABD STORE TO REG B
CONSTANT LOAD_ACC: STD_LOGIC_VECTOR(5 DOWNTO 0):= "010101";--LOAD ACCUMULATOR
CONSTANT EXECUTE_FUNCTION : STD_LOGIC_VECTOR(5 DOWNTO 0):= "001000";--EXECUTE FUNCTION ON DATA
CONSTANT RST_CNT : STD_LOGIC_VECTOR(5 DOWNTO 0):= "100000";--RESET ACCUMULATION COUNTER
CONSTANT BLOCK_ALU :  STD_LOGIC_VECTOR(5 DOWNTO 0):="000000"; --BLOCK ALL IO SIGNALS OF ALU
--CONSTANT  :  STD_LOGIC_VECTOR(5 DOWNTO 0):="000001"; --BLOCK ALL IO SIGNALS OF ALU
CONSTANT READ_ALU : STD_LOGIC_VECTOR(5 DOWNTO 0):="000001";--GET RESULT AT DOUT PORT OF ALU
---------------ALU EXECUTABLE FUNCTIONS---
CONSTANT ALU_ADD :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000"; --ADD
CONSTANT ALU_SUB :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001"; --SUB
CONSTANT ALU_DIV :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010"; --DIVIDE
CONSTANT ALU_AND :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011"; --AND
CONSTANT ALU_NAND :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100"; --NAND
CONSTANT ALU_OR : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";--OR
CONSTANT ALU_XOR :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110"; --XOR
CONSTANT ALU_NOT: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111" ;--NOT
CONSTANT ALU_MULT :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000"; --MULT
CONSTANT ALU_inc :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100"; --icrement acc
CONSTANT ALU_dec :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101"; --decrement acc

--------------DATA FLOW CONTROL -------------------
CONSTANT RAM :STD_LOGIC_vector(1 downto 0):=  "00";
CONSTANT iop :STD_LOGIC_vector(1 downto 0):=  "01";
CONSTANT Prg_mem : STD_LOGIC_vector(1 downto 0):=  "10";
constant UART_Data : std_logic_vector(1 downto 0):= "11";

CONSTANT load_pixel_data : STD_LOGIC_vector(1 downto 0):=  "01";
CONSTANT load_LOC_x : STD_LOGIC_vector(1 downto 0):=  "10";
CONSTANT load_loc_Y : STD_LOGIC_vector(1 downto 0):=  "11";
CONSTANT none : STD_LOGIC_vector(1 downto 0):=  "00";
signal ctrl_reg : std_logic_vector(1 downto 0);

CONSTANT SET_DSRC_IOP :STD_LOGIC :=            '1';

CONSTANT HOLD : STD_LOGIC:= '1'; 
CONSTANT RELEASE : STD_LOGIC:= '0'; 
 
constant    re : std_logic := '0';
constant    fe : std_logic := '1';

------------------------------------------------------------------------------------------------------
signal IH, copy_addr, load_data,load_pc, inc_addr, dec_addr : std_logic;
SIGNAL state : INTEGER RANGE 0 TO 3;
SIGNAL PC : INTEGER RANGE 0 TO 255;
BEGIN
uart_reset <= '1';
address <= address0;
 pcnt <= conv_std_logic_vector(pc, 8 ) ;
PROCESS(CLK)
BEGIN
IF RISING_EDGE(CLK) THEN
		if ih = release then
		INSTRUCTION <= INST_IN;
		end if;
		
		if copy_addr = '1' then
		address0<= inst_in;	
		else if inc_addr = '1' and dec_addr <= '0' then
						address0 <= address0 + 1;
						elsif inc_addr = '0' and dec_addr <= '1' then
						address0 <= address0  - 1;
						end if;	
						if  ctrl_Reg = load_pixel_data then address0 <= "11111111";
						elsif  ctrl_Reg = load_loc_x      then address0 <= "11111101";
						elsif  ctrl_Reg = load_loc_y      then address0 <= "11111110";
						end if;
 		end if;
		
		if load_pc = '1' then
			jump_pc <= inst_in;
			end if;
			
		if load_data = '1' then
		data <= inst_in;
		end if;

end if;	

if falling_edge(clk) then	

		if instruction = "00000001" then  --mov dmem, alu acc
							if state = 0 then
									ih <=  hold;	
									mem_en <= '1';
									mem_wr <= '0';  --read memory at falling  edge
									pc <= pc  + 1; --fetch address at next rising address
									copy_addr<= '1';
									state <= state + 1;
							elsif state = 1 then
									dss <= RAM;
									xalu <= load_acc;
									ih <= release;
							     copy_addr <= '0';
								  pc <= pc + 1;
								  state <= 0;
							end if;
								   
							
			elsif instruction = "00000010" then -- move dmem, reg A;
								if state = 0 then
									ih <=  hold;	
									mem_en <= '1';
									mem_wr <= '0';  --read memory at falling  edge
									pc <= pc  + 1; --fetch address at next rising address
									copy_addr<= '1';
									state <= state + 1;
							elsif state = 1 then
									dss <= RAM;
									xalu <= fetch_a;
									ih <= release;
							     copy_addr <= '0';
								  pc <= pc + 1;
								  state <= 0;
							end if;
								   
			   elsif instruction = "00000011" then --mov dmem(addr), reg b 
												if state = 0 then
									ih <=  hold;	
									mem_en <= '1';
									mem_wr <= '0';  --read memory at falling  edge
									pc <= pc  + 1; --fetch address at next rising address
									copy_addr<= '1';
									state <= state + 1;
							elsif state = 1 then
									dss <= RAM;
									xalu <= fetch_b;
									ih <= release;
							     copy_addr <= '0';
								  pc <= pc + 1;
								  state <= 0;
							end if;
								   
								
				elsif instruction = "00000100" then -- mov IOP_A, acc;
							if state = 0 then
							dss <= IOP;
								ih <= hold;
								xiop <= r_portA;
								STATE <= STATE + 1;
						ELSIF STATE = 1 THEN
								IH <= RELEASE;
								XALU <= LOAD_ACC;
								STATE <= 0;
								PC<= PC+1;
								END IF;
				elsif instruction = "00000101" then -- mov IOP_A, reg_a
							if state = 0 then
							dss <= IOP;
								ih <= hold;
								xiop <= r_portA;
								STATE <= STATE + 1;
						ELSIF STATE = 1 THEN
								IH <= RELEASE;
								XALU <= fetch_a;
								STATE <= 0;
								PC<= PC+1;
								END IF;
				elsif instruction = "00000110" then -- mov IOP_A, reg_b;
							if state = 0 then
							dss <= IOP;
								ih <= hold;
								xiop <= r_portA;
								STATE <= STATE + 1;
						ELSIF STATE = 1 THEN
								IH <= RELEASE;
								XALU <= fetch_b;
								STATE <= 0;
								PC<= PC+1;
								END IF;			
				elsif instruction = "00000111" then -- mov IOP_B, acc;
							if state = 0 then
							dss <= IOP;
								ih <= hold;
								xiop <= r_portB;
								STATE <= STATE + 1;
						ELSIF STATE = 1 THEN
								IH <= RELEASE;
								XALU <= LOAD_ACC;
								STATE <= 0;
								PC<= PC+1;
								END IF;
				elsif instruction = "00001000" then -- mov IOP_B, reg_a
							if state = 0 then
							dss <= IOP;
								ih <= hold;
								xiop <= r_portB;
								STATE <= STATE + 1;
						ELSIF STATE = 1 THEN
								IH <= RELEASE;
								XALU <= fetch_a;
								STATE <= 0;
								PC<= PC+1;
								END IF;
				elsif instruction = "00001001" then -- mov IOP_B, reg_b;
							if state = 0 then
						dss <= IOP;
								ih <= hold;
								xiop <= r_portB;
								STATE <= STATE + 1;
						ELSIF STATE = 1 THEN
								IH <= RELEASE;
								XALU <= fetch_b;
								STATE <= 0;
								PC<= PC+1;
								END IF;			
---CLK  : ------RE-----FE------RE-----FE-------RE------FE
--INST  :[XXX][          I0               ][    Addresss            ][							next inst   ]
--STATE:[000000000000][111111111111111111111][ 0000000000000 ]
--pc          :[            p c					      	][      pc + 1                     ][pc +1                                ]
--alubdo:[xxxxxxxxxxxx][						data																					]
--addr   :[xxxxxxxxxxxxxxxxxxxxxx][ addr _w      ]
--wr       :[xxxxxxxxxxxxx][			write										]
			ELSIF INSTRUCTION = "00001010" THEN --MOV ALU: ACC, DMEM
			if state = 0 then
						ih <= hold;
						xalu <= read_alu;
						copy_addr <= '1'; --load_address on rising edge
						pc <= pc + 1; 
					  state <= state + 1;
					  mem_en <= '1';
					  mem_wr <= '1'; --write memory on falling edge
					elsif state = 1 then 
						copy_addr <= '0';
						pc<= pc+1;
						ih <= release;
						state <= 0;
						end if;
		
					  
		 ELSIF INSTRUCTION = "00001011" THEN --MOV ALU:ACC, IOPA
					XALU <= READ_ALU;
					XIOP <= W_PORTA;
					PC<= PC+1;
		ELSIF INSTRUCTION = "00001100" THEN --MOV ALU:ACC, IOPB
					XALU <= READ_ALU;
					XIOP <= W_PORTB;
					PC<= PC+1;
			
ELSIF INSTRUCTION = "00001101" THEN --push at incremental/decremental dptr
            if state = 0 then
					ih <= hold;
					xalu <= read_alu;
					mem_en <='1' ;
					mem_wr <= '1';
					state <= state + 1;
				elsif state = 1 then				
					ih <= release;
					pc <= pc + 1;
				end if;	
					
					
			
			
		ELSIF INSTRUCTION = "00001110" THEN --BLOCK IOPORT
					XIOP <= BLOCK_IO;
					PC<= PC+1;
		ELSIF INSTRUCTION = "00001111" THEN --BLOCK ALU
					XALU <= BLOCK_ALU;
					PC<= PC+1;
				ELSIF INSTRUCTION = "00010000" THEN --RST_CNT
				XALU <= RST_CNT;
				PC<= PC+1;
		ELSIF INSTRUCTION = "00010001" THEN --alu add
		     fsel <= alu_add;
			  xalu <= execute_function;
			  PC<= PC+1;
		ELSIF INSTRUCTION = "00010010" THEN --alu sub
		     fsel <= alu_sub;
			  xalu <= execute_function;	
			  PC<= PC+1;
		ELSIF INSTRUCTION = "00010011" THEN --alu div
		     fsel <= alu_div;
			  xalu <= execute_function;
			  PC<= PC+1;
	ELSIF INSTRUCTION = "00010100" THEN --alu and
		     fsel <= alu_and;
			  xalu <= execute_function;
			  PC<= PC+1;
						--ELSIF INSTRUCTION = "" THEN
	ELSIF INSTRUCTION = "00010101" THEN --alu nand
		     fsel <= alu_nand;
			  xalu <= execute_function;
			  PC<= PC+1;
	ELSIF INSTRUCTION = "00010110" THEN --alu or
		     fsel <= alu_or;
			  xalu <= execute_function;
			  PC<= PC+1;
ELSIF INSTRUCTION = "00010111" THEN --alu xor
		     fsel <= alu_xor;
			  xalu <= execute_function;
			  PC<= PC+1;
ELSIF INSTRUCTION = "00011000" THEN --alu not
		     fsel <= alu_not;
			  xalu <= execute_function;
			  PC<= PC+1;
ELSIF INSTRUCTION = "00011001" THEN --alu mult
		     fsel <= alu_mult;
			  xalu <= execute_function;
			  ih <= hold;
			  if rdy = '1' then
			  ih <= release;
			  PC<= PC+1;
			  end if;
ELSIF INSTRUCTION = "00011010" THEN --alu inc
		     fsel <= alu_inc;
			  xalu <= execute_function;
			  PC<= PC+1;
			  
ELSIF INSTRUCTION = "00011011" THEN --alu dec
		     fsel <= alu_dec;
			  xalu <= execute_function;
			  PC<= PC+1;
			  
elsif instruction = "00011100" then --go to begining 
			pc <= 0;  --reset pc
		
elsif instruction = "00011101" then --load data fromprogram memory
           if state  = 0 then
					  ih <= hold;
					  dss <= prg_mem; 
					  xalu <= load_acc;			  
					  pc <= pc + 1;--increment pc to fetch data
					  load_data <= '1';
					  state <= state + 1;--increment state
					  
			elsif state = 1 then
					  xalu <= load_acc;
					  state <=state + 1;
					  xalu <= load_acc;
					  load_data <= '0';
					  
		elsif state = 2 then
					  ih <= release;
					  pc <= pc + 1;
					  state<= 0;
					  end if;
elsif instruction = "00011110" then ----halt
					IH <= hold;
elsif instruction = "00011111" then --goto address
					if state = 0  then
					ih <= hold; --hold instruction 
					pc <= pc + 1;--increment PC to load address to jump at next rising edge
					load_pc <= '1';
					state <= state + 1;
					elsif state = 1 then
					load_pc  <='0';
					pc <= conv_integer(jump_pc);
					Ih <= release;
					state <= 0;
					end if;

elsif instruction = "00100001" then --compare accumulator with refrence specified by program	if both are equal then jump to service roution	

		if status = "11" then
		if state = 0  then
					ih <= hold; --hold instruction 
					pc <= pc + 1;--increment PC to load address to jump at next rising edge
					load_pc <= '1';
					state <= state + 1;
					elsif state = 1 then
					load_pc  <='0';
					pc <= conv_integer(jump_pc);
					Ih <= release;
					state <= 0;
					end if;
			else
			pc <= pc + 2; --increment pc by 2 to keep running main routine since condition is false;
			end if;
elsif instruction = "00100010" then --cmp acc  >  b 

		if status = "01" then
		if state = 0  then
					ih <= hold; --hold instruction 
					pc <= pc + 1;--increment PC to load address to jump at next rising edge
					load_pc <= '1';
					state <= state + 1;
					elsif state = 1 then
					load_pc  <='0';
					pc <= conv_integer(jump_pc);
					Ih <= release;
					state <= 0;
					end if;
			else
			pc <= pc + 2; --increment pc by 2 to keep running main routine since condition is false;
			end if;		
		elsif instruction = "00100011" then --compare accumulator with refrence specified by program	if both are equal then jump to service roution	

		if status = "10" then -- cmp acc > b
		if state = 0  then
					ih <= hold; --hold instruction 
					pc <= pc + 1;--increment PC to load address to jump at next rising edge
					load_pc <= '1';
					state <= state + 1;
					elsif state = 1 then
					load_pc  <='0';
					pc <= conv_integer(jump_pc);
					Ih <= release;
					state <= 0;
					end if;
			else
			pc <= pc + 2; --increment pc by 2 to keep running main routine since condition is false;
			end if;
			
	elsif instruction = "00100100" then --load data fromprogram memory to regiser B
           if state  = 0 then
					  ih <= hold;
					  dss <= prg_mem; 
					  xalu <= fetch_b;			  
					  pc <= pc + 1;--increment pc to fetch data
					  load_data <= '1';
					  state <= state + 1;--increment state
					  
			elsif state = 1 then
					  xalu <= fetch_b;
					  state <=state + 1;
					  load_data <= '0';
					  
		elsif state = 2 then
					  ih <= release;
					  pc <= pc + 1;
					  state<= 0;
					  end if;		
					  
		elsif instruction = "00100101" then --load data fromprogram memory to regiser A
           if state  = 0 then
					  ih <= hold;
					  dss <= prg_mem; 
					  xalu <= fetch_a;			  
					  pc <= pc + 1;--increment pc to fetch data
					  load_data <= '1';
					  state <= state + 1;--increment state
					  
			elsif state = 1 then
					  xalu <= fetch_a;
					  state <=state + 1;
					  load_data <= '0';
					  
		elsif state = 2 then
					  ih <= release;
					  pc <= pc + 1;
					  state<= 0;
					  end if;			
				
		elsif instruction = "00100110" then --disable memory
					mem_en <= '0';
					pc <= pc + 1;
					
	elsif instruction = "00100111" then --inc wptr
			if state = 0 then
					ih <= hold;
				 inc_addr <= '1' ;
				 state <= state + 1;
				 elsif state = 1 then
				 ih <= release;
				 inc_addr <= '0';
				 pc <= pc  + 1;
				 state <= 0;
				 end if;
				 
		elsif instruction = "00101000" then
			if state = 0 then
				ih <= hold;
				 dec_addr <= '1' ;
				 state <= state + 1;
				 elsif state = 1 then
				 ih <= release;
				 dec_addr <= '0';
				 state <= 0;
				 pc <= pc  + 1;
				 end if;
					
	elsif instruction = "00101001" then  ---pop data from RAM to accumulator
	  if state =  0 then 
	  ih <= hold;
	  mem_en <= '1';
	  mem_wr <= '0';
	  state <= state + 1;
	 elsif state = 1 then 
	  xalu <= load_acc;
	  mem_en <= '0';
	  state <= state + 1;
	  elsif state = 2 then
	  IH <= release;
	  state <= 0;
	  pc <= pc + 1;
	  end if;
	  
	  elsif instruction = "00101010" then --do something for  i iterations
	  	if statusAB = "11" then 
		if state = 0  then
					ih <= hold; --hold instruction 
					pc <= pc + 1;--increment PC to load address to jump at next rising edge
					load_pc <= '1';
					state <= state + 1;
					elsif state = 1 then
					load_pc  <='0';
					pc <= conv_integer(jump_pc);
					Ih <= release;
					state <= 0;
					end if;
			else
			pc <= pc + 2; --increment pc by 2 to keep running main routine since condition is false;
			end if;
	 elsif instruction = "00101011" then 	
			fsel <= "1110";
			xalu <= execute_function;
			pc <= pc + 1;
			
	elsif instruction = "00101100" then ---wrtite pixel data in graphics buffer from Accumulator
	if state = 0 then
			ih <= hold;
			xalu <= read_alu;
			ctrl_reg <=	 load_pixel_data;
			gbuffer_en <= '1';
			gbuffer_we <= '1';
			state <= state + 1;
	elsif state = 1 then 

			ctrl_reg <= none;
			state <= state + 1;
	elsif state = 2 then
			IH <= release;
			gbuffer_en <= '0';
			gbuffer_we <= '0';
			pc <= pc + 1;
			state <= 0;
			end if;	
  			
	elsif instruction = "00101101" then ---wrtite location y in graphics buffer from Accumulator
	if state = 0 then
			ih <= hold;
			xalu <= read_alu;
			ctrl_reg <=	 load_loc_x;
			gbuffer_en <= '1';
			gbuffer_we <= '1';
			state <= state + 1;
	elsif state = 1 then 

			ctrl_reg <= none;
			state <= state + 1;
	elsif state = 2 then
			IH <= release;
			gbuffer_en <= '0';
			gbuffer_we <= '0';
			pc <= pc + 1;
			state <= 0;
			end if;	
			
	elsif instruction = "00101110" then ---wrtite location_y in graphics buffer from Accumulator
	if state = 0 then
			ih <= hold;
			ctrl_reg <=	 load_loc_y;
			xalu <= read_alu;
			gbuffer_en <= '1';
			gbuffer_we <= '1';
			state <= state + 1;
	elsif state = 1 then 
			ctrl_reg <= none;
			state <= state + 1;
	elsif state = 2 then
			IH <= release;
			gbuffer_en <= '0';
			gbuffer_we <= '0';
			pc <= pc + 1;
			state <= 0;
			end if;			
	   elsif instruction = "00101111" then --jump by 1
					pc <= pc + 1;
	elsif instruction = "00110000"	then ----transmit data through UART
							
				if state  = 0 then 
				if tx_busy = '0' then  ---if UART available to transmit data else wait for availablity
				   ih <= hold;
					tx_en <= '1';   ---enable to latch tx data
					state <= state + 1;
					end if;
				elsif state = 1 then
					ih <= release;
					tx_en <= '0';----force to low to latch data
					state <= 0;
					pc <= pc + 1; --goto next instruction 
				end if;				
				
				
	elsif instruction  = "00110001" then --receive data from UART port
			 ---if data available across UART to receive with no error then
				if state = 0 then
				if rx_busy = '0'  then
				ih <= hold;
				dss <= uart_data; --set ALU input source UART data 
				xalu <= load_acc; --put data to Accumulator register
				state <= state + 1;	
				end if;
				
				elsif state = 1 then
				ih <= release;
				xalu <= block_alu; --block alu IO to avoid unneccesary changes in data
				state <= 0;
				pc <= pc + 1;				
				end if;	
			
				
							
end if;	
END IF;								


END PROCESS;
END BEHAVIORAL;