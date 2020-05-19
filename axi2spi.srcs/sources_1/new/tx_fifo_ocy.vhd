--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller
--TX_FIFO Occupancy Register    --Read only


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
			tx_fifo_ocy_rdata	:	out		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			tx_fifo_ocy_rack	:	out 	std_logic
			
			);
END TX_FIFO_OCY;

ARCHITECTURE behave OF TX_FIFO_OCY IS

SIGNAL tx_fifo_ocy_reg : std_logic_vector (31 downto 0) := x"00000000";
SIGNAL tx_fifo_ocy_rack_temp : std_logic := '0';

BEGIN

--register 4 lsb set to occupancy value
tx_fifo_ocy_reg (3 downto 0) <= tx_fifo_occupancy;
tx_fifo_ocy_rack <= tx_fifo_ocy_rack_temp;

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk)) THEN
	
	   --reset
		IF (reg_rst = '1') THEN
			tx_fifo_ocy_reg <= x"00000000";
			tx_fifo_ocy_rack_temp <= '0';
		END IF;
			
		--read
		IF (reg_read_enable = '1' and tx_fifo_ocy_cs = '1') THEN
			tx_fifo_ocy_rdata (31 downto 0) <= tx_fifo_ocy_reg;
			tx_fifo_ocy_rack_temp <= not tx_fifo_ocy_rack_temp;
			
		ELSE
		tx_fifo_ocy_rack_temp <= '0';
		END IF;
		
	END IF;

END PROCESS;

END behave;