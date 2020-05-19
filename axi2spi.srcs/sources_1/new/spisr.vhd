--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller
--SPI Status Register --Read only 


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
			spisr_rdata			:	out		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			spisr_rack			:	out 	std_logic
			
			);
END SPISR;

ARCHITECTURE behave OF SPISR IS

SIGNAL spisr_reg : std_logic_vector (31 downto 0) := "00000000000000000000000000" 
    & slave_mode_select & mode_fault_error & tx_full & tx_empty & rx_full & rx_empty;

SIGNAL spisr_rack_temp : std_logic := '0';

BEGIN
        --register set with input bits
		--BITS 31 to 6 reserved
		spisr_reg (5) <= slave_mode_select;
		spisr_reg (4) <= mode_fault_error;
		spisr_reg (3) <= tx_full;
		spisr_reg (2) <= tx_empty;
		spisr_reg (1) <= rx_full;
		spisr_reg (0) <= rx_empty;
		
		spisr_rack <= spisr_rack_temp;

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk)) THEN
			
		--reset
		IF (reg_rst = '1') THEN
			spisr_rack_temp <= '0';
		END IF;
		
		--read
		IF (reg_read_enable = '1' and spisr_cs = '1') THEN
		spisr_rdata <= spisr_reg;
		spisr_rack_temp <= not spisr_rack_temp;
		
		ELSE
		spisr_rack_temp <= '0';
		END IF;
	END IF;

END PROCESS;

END behave;