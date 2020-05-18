--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY TX_FIFO_OCY IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32	);
				
    Port (
			reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			
			tx_fifo_ocy_cs		:	in	std_logic;
			
			tx_fifo_occupancy	:	in		std_logic_vector (3 downto 0);
			
			reg_read_enable		:	in		std_logic;
			reg_rdata			:	out		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			reg_rack			:	out 	std_logic;
			
			reg_rerror			:	out		std_logic;
			
			
			
			);
END TX_FIFO_OCY;

ARCHITECTURE behave OF TX_FIFO_OCY IS

SIGNAL tx_fifo_ocy_reg : std_logic_vector (31 downto 0) := x"00000000";

BEGIN

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk) and tx_fifo_ocy_cs = '1') THEN
	
		IF (reg_rst = '1') THEN
			tx_fifo_ocy_reg <= x"00000000";
		END IF;
			
		IF (reg_read_enable = '1') THEN
			reg_rdata <= tx_fifo_ocy_reg;
			reg_rack <= '1';
			wait until rising_edge(reg_clk);
			reg_rack <= '0';
		END IF;
		
	END IF;

END PROCESS;

tx_fifo_ocy_reg (3 downto 0) <= tx_fifo_occupancy;

END behave;