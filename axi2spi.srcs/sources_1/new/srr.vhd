--Description: SRR Module for AXI to SPI Controller
--Software reset register
--Write only --accepts 0000 000A to set soft reset signal


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SRR IS
    Generic	( C_S_AXI_DATA_WIDTH : integer := 32	);
				
    Port (
			reg_clk  :	in	std_logic;
			reg_rst  :	in 	std_logic;
			
			srr_cs   :	in	std_logic;
			
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			srr_wack			:	out		std_logic;
			srr_werror			:	out 	std_logic;
			
			soft_reset			:	out		std_logic
			);
END SRR;

ARCHITECTURE behave OF SRR IS

--Register and temp signals
signal srr_reg, srr_reg_temp : std_logic_vector (31 downto 0) := x"00000000";
signal srr_wack_temp, srr_werror_temp : std_logic := '0';

BEGIN

--Main Process
PROCESS (reg_clk, reg_rst)

--strobe counter
variable i : integer range 0 to ((C_S_AXI_DATA_WIDTH / 8) - 1) := 0;

BEGIN

--
srr_wack <= srr_wack_temp;
srr_werror <= srr_werror_temp;

    IF (rising_edge(reg_clk)) THEN
	
		--reset
		IF (reg_rst = '1') THEN
			srr_reg <= x"00000000";
			srr_werror_temp <= '0';
			soft_reset <= '0';
			srr_wack_temp <= '0';
		END IF;
		
		--write strobe
		IF (reg_write_enable = '1' and srr_cs = '1') THEN  
			i := 0;
			while (i < 4) loop
				if(reg_wstb(i) = '1') then
					--update value
					srr_reg_temp((i*8 + 7) downto i*8) <= reg_wdata((i*8 + 7) downto i*8);
				else
					--keep old value
					srr_reg_temp((i*8 + 7) downto i*8) <= srr_reg((i*8 + 7) downto i*8);
				end if;
				i := i + 1;
			end loop;
			
			srr_wack_temp <= not srr_wack_temp;
		      
		      --soft reset value error check
		      IF (srr_reg_temp (31 downto 0) = x"0000000A") THEN
		        srr_reg <= srr_reg_temp;
				soft_reset <= '1';
				srr_werror_temp <= '0';
			  ELSIF (srr_reg_temp (31 downto 0) = x"00000000") THEN
			    srr_reg <= srr_reg_temp;
				soft_reset <= '0';
				srr_werror_temp <= '0';
			  ELSE
			    srr_reg <= (others => '0');
				srr_werror_temp <= not srr_werror_temp;
				soft_reset <= '0';
			  END IF;
			  
		ELSE
		srr_wack_temp <= '0';	
		srr_werror <= '0';
		
		END IF;
    END IF;
	
END PROCESS;

END behave;