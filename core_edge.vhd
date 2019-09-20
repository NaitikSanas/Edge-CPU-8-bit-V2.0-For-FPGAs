library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity core_edge is
port(
			IO_p1, LED : inout std_logic_vector(7 downto 0);
			clk_in: in std_logic;
			TX: out std_logic;
			RX: in std_logic;
			pixel_data_out: out std_logic_vector(7 downto 0);
	--	data_in, prg_addr : in std_logic_vector(7 downto 0);
			Hsync, Vsync: out std_logic
			

);
end core_edge;

architecture Behavioral of core_edge is

	COMPONENT ALU_INT8
	PORT(
		DATA_IN : IN std_logic_vector(7 downto 0);
		status, statusAB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

		FUNCTION_SEL : IN std_logic_vector(3 downto 0);
		CLK : IN std_logic;
		IOEN : IN std_logic;
		AB : IN std_logic;
		WR : IN std_logic;
		EXE : IN std_logic;
		LACC : IN std_logic;
		rst_cnt : IN std_logic;          
		DATA_OUT : OUT std_logic_vector(7 downto 0);
		rdy : OUT std_logic
		);
	END COMPONENT;


	
	COMPONENT IO_PORT
	PORT(
		DI : IN std_logic_vector(7 downto 0);
		CLK : IN std_logic;
		WR : IN std_logic;
		AB : IN std_logic;
		EN : IN std_logic;    
		PORT_A : INOUT std_logic_vector(7 downto 0);
		PORT_B : INOUT std_logic_vector(7 downto 0);      
		DO : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;


	
	COMPONENT Memory
	PORT(
		DI : IN std_logic_vector(7 downto 0);
		address : IN std_logic_vector(7 downto 0);
		clk : IN std_logic;
		WR : IN std_logic;
		E : IN std_logic;          
		DO : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;


COMPONENT mux
	PORT(
		a : IN std_logic_vector(7 downto 0);
		b : IN std_logic_vector(7 downto 0);
		c : IN std_logic_vector(7 downto 0);
		d : IN std_logic_vector(7 downto 0);
		sel : IN std_logic_vector(1 downto 0);          
		y : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;


	
	
	COMPONENT IDCU
	PORT(
		Inst_IN : IN std_logic_vector(7 downto 0);
		CLK : IN std_logic;
		rdy : IN std_logic;
		Status : IN std_logic_vector(1 downto 0);
		statusAB : IN std_logic_vector(1 downto 0);
		rx_busy : IN std_logic;
		tx_busy : IN std_logic;
		rx_error : IN std_logic;          
		XALU : OUT std_logic_vector(5 downto 0);
		XIOP : OUT std_logic_vector(2 downto 0);
		DSS : OUT std_logic_vector(1 downto 0);
		uart_reset : OUT std_logic;
		tx_en : OUT std_logic;
		mem_en : OUT std_logic;
		mem_wr : OUT std_logic;
		gbuffer_we : OUT std_logic;
		gbuffer_en : OUT std_logic;
		ADDRESS : OUT std_logic_vector(7 downto 0);
		pcnt : OUT std_logic_vector(7 downto 0);
		data : OUT std_logic_vector(7 downto 0);
		fsel : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	
	COMPONENT Program_mem
	PORT(
		address : IN std_logic_vector(4 downto 0);          
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT clock_divider
	PORT(
		clk : IN std_logic;          
			clk_out, display_clk , UART_CLK: out std_logic
		);
	END COMPONENT;

	COMPONENT Graphics_buffer
	PORT(
		data_in : IN std_logic_vector(7 downto 0);
		address : IN std_logic_vector(7 downto 0);
		clk : IN std_logic;
		display_clk : IN std_logic;
		en : IN std_logic;
		we : IN std_logic;          
			PDO : OUT std_logic_vector(7 downto 0);
		hs : OUT std_logic;
		vs : OUT std_logic
		);
	
	END COMPONENT;


	COMPONENT uart
	PORT(
		clk : IN std_logic;
		reset_n : IN std_logic;
		tx_ena : IN std_logic;
		tx_data : IN std_logic_vector(7 downto 0);
		rx : IN std_logic;          
		rx_busy : OUT std_logic;
		rx_error : OUT std_logic;
		rx_data : OUT std_logic_vector(7 downto 0);
		tx_busy : OUT std_logic;
		tx : OUT std_logic
		);
	END COMPONENT;

signal PDATA, ADATA,addr, pc,data_from_gpu,jump_pc,data_from_mem,  data_from_alu, data_from_iop, alu_data, dptr, isin, pcnt, from_prog, address: std_logic_vector(7 downto 0);
signal fsel: std_logic_vector(3 downto 0);

signal xalu: std_logic_vector(5 downto 0);
signal xiop: std_logic_vector(2 downto 0);

signal Uart_tx_data, uart_rx_data: std_logic_vector(7 downto 0);
signal uart_rst , uart_en, uart_rx_error, uart_tx_busy, uart_rx_busy : std_logic;

signal dss, status, statusAB, mode: std_logic_vector(1 downto 0);
signal RESET, ready, gbuf_en, gbuf_we, clk, en , wr, Dclk, DATA_READY, UART_CLK : std_logic;


begin	
UART_COM: uart PORT MAP(
		clk => UART_CLK,
		reset_n => uart_rst ,
		tx_ena =>  uart_en,
		tx_data => data_from_alu,
		rx => rx,
		rx_busy => uart_rx_busy ,
		rx_error => uart_rx_error,
		rx_data => uart_rx_data,
		tx_busy => uart_tx_busy,
		tx => tx
	);

	Graphics_buffer0:Graphics_buffer PORT MAP(
		data_in => data_from_alu ,
		address => address,
		clk =>clk ,
		display_clk =>Dclk ,
		en => gbuf_en,
		we => gbuf_we,
		hs => hsync, vs => vsync, pdo => pixel_data_out
		
	);


	RAM: Memory PORT MAP(
		DI => data_from_alu,
		DO => data_from_mem,
		address => address ,
		clk => clk,
		WR => wr,
		E => en
	);	
clock_scaler: clock_divider PORT MAP(clk => clk_in,clk_out => clk, display_clk => dclk, UART_CLK => UART_CLK);
	
--clk <= clk_in;
program_memory : program_mem port map (address => pcnt(4 downto 0), data_out  => isin);

	instruction_decode_and_control_unit: IDCU PORT MAP(
	status => status,
		Inst_IN =>isin ,
		uart_reset => uart_rst,
		tx_en => uart_en,
		rx_busy => uart_rx_busy,
		tx_busy => uart_tx_busy,
		rx_error => uart_rx_error,
		CLK => clk,
		rdy =>ready ,
		XALU => xalu,
		XIOP =>xiop ,
		DSS =>dss ,
		ADDRESS => address,
		pcnt => pcnt,
		fsel => fsel,
		data => from_prog,
		mem_en =>en,
		mem_wr => wr,
		statusab => statusab,
		 gbuffer_we=> gbuf_we, 
		 gbuffer_en => gbuf_en
	);
	
		
	alu_data_mux: mux PORT MAP(
		a => data_from_mem,
		b => data_from_iop ,
		c =>  from_prog,
		d =>uart_rx_data,
		sel => dss ,
		y => alu_data
	);
--	LED <= UART_RX_DATA;
 physical_IO_PORT: IO_PORT PORT MAP(
		PORT_A =>IO_p1,
		PORT_B =>led,
		DI => data_from_alu ,
		DO =>data_from_iop,
		CLK => clk,
		WR => xiop(2),
		AB => xiop(1),
		EN => xiop(0)
	);
	ALU: ALU_INT8 PORT MAP(
		DATA_IN => alu_data,
		DATA_OUT => data_from_alu,
		FUNCTION_SEL => fsel,
		CLK => clk ,
		IOEN =>xalu(0) ,
		AB =>xalu(1)  ,
		WR => xalu(2) ,
		EXE => xalu(3) ,
		LACC => xalu(4) ,
		rst_cnt => xalu(5) ,
		rdy => ready,
		status => status,
		statusAB => statusAB
	);



end Behavioral;

