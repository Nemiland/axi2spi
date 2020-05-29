--Description : AXI2SPI FIFO/DOUBLE SYNCHRONIZER AND FIFO MODULE WRAPPER


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
	
--REGISTER / SPI IO
    --SRR (REG -> SPI)
    soft_reset : out STD_LOGIC;
    soft_reset_i : in STD_LOGIC;
				
    --SPICR (REG -> SPI)
    Lsb_first			:	out		std_logic;
    Master_inhibit		:	out		std_logic;
    Manual_ss_en		:	out		std_logic;
    --Rx_fifo_reset		:	out		std_logic;      --Reg input bit mapped to FIFO
    --Tx_fifo_reset		:	out		std_logic;      --Reg input bit mapped to FIFO
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
    Tx_fifo_reset_i		:	in		std_logic;      --mapped to FIFO
    Cpha_i				:	in		std_logic;      --mapped to FIFO
    Cpol_i				:	in		std_logic;
    Spi_master_en_i		:	in		std_logic;
    Spi_system_en_i		:	in		std_logic;
    Loopback_en_i		:	in		std_logic;
    
    --SPISR (FIFO outputs to REG and SPI)
    tx_full				:	out		std_logic;
    tx_empty			:	out		std_logic;
    rx_full				:	out		std_logic;
    rx_empty			:	out		std_logic;
    
    --TX DATA (REG -> SPI) SYNC HANDLED BY FIFO
	tx_data    : out std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
	tx_data_i  : in std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
	
	--RX DATA (SPI -> REG) SYNC HANDLED BY FIFO
	rx_data    : out std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
	rx_data_i  : in std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
    		
    --SPISSR (REG -> SPI)
    slave_select		:	out		std_logic_vector ((C_NUM_SS_BITS - 1) downto 0);
    slave_select_i		:	in		std_logic_vector ((C_NUM_SS_BITS - 1) downto 0);

    --DGIER (REG -> SPI)
    gi_en				     :	out 	std_logic;
    gi_en_i				     :	in 	std_logic;
    
    --IPISR     (SPI -> REG)
	drr_not_empty_i			    : 	in		std_logic;
	slave_mode_select_i		    : 	in		std_logic;
	--tx_fifo_half_i			: 	in		std_logic;       --reg output mapped from FIFO
	drr_overrun_i				: 	in		std_logic;
	drr_full_i				    : 	in		std_logic;
	dtr_underrun_i			    : 	in		std_logic;
	dtr_empty_i				    : 	in		std_logic;
	slave_mode_fault_error_i	: 	in		std_logic;
	mode_fault_error_i		    : 	in		std_logic;
	------------------------------------------------
	drr_not_empty			: 	out		std_logic;
	slave_mode_select		: 	out		std_logic;
	tx_fifo_half			: 	out		std_logic;      --mapped from FIFO
	drr_overrun				: 	out		std_logic;
	drr_full				: 	out		std_logic;
	dtr_underrun			: 	out		std_logic;
	dtr_empty				: 	out		std_logic;
	slave_mode_fault_error	: 	out		std_logic;
	mode_fault_error		: 	out		std_logic;
    
            --IPIER MAPPED INTERNAL IN REG_WRAPPER
    
	--FIFO I/O
	rx_w_enable       : in std_logic;
	rx_r_enable       : in std_logic;
	rx_occupancy      : out std_logic_vector (3 downto 0);		
	tx_w_enable       : in std_logic;
	tx_r_enable       : in std_logic;
	tx_occupancy      : out std_logic_vector (3 downto 0)
		);
		
end SYNCH_WRAPPER;

architecture behavior of SYNCH_WRAPPER is

-----------------------------------------------------------------------------------------
--FIFO component
component AXI2SPI_AFIFO is
generic (   C_NUM_TRANSFER_BITS : integer := 32;
			C_FIFO_EXIST : std_logic := '0'          );
		
