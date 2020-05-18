--Author: Devon Stedronsky
--Date: May 2020
--
--Description: SRR Module for AXI to SPI Controller


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SRR IS
	Generic	( C_S_AXI_DATA_WIDTH : integer := 32	);
				
    Port (
			reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			
			srr_cs		:	in	std_logic;
			
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			reg_wack			:	out		std_logic;
			reg_werror			:	out 	std_logic;
			
			soft_reset			:	out		std_logic;
						
			);
END SRR;

ARCHITECTURE behave OF SRR IS

signal srr_reg : std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0) := x"00000000";

BEGIN

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk) and srr_cs = '1') THEN
	
		--reset
		IF (reg_rst = '1') THEN
			srr_reg <= x"00000000";
			reg_werror <= '0';
			soft_reset <= '0';
			reg_wack <= '0';
		END IF;
		
		
		--soft reset value error check
		IF (reg_write_enable = '1') THEN
			
			IF (reg_wdata = x"0000000A") THEN
				srr_reg <= reg_wdata;
				soft_reset <= '1';
				reg_wack <= '1';
				wait until rising_edge(reg_clk);
				reg_wack <= '0';
			
			ELSIF (reg_wdata = x"00000000") THEN
				srr_reg <= reg_wdata;
				soft_reset <= '0';
				reg_wack <= '1';
				wait until rising_edge(reg_clk);
				reg_wack <= '0';
			
			ELSE
				reg_werror <= '1';
			
			END IF;
		END IF;
		
		--read error (write only register)
		--IF (reg_read_enable = '1') THEN
			--reg_rerror = '1';
		--END IF;
		
	END IF;
	
END PROCESS;

END behave;