--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SPISR IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32	);
				
    Port (
			reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			
			spisr_cs		:	in	std_logic;
			
			slave_mode_select	:	in 		std_logic;
			mode_fault_error	:	in		std_logic;
			tx_full				:	in		std_logic;
			tx_empty			:	in		std_logic;
			rx_full				:	in		std_logic;
			rx_empty			:	in		std_logic;
			
			reg_read_enable		:	in		std_logic;
			reg_rdata			:	out		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			reg_rack			:	out 	std_logic;
			
			reg_rerror			:	out		std_logic;
			reg_werror			:	out		std_logic
			
			);
END SPISR;

ARCHITECTURE behave OF SPISR IS

SIGNAL spisr_reg : std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);

BEGIN

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk) and spisr_cs = '1') THEN
			
		--reset
		IF (reg_rst = '1') THEN
			reg_rack <= '0';
			reg_rerror <= '0';
		END IF;
		
		--read
		IF (reg_read_enable = '1') THEN
		reg_rdata <= spisr_reg;
		reg_rack <= '1';
		wait until rising_edge(reg_clk);
		reg_rack <= '0';
		END IF;
		
		
		--ERROR CONDITION?
		--IF() THEN
		--reg_rerror <= '1';
		--END IF;
		
	END IF;

END PROCESS;

		--register tied to inputs
		--BITS 31 to 6 reserved
		spisr_reg (5) <= slave_mode_select;
		spisr_reg (4) <= mode_fault_error;
		spisr_reg (3) <= tx_full;
		spisr_reg (2) <= tx_empty;
		spisr_reg (1) <= rx_full;
		spisr_reg (0) <= rx_empty;

END behave;