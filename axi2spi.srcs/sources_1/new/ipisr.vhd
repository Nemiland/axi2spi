--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller
--IP Interrupt Status Register      --R/TOW


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
			ipisr_wack			:	out		std_logic;
			
			reg_read_enable		:	in		std_logic;
			ipisr_rack			:	out 	std_logic;
			ipisr_rdata         :   out     std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			
			drr_not_empty			: 	out		std_logic;
			slave_mode_select		: 	out		std_logic;
			tx_fifo_half			: 	out		std_logic;
			drr_overrun				: 	out		std_logic;
			drr_full				: 	out		std_logic;
			dtr_underrun			: 	out		std_logic;
			dtr_empty				: 	out		std_logic;
			slave_mode_fault_error	: 	out		std_logic;
			mode_fault_error		: 	out		std_logic
				
			);
END IPISR;

ARCHITECTURE behave OF IPISR IS

SIGNAL ipisr_reg, ipisr_reg_temp : std_logic_vector (31 downto 0) := x"00000000";
SIGNAL ipisr_rack_temp, ipisr_wack_temp : std_logic := '0';

BEGIN
        --output signals set to register bits
		drr_not_empty 		<= ipisr_reg (8);
		slave_mode_select 	<= ipisr_reg (7);
		tx_fifo_half		<= ipisr_reg (6);
		drr_overrun			<= ipisr_reg (5);
		drr_full			<= ipisr_reg (4);
		dtr_underrun		<= ipisr_reg (3);
		dtr_empty				 <= ipisr_reg (2);
		slave_mode_fault_error	 <= ipisr_reg (1);
		mode_fault_error		 <= ipisr_reg (0);
		
ipisr_rack <= ipisr_rack_temp;
ipisr_wack <= ipisr_wack_temp;

PROCESS (reg_clk, reg_rst)
variable i : integer range 0 to ((C_S_AXI_DATA_WIDTH / 8) - 1) := 0;
variable k : integer range 0 to 8 := 0;
BEGIN

	IF (rising_edge(reg_clk)) THEN
	
		IF (reg_rst = '1') THEN
			ipisr_reg <= x"00000000";
			ipisr_wack_temp <= '0';
			ipisr_rack_temp <= '0';
		END IF;
		
		--TOW
		IF (reg_write_enable = '1' and ipisr_cs = '1') THEN
		      
		    --WSTB loop
            i := 0;
			while (i < 4) loop
				if(reg_wstb(i) = '1') then
					--update value
					ipisr_reg_temp((i*8 + 7) downto i*8) <= reg_wdata((i*8 + 7) downto i*8);
				else
					--keep old value
					ipisr_reg_temp((i*8 + 7) downto i*8) <= ipisr_reg_temp((i*8 + 7) downto i*8);
				end if;
				i := i + 1;
			end loop;
			
			--TOW loop
			k := 0;
			while (k < 9) loop
			     if (ipisr_reg_temp (k) = '1') THEN
			         ipisr_reg (k) <= not ipisr_reg (k);
			     else
			         ipisr_reg(k) <= ipisr_reg(k);
			     end if;
			     k := k + 1;
			end loop;

		--READ
		ELSIF (reg_read_enable = '1' and ipisr_cs = '1') THEN
            ipisr_rdata <= ipisr_reg;
		      ipisr_rack_temp <= not ipisr_rack_temp;
		
		--no operation      
		ELSE
		ipisr_rack_temp <= '0';
		ipisr_wack_temp <= '0';

		END IF;
		
	END IF;

END PROCESS;

END behave;