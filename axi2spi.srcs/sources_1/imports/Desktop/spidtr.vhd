--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SPIDTR IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32;
				C_NUM_TRANSFER_BITS	: integer := 32	);
				
    Port (
			reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			
			spidtr_cs		:	in	std_logic;
			
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			reg_wack			:	out		std_logic;
			
			tx_fifo_data		:	out		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
			
			reg_werror			:	out 	std_logic
			
			);
END SPIDTR;

ARCHITECTURE behave OF SPIDTR IS

SIGNAL spidtr_reg : std_logic_vector((C_S_AXI_DATA_WIDTH - 1) downto 0) := x"00000000";

BEGIN

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk) AND spidtr_cs = '1') THEN
	
		IF (reg_rst = '1') THEN
			spidtr_reg <= x"00000000";
			reg_wack <= '0';
			reg_werror <= '0';
		END IF;
		
		IF (reg_write_enable = '1') THEN
			spidtr_reg <= reg_wdata;
			
			reg_wack <= '1';
			wait until rising_edge(reg_clk);
			reg_wack <= '0';
		END IF;
		
		--error condition???
		
	END IF;

END PROCESS;


--tx_fifo_data set to register value
tx_fifo_data <= spidtr_reg;


END behave;