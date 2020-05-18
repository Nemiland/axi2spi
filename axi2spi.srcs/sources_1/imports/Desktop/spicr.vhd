--Author: Devon Stedronsky
--Date: May 2020
--
--Description: SPICR Module for AXI to SPI Controller


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SPICR IS
	Generic	( C_S_AXI_DATA_WIDTH : integer := 32	);
				
    Port (
			reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			
			spicr_cs		:	in	std_logic;
			
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			reg_wack			:	out		std_logic;
			
			reg_read_enable		:	in		std_logic;
			reg_rack			:	out 	std_logic;
			
			reg_werror			:	out 	std_logic;
			reg_rerror			:	out		std_logic;
			
			
			--OUTPUT CONTROL SIGNALS
			Lsb_first			:	out		std_logic;
			Master_inhibit		:	out		std_logic;
			Manual_ss_en		:	out		std_logic;
			Rx_fifo_reset		:	out		std_logic;
			Tx_fifo_reset		:	out		std_logic;
			Chpa				:	out		std_logic;
			Cpol				:	out		std_logic;
			Spi_master_en		:	out		std_logic;
			Spi_system_en		:	out		std_logic;
			Loopback_en			:	out		std_logic
		
			);
END SPICR;

ARCHITECTURE behave OF SPICR IS

SIGNAL spicr_reg : std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0) := x"00000180";

BEGIN

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk) and spicr_cs = '1') THEN
	
		--reset
		IF (reg_rst = '1') THEN
			spicr_reg <= x"00000180";
			reg_rerror <= '0';
			reg_werror <= '0';
			reg_rack <= '0';
			reg_wack <= '0';
		END IF;
		
		--Simultaneous read/write error
		IF (reg_read_enable = '1' and reg_write_enable = '1') THEN
			reg_werror <= '1';
			reg_rerror <= '1';
		
		--write
		ELSIF (reg_write_enable = '1') THEN
			spicr_reg <= reg_wdata;
			reg_wack <= '1';
			wait until rising_edge(reg_clk);
			reg_wack <= '0';
		
		--read
		ELSIF (reg_read_enable = '1') THEN
			
			--bits 31 to 10 reserved
			Lsb_first 		<= spicr_reg(9);
			Master_inhibit 	<= spicr_reg(8);
			Manual_ss_en 	<= spicr_reg(7);
			Rx_fifo_reset 	<= spicr_reg(6);
			Tx_fifo_reset 	<= spicr_reg(5);
			Chpa			<= spicr_reg(4);
			Cpol			<= spicr_reg(3);
			Spi_master_en	<= spicr_reg(2);
			Spi_system_en	<= spicr_reg(1);
			Loopback_en		<= spicr_reg(0);
			
			reg_rack <= '1';
			wait until rising_edge(reg_clk);
			reg_rack <= '0';
			
		END IF;
		
	END IF;

END PROCESS;

END behave;