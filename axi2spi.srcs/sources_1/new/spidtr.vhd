--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller
--SPI Data Transmit Register    --Write only


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
			spidtr_wack			:	out		std_logic;
			
			tx_fifo_data		:	out		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0)			
			);
END SPIDTR;

ARCHITECTURE behave OF SPIDTR IS

SIGNAL spidtr_reg : std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0) := (others => '0');
SIGNAL spidtr_wack_temp : std_logic := '0';

BEGIN

--TX FIFO DATA SET TO REGISTER
tx_fifo_data <= spidtr_reg;
spidtr_wack <= spidtr_wack_temp;

PROCESS (reg_clk, reg_rst)
variable i : integer range 0 to ((C_S_AXI_DATA_WIDTH / 8) - 1) := 0;
BEGIN

	IF (rising_edge(reg_clk)) THEN
	    
	    --reset
		IF (reg_rst = '1') THEN
			spidtr_reg <= x"00000000";
			spidtr_wack_temp <= '0';
		END IF;
		
		--write
		IF (reg_write_enable = '1' and spidtr_cs = '1') THEN
            i := 0;
			while (i < 4) loop
				if(reg_wstb(i) = '1') then
					--update value
					spidtr_reg((i*8 + 7) downto i*8) <= reg_wdata((i*8 + 7) downto i*8);
				else
					--keep old value
					spidtr_reg((i*8 + 7) downto i*8) <= spidtr_reg((i*8 + 7) downto i*8);
				end if;
				i := i + 1;
			end loop;
			spidtr_wack_temp <= not spidtr_wack_temp;
			
		ELSE
		spidtr_wack_temp <= '0';
		END IF;
        
		
	END IF;

END PROCESS;

END behave;