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
	reg_clk 	: in std_logic;
	spi_clk		: in std_logic;
	reset		: in std_logic;
	
    --SRR (REG -> SPI)
    soft_reset : out STD_LOGIC;
    soft_reset_i : in STD_LOGIC;
				
    --SPICR (REG -> SPI)
    Lsb_first			:	out		std_logic;
    Master_inhibit		:	out		std_logic;
    Manual_ss_en		:	out		std_logic;
    Rx_fifo_reset		:	out		std_logic;
    Tx_fifo_reset		:	out		std_logic;
    Cpha				:	out		std_logic;
    Cpol				:	out		std_logic;
    Spi_master_en		:	out		std_logic;
    Spi_system_en		:	out		std_logic;
    Loopback_en			:	out		std_logic;
    -----------------------------------------------
    Lsb_first_i			:	in		std_logic;
    Master_inhibit_i	:	in		std_logic;
    Manual_ss_en_i		:	in		std_logic;
    Rx_fifo_reset_i		:	in		std_logic;
    Tx_fifo_reset_i		:	in		std_logic;
    Cpha_i				:	in		std_logic;
    Cpol_i				:	in		std_logic;
    Spi_master_en_i		:	in		std_logic;
    Spi_system_en_i		:	in		std_logic;
    Loopback_en_i		:	in		std_logic;

    --SPISR (SPI -> REG)
    --slave_mode_select	:	out 		std_logic;
    --mode_fault_error	:	out		std_logic;
    tx_full				:	out		std_logic;
    tx_empty			:	out		std_logic;
    rx_full				:	out		std_logic;
    rx_empty			:	out		std_logic;
    --slave_mode_select_i	:	in 		std_logic;
    --mode_fault_error_i	:	in		std_logic;
    tx_full_i				:	in		std_logic;
    tx_empty_i			    :	in		std_logic;
    rx_full_i				:	in		std_logic;
    rx_empty_i			    :	in		std_logic;
				
    --SPISSR (REG -> SPI)
    slave_select		:	out		std_logic_vector ((C_NUM_SS_BITS - 1) downto 0);
    slave_select_i		:	in		std_logic_vector ((C_NUM_SS_BITS - 1) downto 0);

--SPI INTERFACE PORTS				
--slave_mode_select : out STD_LOGIC;
--mode_fault_error : out STD_LOGIC;
--slave_mode_fault_error : out STD_LOGIC;

    --Interrupt Registers (REG -> SPI)
    gi_en				    :	out 	std_logic;
    drr_not_empty			: 	out		std_logic;
    --slave_mode_select		: 	out		std_logic;
    tx_fifo_half			: 	out		std_logic;
    drr_overrun				: 	out		std_logic;
    drr_full				: 	out		std_logic;
    dtr_underrun			: 	out		std_logic;
    dtr_empty				: 	out		std_logic;
    slave_mode_fault_error	: 	out		std_logic;
    --mode_fault_error		: 	out		std_logic;
    Drr_not_empty_int_en	:	out		std_logic;
    ss_mode_fault_int_en	:	out		std_logic;
    Tx_fifo_half_int_en		:	out		std_logic;
    Drr_overrun_int_en		:	out		std_logic;
    Drr_full_int_en			:	out		std_logic;
    Dtr_underrun_int_en		:	out		std_logic;
    Dtr_empty_int_en		:	out		std_logic;
    Slave_mode_fault_int_en	:	out		std_logic;
    Mode_fault_int_en		:	out		std_logic;
    ------------------------------------------------------
    gi_en_i				     :	in 	std_logic;
    drr_not_empty_i			 : 	in		std_logic;
    --slave_mode_select_i	 : 	in		std_logic;
    tx_fifo_half_i			 : 	in		std_logic;
    drr_overrun_i		     : 	in		std_logic;
    drr_full_i				 : 	in		std_logic;
    dtr_underrun_i			 : 	in		std_logic;
    dtr_empty_i				 : 	in		std_logic;
    slave_mode_fault_error_i : 	in		std_logic;
    --mode_fault_error_i	 : 	in		std_logic;
    Drr_not_empty_int_en_i	 :	in		std_logic;
    ss_mode_fault_int_en_i	 :	in		std_logic;
    Tx_fifo_half_int_en_i	 :	in		std_logic;
    Drr_overrun_int_en_i	 :	in		std_logic;
    Drr_full_int_en_i		 :	in		std_logic;
    Dtr_underrun_int_en_i	 :	in		std_logic;
    Dtr_empty_int_en_i		 :	in		std_logic;
    Slave_mode_fault_int_en_i   :	in		std_logic;
    Mode_fault_int_en_i		    :	in		std_logic;
	

	--TX DATA (REG -> SPI)
	tx_data    : out std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
	tx_data_i  : in std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
	
	--RX DATA (SPI -> REG)
	rx_data    : out std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
	rx_data_i  : in std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
	
	--FIFO I/O
	rx_w_enable       : in std_logic;
	rx_r_enable       : in std_logic;
	rx_empty_flag     : out std_logic;
	rx_full_flag      : out std_logic;
	rx_occupancy      : out std_logic_vector (3 downto 0);		
	tx_w_enable       : in std_logic;
	tx_r_enable       : in std_logic;
    tx_full_flag      : out std_logic;
    tx_empty_flag     : out std_logic;
	tx_occupancy      : out std_logic_vector (3 downto 0)
		);
		
