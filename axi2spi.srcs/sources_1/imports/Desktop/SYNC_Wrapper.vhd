--Author: Devon Stedronsky
--Date: April 2020
--
--Description : AXI2SPI FIFO/DOUBLE SYNCHRONIZER WRAPPER


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity SYNCH_WRAPPER is
generic (
			C_FIFO_EXIST : std_logic := '0';
			C_NUM_SS_BITS : integer := 1;
			C_NUM_TRANSFER_BITS : integer := 32
		);
		
port( 
	--CLOCK SIGNALS
	reg_clk 					: in std_logic;
	spi_clk						: in std_logic;
	reset						: in std_logic;
	
			
	--REG to SPI_IF
	tx_data 					: out STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1) downto 0);
	lsb_first 					: out STD_LOGIC;
	master_inhibit 				: out STD_LOGIC;
	manual_ss_en				: out STD_LOGIC;
	cpha 						: out STD_LOGIC;
	cpol 						: out STD_LOGIC;
	spi_master_en 				: out STD_LOGIC;
	loopback_en 				: out STD_LOGIC;
	tx_empty 					: out STD_LOGIC;
	rx_full 					: out STD_LOGIC;
	slave_select 				: out STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
	gi_en 						: out STD_LOGIC;
	slave_select_mode 			: out STD_LOGIC;
	ss_mode_fault_int_en 		: out STD_LOGIC;
	slave_mode_fault_int_en 	: out STD_LOGIC;
	
	tx_data_i 					: in STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1) downto 0);
	lsb_first_i 				: in STD_LOGIC;
	master_inhibit_i			: in STD_LOGIC;
	manual_ss_en_i				: in STD_LOGIC;
	cpha_i 						: in STD_LOGIC;
	cpol_i 						: in STD_LOGIC;
	spi_master_en_i 			: in STD_LOGIC;
	loopback_en_i 				: in STD_LOGIC;
	tx_empty_i 					: in STD_LOGIC;
	rx_full_i 					: in STD_LOGIC;
	slave_select_i 				: in STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
	gi_en_i 					: in STD_LOGIC;
	slave_select_mode_i 		: in STD_LOGIC;
	ss_mode_fault_int_en_i 		: in STD_LOGIC;
	slave_mode_fault_int_en_i 	: in STD_LOGIC;
	
	--SPI_IF to REG
	rx_data 					: out STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1)  downto 0);
	mode_fault_error 			: out STD_LOGIC;
	slave_mode_select 			: out STD_LOGIC;	
	slave_mode_fault_error 		: out STD_LOGIC;
	
	rx_data_i 					: in STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1)  downto 0);
	mode_fault_error_i 			: in STD_LOGIC;
	slave_mode_select_i 		: in STD_LOGIC;
	slave_mode_fault_error_i 	: in STD_LOGIC
		);
		
end SYNCH_WRAPPER;

architecture behavior of SYNCH_WRAPPER is

--TEMP SIGNALS
	SIGNAL tx_data_sync 					: STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1) downto 0);
	SIGNAL lsb_first_sync  					: STD_LOGIC;
	SIGNAL master_inhibit_sync  			: STD_LOGIC;
	SIGNAL manual_ss_en_sync 				: STD_LOGIC;
	SIGNAL cpha_sync  						: STD_LOGIC;
	SIGNAL cpol_sync  						: STD_LOGIC;
	SIGNAL spi_master_en_sync  				: STD_LOGIC;
	SIGNAL loopback_en_sync  				: STD_LOGIC;
	SIGNAL tx_empty_sync  					: STD_LOGIC;
	SIGNAL rx_full_sync  					: STD_LOGIC;
	SIGNAL slave_select_sync  				: STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
	SIGNAL gi_en_sync  						: STD_LOGIC;
	SIGNAL slave_select_mode_sync  			: STD_LOGIC;
	SIGNAL ss_mode_fault_int_en_sync  		: STD_LOGIC;
	SIGNAL slave_mode_fault_int_en_sync  	: STD_LOGIC;
	
	SIGNAL rx_data_sync  					: STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1)  downto 0);
	SIGNAL mode_fault_error_sync  			: STD_LOGIC;
	SIGNAL slave_mode_select_sync  			: STD_LOGIC;
	SIGNAL slave_mode_fault_error_sync  	: STD_LOGIC;