port(   wdata : 						in std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
		w_enable, r_enable, reset : 	in std_logic;
		wclk, rclk : 					in std_logic;
		rdata : 						out std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
		full_flag, empty_flag : 		out std_logic;
		occupancy : 					out std_logic_vector (3 downto 0);
		fifo_half :                     out std_logic                             );
end component;
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--TEMP SIGNALS
    --SRR to SPI
    SIGNAL soft_reset_sync                  : STD_LOGIC;
    
    --SPICR to SPI
	SIGNAL lsb_first_sync  					: STD_LOGIC;
	SIGNAL master_inhibit_sync  			: STD_LOGIC;
	SIGNAL manual_ss_en_sync 				: STD_LOGIC;
	SIGNAL cpha_sync  						: STD_LOGIC;
	SIGNAL cpol_sync  						: STD_LOGIC;
	SIGNAL Spi_system_en_sync		        : STD_LOGIC;
	SIGNAL spi_master_en_sync  				: STD_LOGIC;
	SIGNAL loopback_en_sync  				: STD_LOGIC;
	
	--FIFO to SPI
	SIGNAL tx_empty_sync  					: STD_LOGIC;
	SIGNAL rx_full_sync  					: STD_LOGIC;
	
	--SPISSR to SPI
	SIGNAL slave_select_sync  				: STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
	
	--DGIER to SPI
	SIGNAL gi_en_sync  						: STD_LOGIC;
	
	           --DATA REG to SPI MAPPED THROUGH FIFO
	
    --SPI to IPISR
	SIGNAL drr_not_empty_sync          : STD_LOGIC := '0';
	SIGNAL slave_mode_select_sync      : STD_LOGIC := '0';
	--SIGNAL tx_fifo_half_sync           : STD_LOGIC := '0';     --mapped internally with fifo
	SIGNAL drr_overrun_sync            : STD_LOGIC := '0';
	SIGNAL drr_full_sync               : STD_LOGIC := '0';
	SIGNAL dtr_underrun_sync           : STD_LOGIC := '0';
	SIGNAL dtr_empty_sync              : STD_LOGIC := '0';
	SIGNAL slave_mode_fault_error_sync : STD_LOGIC := '0';
	SIGNAL mode_fault_error_sync       : STD_LOGIC := '0';
	
	--unused ports
	SIGNAL rx_fifo_half_unused              : STD_LOGIC := '0';
--------------------------------------------------------------------------------------

begin

-----------------------------------------------------------------------------------  
--Synchronization of SPI to REG signals
process (reg_clk, reset)
begin
	--reset to default register values
    if reset = '1' then
    drr_not_empty <= '0';
    drr_not_empty_sync <= '0'; 
	slave_mode_select <= '0';
	slave_mode_select_sync <= '0';
	drr_overrun <= '0';
	drr_overrun_sync <= '0';
	drr_full <= '0';
	drr_full_sync <= '0';
	dtr_underrun <= '0';
	dtr_underrun_sync <= '0';
	dtr_empty <= '0';
	dtr_empty_sync <= '0';
	slave_mode_fault_error <= '0';
	slave_mode_fault_error_sync <= '0';
	mode_fault_error <= '0';
	mode_fault_error_sync <= '0';

    else
    
		--synchronization
        if rising_edge(reg_clk) then
	       drr_not_empty_sync <= drr_not_empty_i;
	       drr_not_empty <= drr_not_empty_sync;
	       
	       slave_mode_select_sync <= slave_mode_select_i;
	       slave_mode_select <= slave_mode_select_sync;
	       
	       drr_overrun_sync <= drr_overrun_i;
	       drr_overrun <= drr_overrun_sync;
	       
	       drr_full_sync <= drr_full_i;
	       drr_full <= drr_full_sync;
	       
	       dtr_underrun_sync <= dtr_underrun_i;
	       dtr_underrun <= dtr_underrun_sync;
	       
	       dtr_empty_sync <= dtr_empty_i;
	       dtr_empty <= dtr_empty_sync;
	       
	       slave_mode_fault_error_sync <= slave_mode_fault_error_i;
	       slave_mode_fault_error <= slave_mode_fault_error_sync;
	       
	       mode_fault_error_sync <= mode_fault_error_i;
	       mode_fault_error <= mode_fault_error_sync;
	       
        end if;
    end if;
