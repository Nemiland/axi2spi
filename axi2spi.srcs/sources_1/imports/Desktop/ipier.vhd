--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY IPIER IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32	);
				
    Port (
			reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			
			ipier_cs		:	in	std_logic;
			
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			reg_wack			:	out		std_logic;
						
			reg_werror			:	out 	std_logic;
			reg_rerror			:	out		std_logic;
			
			reg_read_enable		:	in		std_logic;
			reg_rack			:	out 	std_logic;
			
			Drr_not_empty_int_en	:	out		std_logic;
			Ss_mode_int_en			:	out		std_logic;
			Tx_fifo_half_int_en		:	out		std_logic;
			Drr_overrun_int_en		:	out		std_logic;
			Drr_full_int_en			:	out		std_logic;
			Dtr_underrun_int_en		:	out		std_logic;
			Dtr_empty_int_en		:	out		std_logic;
			Slave_mode_fault_int_en	:	out		std_logic;
			Mode_fault_int_en		:	out		std_logic
			
			);
END IPIER;

ARCHITECTURE behave OF IPIER IS

SIGNAL ipier_reg : std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0) := x"00000000";

BEGIN

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk) and ipier_cs = '1') THEN
	
		IF (reg_rst = '1') THEN
			ipier_reg <= x"00000000";
			reg_rack <= '0';
			reg_wack <= '0';
			reg_rerror <= '0';
			reg_werror <= '0';
		END IF;
		
		--WRITE
		IF (reg_write_enable <= '1') THEN
			ipier_reg <= reg_wdata;
			reg_wack <= '1';
			wait until rising_edge(reg_clk);
			reg_wack <= '0';
		END IF;
		
		--READ
		IF (reg_read_enable <= '1') THEN
			
			Drr_not_empty_int_en 	<= ipier_reg (8);
			Ss_mode_int_en			<= ipier_reg (7);
			Tx_fifo_half_int_en 	<= ipier_reg (6);
			Drr_overrun_int_en		<= ipier_reg (5);
			Drr_full_int_en			<= ipier_reg (4);
			Dtr_underrun_int_en		<= ipier_reg (3);
			Dtr_empty_int_en		<= ipier_reg (2);
			Slave_mode_fault_int_en	<= ipier_reg (1);
			Mode_fault_int_en		<= ipier_reg (0);

			reg_rack <= '1';
			wait until rising_edge(reg_clk);
			reg_rack <= '0';
		END IF;
	END IF;

END PROCESS;

END behave;