end SYNCH_WRAPPER;

architecture behavior of SYNCH_WRAPPER is

--FIFO component
component AXI2SPI_AFIFO is
generic (
			C_NUM_TRANSFER_BITS : integer := 32
		);
		
port( 
		wdata : 						in std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
		w_enable, r_enable, reset : 	in std_logic;
		wclk, rclk : 					in std_logic;
		rdata : 						out std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
		full_flag, empty_flag : 		out std_logic;
		occupancy : 					out std_logic_vector (3 downto 0)
	);
end component;


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
	
	SIGNAL rx_data_temp                     : STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1)  downto 0);
	SIGNAL tx_data_temp                     : STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1)  downto 0);

begin

    --FIFO INSTANTIATIONS
    RX_FIFO_inst : AXI2SPI_AFIFO
    generic map (C_NUM_TRANSFER_BITS => C_NUM_TRANSFER_BITS)
    port map (  wdata => rx_data_i,
		        w_enable => rx_w_enable, 
		        r_enable => rx_r_enable, 
		        reset => reset,
		        wclk => spi_clk, 
		        rclk => reg_clk,
		        rdata => rx_data,
		        full_flag => rx_full, 
		        empty_flag => rx_empty_flag,
		        occupancy => rx_occupancy                             );
    
    TX_FIFO_inst : AXI2SPI_AFIFO
    generic map (C_NUM_TRANSFER_BITS => C_NUM_TRANSFER_BITS)
    port map ( wdata => tx_data_i,
		       w_enable => tx_w_enable, 
		       r_enable => tx_r_enable, 
		       reset => reset,
		       wclk => reg_clk, 
		       rclk => spi_clk,
		       rdata => tx_data,
		       full_flag => tx_full_flag, 
		       empty_flag => tx_empty, 
		       occupancy => tx_occupancy                              );
    
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
	slave_mode_select <= '1';
	slave_select_mode_sync <= '1';
	ss_mode_fault_int_en <= '0';
	ss_mode_fault_int_en_sync <= '0';
	slave_mode_fault_int_en <= '0';
	slave_mode_fault_int_en_sync <= '0';
    else
	
		--syncrhonization
        if rising_edge(spi_clk) then
        	
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
			
			slave_mode_select_sync <= slave_select_mode_i;
			slave_mode_select <= slave_select_mode_sync;
			
			ss_mode_fault_int_en_sync <= ss_mode_fault_int_en_i;
			ss_mode_fault_int_en <= ss_mode_fault_int_en_sync;
			
			slave_mode_fault_int_en_sync <= slave_mode_fault_int_en_i;
			slave_mode_fault_int_en <= slave_mode_fault_int_en_sync;
			
        end if;
    end if;
end process;

--FIFO GENERATION
process (spi_clk, reg_clk, reset)
begin

if (C_FIFO_EXIST = '0') then
    if reset = '1' then
        tx_data <= (others => '0');
	    tx_data_sync <= (others => '0');
	    rx_data <= (others => '0');
	    rx_data_sync <= (others => '0');
	    
	elsif (rising_edge(spi_clk)) then
	    tx_data_sync <= tx_data_i;
		tx_data <= tx_data_sync;
		
    elsif (rising_edge(reg_clk)) then
        rx_data_sync <= rx_data_i;
		rx_data <= rx_data_sync;
    end if;


elsif (C_FIFO_EXIST = '1') then
   
end if;
end process;

end behavior;
