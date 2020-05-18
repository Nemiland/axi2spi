--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY IPISR IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32	);
				
    Port (
			reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			
			ipisr_cs		:	in	std_logic;
			
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			reg_wack			:	out		std_logic;
			
			reg_read_enable		:	in		std_logic;
			reg_rack			:	out 	std_logic;
			
			reg_werror			:	out 	std_logic;
			reg_rerror			:	out		std_logic;
			
			drr_not_empty			: 	out		std_logic;
			slave_mode_select		: 	out		std_logic;
			tx_fifo_half			: 	out		std_logic;
			drr_overrun				: 	out		std_logic;
			drr_full				: 	out		std_logic;
			dtr_underrun			: 	out		std_logic;
			dtr_empty				: 	out		std_logic;
			slave_mode_fault_error	: 	out		std_logic;
			mode_fault_error		: 	out		std_logic;
				
			);
END IPISR;

ARCHITECTURE behave OF IPISR IS

SIGNAL ipisr_reg : std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0) := x"00000000";

BEGIN

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk) and ipisr_cs = '1') THEN
	
		IF (reg_rst = '1') THEN
			ipisr_reg <= x"00000000"
			reg_wack <= '0';
			reg_rack <= '0';
			reg_werror <= '0';
			reg_rerror <= '0';
		END IF;
		
		--TOW
		IF (reg_write_enable = '1') THEN
		
			IF (reg_wdata (8) = '1') THEN
				ipisr_reg (8) = not ipisr_reg (8);
			END IF;
			
			IF (reg_wdata (7) = '1') THEN
				ipisr_reg (7) = not ipisr_reg (7);
			END IF;
			
			IF (reg_wdata (6) = '1') THEN
				ipisr_reg (6) = not ipisr_reg (6);
			END IF;
			
			IF (reg_wdata (5) = '1') THEN
				ipisr_reg (5) = not ipisr_reg (5);
			END IF;
			
			IF (reg_wdata (4) = '1') THEN
				ipisr_reg (4) = not ipisr_reg (4);
			END IF;
			
			IF (reg_wdata (3) = '1') THEN
				ipisr_reg (3) = not ipisr_reg (3);
			END IF;
			
			IF (reg_wdata (2) = '1') THEN
				ipisr_reg (2) = not ipisr_reg (2);
			END IF;
			
			IF (reg_wdata (1) = '1') THEN
				ipisr_reg (1) = not ipisr_reg (1);
			END IF;
			
			IF (reg_wdata (0) = '1') THEN
				ipisr_reg (0) = not ipisr_reg (0);
			END IF;
			
			reg_wack <= '1';
			wait until rising_edge(reg_clk);
			reg_wack <= '0';
		END IF;
		
		--READ
		IF (reg_read_enable = '1') THEN
		drr_not_empty 		<= ipisr_reg (8);
		slave_mode_select 	<= ipisr_reg (7);
		tx_fifo_half		<= ipisr_reg (6);
		drr_overrun			<= ipisr_reg (5);
		drr_full			<= ipisr_reg (4);
		dtr_underrun		<= ipisr_reg (3);
		dtr_empty				 <= ipisr_reg (2);
		slave_mode_fault_error	 <= ipisr_reg (1);
		mode_fault_error		 <= ipisr_reg (0);
		
		reg_rack <= '1';
		wait until rising_edge(reg_clk);
		reg_rack <= '0';
		END IF;
		
	END IF;

END PROCESS;

END behave;