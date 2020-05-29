--Description: IPIER Module for AXI to SPI Controller
--IP Interrupt Enable Register  --R/W
--Individual interrupt enable signals written from AXI to enable latching in IPISR


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
			ipier_wack			:	out		std_logic;
			
			reg_read_enable		:	in		std_logic;
			ipier_rack			:	out 	std_logic;
			ipier_rdata         :	out		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			
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

SIGNAL ipier_reg : std_logic_vector (31 downto 0) := x"00000000";
SIGNAL ipier_rack_temp, ipier_wack_temp : std_logic := '0';

BEGIN
            --output signals set to register bits
			Drr_not_empty_int_en 	<= ipier_reg (8);
			Ss_mode_int_en			<= ipier_reg (7);
			Tx_fifo_half_int_en 	<= ipier_reg (6);
			Drr_overrun_int_en		<= ipier_reg (5);
			Drr_full_int_en			<= ipier_reg (4);
			Dtr_underrun_int_en		<= ipier_reg (3);
			Dtr_empty_int_en		<= ipier_reg (2);
			Slave_mode_fault_int_en	<= ipier_reg (1);
			Mode_fault_int_en		<= ipier_reg (0);
			
			ipier_rack <= ipier_rack_temp;
			ipier_wack <= ipier_wack_temp;
			
PROCESS (reg_clk, reg_rst)
variable i : integer range 0 to ((C_S_AXI_DATA_WIDTH / 8) - 1) := 0;
BEGIN

	IF (rising_edge(reg_clk)) THEN
	
		IF (reg_rst = '1') THEN
			ipier_reg <= x"00000000";
			ipier_rack_temp <= '0';
			ipier_wack_temp <= '0';
		END IF;
		
		--WRITE
		IF (reg_write_enable <= '1' and ipier_cs = '1') THEN
            i := 0;
			while (i < 4) loop
				if(reg_wstb(i) = '1') then
					--update value
					ipier_reg((i*8 + 7) downto i*8) <= reg_wdata((i*8 + 7) downto i*8);
				else
					--keep old value
					ipier_reg((i*8 + 7) downto i*8) <= ipier_reg((i*8 + 7) downto i*8);
				end if;
				i := i + 1;
			end loop;
			ipier_wack_temp <= not ipier_wack_temp;
		
		--READ
		ELSIF (reg_read_enable <= '1' and ipier_cs = '1') THEN
		    ipier_rdata <= ipier_reg;
			ipier_rack_temp <= not ipier_rack_temp;
			
			
	   ELSE
	   ipier_wack_temp <= '0';
	   ipier_rack_temp <= '0';
	   END IF;
	END IF;

END PROCESS;

END behave;