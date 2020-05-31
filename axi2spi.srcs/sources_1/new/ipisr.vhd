--Description: IPISR Module for AXI to SPI Controller
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
			
			--interrupt inputs from SPI
			drr_not_empty			: 	in		std_logic;
			slave_mode_select		: 	in		std_logic;
			tx_fifo_half			: 	in		std_logic;
			drr_overrun				: 	in		std_logic;
			drr_full				: 	in		std_logic;
			dtr_underrun			: 	in		std_logic;
			dtr_empty				: 	in		std_logic;
			slave_mode_fault_error	: 	in		std_logic;
			mode_fault_error		: 	in		std_logic;
			
			--interrupt enable inputs from IPIER
			Drr_not_empty_int_en	:	in		std_logic;
			Ss_mode_int_en			:	in		std_logic;
			Tx_fifo_half_int_en		:	in		std_logic;
			Drr_overrun_int_en		:	in		std_logic;
			Drr_full_int_en			:	in		std_logic;
			Dtr_underrun_int_en		:	in		std_logic;
			Dtr_empty_int_en		:	in		std_logic;
			Slave_mode_fault_int_en	:	in		std_logic;
			Mode_fault_int_en		:	in		std_logic	
			);
END IPISR;

ARCHITECTURE behave OF IPISR IS

SIGNAL ipisr_reg, ipisr_reg_temp : std_logic_vector (31 downto 0) := x"00000000";
SIGNAL ipisr_rack_temp, ipisr_wack_temp : std_logic := '0';
SIGNAL enable_vector, interrupt_vector : std_logic_vector (8 downto 0) := (others => '0');


BEGIN
		
ipisr_rack <= ipisr_rack_temp;
ipisr_wack <= ipisr_wack_temp;

--interrupt enable signals vector
enable_vector <= Drr_not_empty_int_en & Ss_mode_int_en & Tx_fifo_half_int_en &
                 Drr_overrun_int_en & Drr_full_int_en & Dtr_underrun_int_en &
                 Dtr_empty_int_en & Slave_mode_fault_int_en & Mode_fault_int_en;

--vector of SPI interrupt signals                 
interrupt_vector <= drr_not_empty & slave_mode_select & tx_fifo_half & drr_overrun & drr_full &
                        dtr_underrun & dtr_empty & slave_mode_fault_error & mode_fault_error;


PROCESS (reg_clk, reg_rst)
variable i : integer range 0 to ((C_S_AXI_DATA_WIDTH / 8) - 1) := 0;
variable k, j : integer range 0 to 8 := 0;
BEGIN

	IF (rising_edge(reg_clk)) THEN
	
	   --TOW from SPI inputs
	    j := 0;
	    while (j < 9) loop
	       if (enable_vector(j) = '1' and interrupt_vector(j) = '1') then
	           ipisr_reg (j) <= not ipisr_reg (j);
	       else
	           ipisr_reg (j) <= ipisr_reg (j);
	       end if;
	       j := j + 1;
	    end loop;
	    
	    
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
			
			--TOW from AXI BUS
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