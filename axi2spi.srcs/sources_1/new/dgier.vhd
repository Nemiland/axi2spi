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
			reg_rdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			reg_rack			:	out 	std_logic;
			
			--global interrupt enable signal
			gi_en				:	out 	std_logic;
			
			reg_werror			:	out 	std_logic;
			reg_rerror			:	out		std_logic;
			
			
			
			);
END DGIER;

ARCHITECTURE behave OF DGIER IS

SIGNAL dgier_reg : std_logic_vector (31 downto 0) := (others => '0');
SIGNAL masked_wdata : std_logic_vector (C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
BEGIN

gi_en <= dgier_reg (31);

PROCESS (reg_clk, reg_rst)
variable i : integer range 0 to ((C_S_AXI_DATA_WIDTH / 8) - 1) := 0;
BEGIN

	IF (rising_edge(reg_clk) ) THEN
	
		IF (reg_rst = '1') THEN
			dgier_reg <= (others => '0')& X"00000000";
			reg_rack <= '0';
			reg_wack <= '0';
			i := 0;
		END IF;
		
		IF (reg_read_enable = '1' and dgier_cs = '1') THEN
			reg_rdata <= (others => '0') & dgier_reg; 
			reg_rack <= not reg_rack;
			
		ELSIF (reg_write_enable = '1' and dgier_cs = '1') THEN
			i := 0;
			while (i < 4) loop
				if(reg_wstb(i) = '1') then
					--update value
					dgier_reg((i*8 + 7) downto i*8) <= reg_wdata((i*8 + 7) downto i*8);
				else
					--keep old value
					dgier_reg((i*8 + 7) downto i*8) <= dgier_reg((i*8 + 7) downto i*8);
				end if;
				i := i + 1;
			end loop;
			reg_wack <= not reg_wack;
		ELSE
			--no read and no write
			reg_rack <= '0';
			reg_wack <= '0';
		END IF;
	END IF;

END PROCESS;

END behave;