end process;
-----------------------------------------------------------------------------------
--Synchronization of REG to SPI signals
process (spi_clk, reset)
begin
	--reset to default register values
    if reset = '1' then	
    
    soft_reset <= '0';
    soft_reset_sync <= '0';
	
    Lsb_first <= '0';
    Lsb_first_sync <= '0';
    Master_inhibit <= '1';
    Master_inhibit_sync <= '1';
    Manual_ss_en <= '1';
    Manual_ss_en_sync <= '1';
    Cpha <= '0';
    Cpha_sync <= '0';
    Cpol <= '0';
    Cpol_sync <= '0';
    Spi_master_en <= '0';
    Spi_master_en_sync <= '0';
    Spi_system_en <= '0';
    Spi_system_en_sync <= '0';
    Loopback_en <= '0';
    Loopback_en_sync <= '0';

    slave_select <= (others => '1');
    slave_select_sync <= (others => '1');

    gi_en <= '0';
    gi_en_sync <= '0';
    
    
    else
	
		--syncrhonization
        if rising_edge(spi_clk) then

        soft_reset_sync <= soft_reset_i;
        soft_reset <= soft_reset_sync;
        
        Lsb_first_sync <= Lsb_first_i;
        Lsb_first <= Lsb_first_sync;
        
        Master_inhibit_sync <= Master_inhibit_i;
        Master_inhibit <= Master_inhibit_sync;
        
        Manual_ss_en_sync <= Manual_ss_en_i;
        Manual_ss_en <= Manual_ss_en_sync;
        
        Cpha_sync <= Cpha_i;
        Cpha <= Cpha_sync;
        
        Cpol_sync <= Cpol_i;
        Cpol <= Cpol_sync;
        
        Spi_master_en_sync <= Spi_master_en_i;
        Spi_master_en <= Spi_master_en_sync;
        
        Spi_system_en_sync <= Spi_system_en_i;
        Spi_system_en <= Spi_system_en_sync;
        
        Loopback_en_sync <= Loopback_en_i;
        Loopback_en <= Loopback_en_sync;
        
        slave_select_sync <= slave_select_i;
        slave_select <= slave_select_sync;
        
        gi_en_sync <= gi_en_i;
        gi_en <= gi_en_sync;
			
        end if;
    end if;
end process;

---------------------------------------------------------------------------------------------
  --FIFO INSTANTIATIONS
    RX_FIFO_inst : AXI2SPI_AFIFO
    generic map (C_NUM_TRANSFER_BITS => C_NUM_TRANSFER_BITS, C_FIFO_EXIST => C_FIFO_EXIST)
    port map (  wdata => rx_data_i,
		        w_enable => rx_w_enable, 
		        r_enable => rx_r_enable, 
		        reset => Rx_fifo_reset_i,
		        wclk => spi_clk, 
		        rclk => reg_clk,
		        rdata => rx_data,
		        full_flag => rx_full, 
		        empty_flag => rx_empty,
		        occupancy => rx_occupancy,
		        fifo_half => rx_fifo_half_unused                             );
    
    TX_FIFO_inst : AXI2SPI_AFIFO
    generic map (C_NUM_TRANSFER_BITS => C_NUM_TRANSFER_BITS, C_FIFO_EXIST => C_FIFO_EXIST)
    port map ( wdata => tx_data_i,
		       w_enable => tx_w_enable, 
		       r_enable => tx_r_enable, 
		       reset => tx_fifo_reset_i,
		       wclk => reg_clk, 
		       rclk => spi_clk,
		       rdata => tx_data,
		       full_flag => tx_full, 
		       empty_flag => tx_empty, 
		       occupancy => tx_occupancy,
		       fifo_half => tx_fifo_half                              );
----------------------------------------------------------------------------------------------
		       
end behavior;
