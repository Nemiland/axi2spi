--Author: Devon Stedronsky
--Date: May 2020
--
--Description: Register Module for AXI to SPI Controller
--SPI Slave Select Register     --R/W   --One Hot Encoded Slave Select


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SPISSR IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32;
	            C_NUM_SS_BITS : integer := 1	);
				
    Port (
			reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			
			spissr_cs		:	in	std_logic;
			
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			spissr_wack			:	out		std_logic;
			
			reg_read_enable		:	in		std_logic;
			spissr_rack			:	out 	std_logic;
			spissr_rdata        :   out     std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			
			slave_select		:	out		std_logic_vector ((C_NUM_SS_BITS - 1) downto 0)
			
			);
END SPISSR;

ARCHITECTURE behave OF SPISSR IS

SIGNAL spissr_reg : std_logic_vector (31 downto 0) := x"11111111";
SIGNAL spissr_rack_temp, spissr_wack_temp : std_logic := '0';

BEGIN

--slave select set to active section of register
slave_select <= spissr_reg((C_NUM_SS_BITS - 1) downto 0);
spissr_rack <= spissr_rack_temp;
spissr_wack <= spissr_wack_temp;

PROCESS (reg_clk, reg_rst)
variable i : integer range 0 to ((C_S_AXI_DATA_WIDTH / 8) - 1) := 0;
BEGIN

	IF (rising_edge(reg_clk)) THEN
	   
	   --reset
		IF (reg_rst = '1') THEN
			spissr_reg <= x"11111111";
			spissr_rack_temp <= '0';
			spissr_wack_temp <= '0';
		END IF;
		
		--write
		IF (reg_write_enable = '1' and spissr_cs = '1') THEN
			i := 0;
			while (i < 4) loop
				if(reg_wstb(i) = '1') then
					--update value
					spissr_reg((i*8 + 7) downto i*8) <= reg_wdata((i*8 + 7) downto i*8);
				else
					--keep old value
					spissr_reg((i*8 + 7) downto i*8) <= spissr_reg((i*8 + 7) downto i*8);
				end if;
				i := i + 1;
			end loop;
			spissr_wack_temp <= not spissr_wack_temp;
		
		--read	
	   ELSIF (reg_read_enable = '1' and spissr_cs = '1') THEN
			spissr_rdata <= spissr_reg;
			spissr_rack_temp <= not spissr_rack_temp;
		
		--no operation	
        ELSE
        spissr_rack_temp <= '0';
        spissr_wack_temp <= '0';
		END IF;
		
		
		END IF;

END PROCESS;


END behave;