--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller
--SPI Data Receive Register     --read only


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
			spidrr_rdata		:	out		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
			spidrr_rack			:	out 	std_logic
			);
END SPIDRR;

ARCHITECTURE behave OF SPIDRR IS

SIGNAL spidrr_reg : std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0) := (others => '0');
SIGNAL spidrr_rack_temp : std_logic := '0';

BEGIN

--register set to rx_fifo_data
spidrr_reg <= rx_fifo_data;
spidrr_rack <= spidrr_rack_temp;

PROCESS (reg_clk, reg_rst)
BEGIN

	IF (rising_edge(reg_clk)) THEN
	   
	   --reset
		IF (reg_rst = '1') THEN
			spidrr_reg <= x"00000000";
			spidrr_rack_temp <= '0';
		END IF;
		
		--read only
		IF (reg_read_enable = '1' and spidrr_cs = '1') THEN
			spidrr_rdata <= spidrr_reg;
			spidrr_rack_temp <= not spidrr_rack_temp;
		
		ELSE
		spidrr_rack_temp <= '0';
		END IF;
	END IF;
	
END PROCESS;

END behave;