begin
--Synchronization of SPI to REG signals
process (reg_clk, reset)
begin
	--reset to default register values
    if reset = '1' then
		rx_data <= (others => '0');
		rx_data_sync <= (others => '0');
		mode_fault_error <= '0';
		mode_fault_error_sync <= '0';
		slave_mode_select <= '1';
		slave_mode_select_sync <= '1';
		slave_mode_fault_error <= '0';
		slave_mode_fault_error_sync <= '0';
    else
		
		--synchronization
        if rising_edge(reg_clk) then
		
            rx_data_sync <= rx_data_i;
			rx_data <= rx_data_sync;
			
			mode_fault_error_sync <= mode_fault_error_i;
			mode_fault_error <= mode_fault_error_sync;
			
			slave_mode_select_sync <= slave_mode_select_i;
			slave_mode_select <= slave_mode_select_sync;
			
			slave_mode_fault_error_sync <= slave_mode_fault_error_i;
			slave_mode_fault_error <= slave_mode_fault_error_sync;
			
        end if;
    end if;
end process;

--Synchronization of REG to SPI signals
process (spi_clk, reset)
begin
	--reset to default register values
    if reset = '1' then	
	tx_data <= (others => '0');
	tx_data_sync <= (others => '0');
	lsb_first <= '0';
	lsb_first_sync <= '0';
	master_inhibit <= '1';
	master_inhibit_sync <= '1';
	manual_ss_en <= '1';
	manual_ss_en_sync <= '1';
	cpha <= '0';
	cpha_sync <= '0';
	cpol <= '0';
	cpol_sync <= '0';
	spi_master_en <= '0';
	spi_master_en_sync <= '0';
	loopback_en <= '0';
	loopback_en_sync <= '0';
	tx_empty <= '1';
	tx_empty_sync <= '1';
	rx_full <= '0';
	rx_full_sync <= '0';
	slave_select <= (others => '1');
	slave_select_sync <= (others => '1');
	gi_en <= '0';
	gi_en_sync <= '0';
	slave_select_mode <= '1';
	slave_select_mode_sync <= '1';
	ss_mode_fault_int_en <= '0';
	ss_mode_fault_int_en_sync <= '0';
	slave_mode_fault_int_en <= '0';
	slave_mode_fault_int_en_sync <= '0';
    else
	
		--syncrhonization
        if rising_edge(spi_clk) then
        
            tx_data_sync <= tx_data_i;
			tx_data <= tx_data_sync;
			
			lsb_first_sync <= lsb_first_i;
			lsb_first <= lsb_first_sync;
			
			master_inhibit_sync <= master_inhibit_i;
			master_inhibit <= master_inhibit_sync;
			
			manual_ss_en_sync <= manual_ss_en_i;
			manual_ss_en <= manual_ss_en_sync;
			
			cpha_sync <= cpha_i;
			cpha <= cpha_sync;
			
			cpol_sync <= cpol_i;
			cpol <= cpol_sync;
			
			spi_master_en_sync <= spi_master_en_i;
			spi_master_en <= spi_master_en_sync;
			
			loopback_en_sync <= loopback_en_i;
			loopback_en <= loopback_en_sync;
			
			tx_empty_sync <= tx_empty_i;
			tx_empty <= tx_empty_sync;
			
			rx_full_sync <= rx_full_i;
			rx_full <= rx_full_sync;

			slave_select_sync <= slave_select_i;
			slave_select <= slave_select_sync;

			gi_en_sync <= gi_en_i;
			gi_en <= gi_en_sync;
			
			slave_select_mode_sync <= slave_select_mode_i;
			slave_select_mode <= slave_select_mode_sync;
			
			ss_mode_fault_int_en_sync <= ss_mode_fault_int_en_i;
			ss_mode_fault_int_en <= ss_mode_fault_int_en_sync;
			
			slave_mode_fault_int_en_sync <= slave_mode_fault_int_en_i;
			slave_mode_fault_int_en <= slave_mode_fault_int_en_sync;
			
        end if;
    end if;
end process;

end behavior;
