--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SPIDRR IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32;
				C_NUM_TRANSFER_BITS : integer := 32		);
				
    Port (
			reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			
			spidrr_cs		:	in	std_logic;
			
			rx_fifo_data		:	in		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
			
			reg_read_enable		:	in		std_logic;
			reg_rdata			:	out		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
			reg_rack			:	out 	std_logic;
			
			reg_rerror			:	out		std_logic;
			
			
			
			);
END SPIDRR;

ARCHITECTURE behave OF SPIDRR IS

SIGNAL spidrr_reg : std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0) := x"00000000";

BEGIN

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk) and spidrr_cs = '1') THEN
	
		IF (reg_rst = '1') THEN
			spidrr_reg <= x"00000000";
			reg_rack <= '0';
			reg_rerror <= '0';
		END IF;
		
		IF (reg_read_enable = '1') THEN
			reg_rdata <= spidrr_reg;
			reg_rack <= '1';
			wait until rising_edge(reg_clk);
			reg_rack <= '0';
		END IF;
		
		--error condition
		
		
	END IF;
END PROCESS;

spidrr_reg <= rx_fifo_data;

END behave;