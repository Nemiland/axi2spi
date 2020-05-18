--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY DGIER IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32	);
				
    Port (
			reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			
			dgier_cs		:	in	std_logic;
			
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			reg_wack			:	out		std_logic;
			
			reg_read_enable		:	in		std_logic;
			reg_rack			:	out 	std_logic;
			
			--global interrupt enable signal
			gi_en				:	out 	std_logic;
			
			reg_werror			:	out 	std_logic;
			reg_rerror			:	out		std_logic
			
			);
END DGIER;

ARCHITECTURE behave OF DGIER IS

SIGNAL dgier_reg : std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0) := x"00000000";

BEGIN

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk) and dgier_cs = '1') THEN
	
		IF (reg_rst = '1') THEN
			dgier_reg <= x"00000000";
		END IF;
		
		IF (reg_read_enable = '1') THEN
			gi_en <= dgier_reg (31);
			reg_rack <= '1';
			wait until rising_edge(reg_clk);
			reg_rack <= '0';
		END IF;
		
		IF (reg_write_enable = '1') THEN
			dgier_reg <= reg_wdata;
			reg_wack <= '1';
			wait until rising_edge(reg_clk);
			reg_wack <= '0';
		END IF;
		
		--error condition???
		
	END IF;

END PROCESS;

END behave;