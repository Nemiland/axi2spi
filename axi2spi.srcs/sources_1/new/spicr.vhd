--Author: Devon Stedronsky
--Date: May 2020
--
--Description: SPICR Module for AXI to SPI Controller
--SPI Control Register --R/W


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
			spicr_wack			:	out		std_logic;
			
			reg_read_enable		:	in		std_logic;
			spicr_rack			:	out 	std_logic;
			spicr_rdata         :   out     std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			
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
SIGNAL spicr_rack_temp, spicr_wack_temp : std_logic := '0';

BEGIN
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
				
PROCESS (reg_clk, reg_rst)
variable i : integer range 0 to ((C_S_AXI_DATA_WIDTH / 8) - 1) := 0;
BEGIN

spicr_rack <= spicr_rack_temp;
spicr_wack <= spicr_wack_temp;


	IF (rising_edge(reg_clk)) THEN
	
		--reset
		IF (reg_rst = '1') THEN
			spicr_reg <= x"00000180";
			spicr_rack_temp <= '0';
			spicr_wack_temp <= '0';
		END IF;
		
		--write
		IF (reg_write_enable = '1' and spicr_cs = '1') THEN
			i := 0;
			while (i < 4) loop
				if(reg_wstb(i) = '1') then
					--update value
					spicr_reg((i*8 + 7) downto i*8) <= reg_wdata((i*8 + 7) downto i*8);
				else
					--keep old value
					spicr_reg((i*8 + 7) downto i*8) <= spicr_reg((i*8 + 7) downto i*8);
				end if;
				i := i + 1;
			end loop;
			spicr_wack_temp <= not spicr_wack_temp;
		
		--read
		ELSIF (reg_read_enable = '1' and spicr_cs = '1') THEN
		    spicr_rdata <= spicr_reg;
			spicr_rack_temp <= not spicr_rack_temp;
        
        ELSE
            spicr_rack_temp <= '0';
            spicr_wack_temp <= '0';
			
		END IF;
		
	END IF;

END PROCESS;

END behave;