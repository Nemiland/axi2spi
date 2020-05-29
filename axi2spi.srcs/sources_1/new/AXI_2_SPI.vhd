--Author: Andrew Newman
--Date: April/May 2020
--
--Description : AXI2SPI TOP MODULE WRAPPER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AXI_2_SPI is
  Generic( C_BASEADDR : unsigned := X"100";
           C_HIGHADDR : unsigned := X"200";
           C_FIFO_EXIST : std_logic := '0';
           C_S_AXI_ADDR_WIDTH : integer := 32;
           C_S_AXI_DATA_WIDTH : integer := 32;
           C_NUM_TRANSFER_BITS : integer := 32; 
           C_NUM_SS_BITS : integer := 8;
           C_SCK_RATIO : integer := 32
         );
    Port ( 
           IP2INTC_Irpt : out STD_LOGIC;
           SCK_I : in STD_LOGIC;
           SCK_O : out STD_LOGIC;
           SCK_T : out STD_LOGIC;
           MOSI_I : in STD_LOGIC;
           MOSI_O : out STD_LOGIC;
           MOSI_T : out STD_LOGIC;
           MISO_I : in STD_LOGIC;
           MISO_O : out STD_LOGIC;
           MISO_T : out STD_LOGIC;
           SPISEL : in STD_LOGIC;
           SS_I : in STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
           SS_O : out STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
           SS_T : out STD_LOGIC;
           S_AXI_ACLK : in STD_LOGIC := '0';
           S_AXI_ARESETN : in STD_LOGIC := '0';
           S_AXI_AWADDR : in STD_LOGIC_VECTOR ((C_S_AXI_ADDR_WIDTH - 1) downto 0) := (others => '0');
           S_AXI_AWVALID : in STD_LOGIC := '0';
           S_AXI_AWREADY : out STD_LOGIC;
           S_AXI_WDATA : in STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
           S_AXI_WSTB : in STD_LOGIC_VECTOR (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0) := (others => '0');
           S_AXI_WVALID : in STD_LOGIC := '0';
           S_AXI_WREADY : out STD_LOGIC;
           S_AXI_BRESP : out STD_LOGIC_VECTOR (1 downto 0);
           S_AXI_BVALID : out STD_LOGIC;
           S_AXI_BREADY : in STD_LOGIC := '0';
           S_AXI_ARADDR : in STD_LOGIC_VECTOR ((C_S_AXI_ADDR_WIDTH - 1) downto 0) := (others => '0');
           S_AXI_ARVALID : in STD_LOGIC := '0';
           S_AXI_ARREADY : out STD_LOGIC;
           S_AXI_RDATA : out STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
           S_AXI_RRESP : out STD_LOGIC_VECTOR (1 downto 0);
           S_AXI_RVALID : out STD_LOGIC;
           S_AXI_RREADY : in STD_LOGIC := '0'
         );
end AXI_2_SPI;

architecture Behavioral of AXI_2_SPI is

component AXI_IF
    Generic (
       C_BASEADDR : unsigned := X"100";
       C_HIGHADDR : unsigned := X"200";
       C_S_AXI_ADDR_WIDTH : integer := 32;
       C_S_AXI_DATA_WIDTH : integer := 32);
    Port ( 
       S_AXI_ACLK : in STD_LOGIC := '0';
       S_AXI_ARESETN : in STD_LOGIC := '0';
       S_AXI_AWADDR : in STD_LOGIC_VECTOR ((C_S_AXI_ADDR_WIDTH - 1) downto 0) := (others => '0');
       S_AXI_AWVALID : in STD_LOGIC := '0';
       S_AXI_AWREADY : out STD_LOGIC;
       S_AXI_WDATA : in STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
       S_AXI_WSTB : in STD_LOGIC_VECTOR (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0) := (others => '0');
       S_AXI_WVALID : in STD_LOGIC := '0';
       S_AXI_WREADY : out STD_LOGIC;
       S_AXI_BRESP : out STD_LOGIC_VECTOR (1 downto 0);
       S_AXI_BVALID : out STD_LOGIC;
       S_AXI_BREADY : in STD_LOGIC := '0';
       S_AXI_ARADDR : in STD_LOGIC_VECTOR ((C_S_AXI_ADDR_WIDTH - 1) downto 0) := (others => '0');
       S_AXI_ARVALID : in STD_LOGIC := '0';
       S_AXI_ARREADY : out STD_LOGIC;
       S_AXI_RDATA : out STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
       S_AXI_RRESP : out STD_LOGIC_VECTOR (1 downto 0);
       S_AXI_RVALID : out STD_LOGIC;
       S_AXI_RREADY : in STD_LOGIC := '0';
       srr_cs : out STD_LOGIC;
       spicr_cs : out STD_LOGIC;
       spisr_cs : out STD_LOGIC;
       spidtr_cs : out STD_LOGIC;
       spidrr_cs : out STD_LOGIC;
       spissr_cs : out STD_LOGIC;
       tx_fifo_ocy_cs : out STD_LOGIC;
       rx_fifo_ocy_cs : out STD_LOGIC;
       dgier_cs : out STD_LOGIC;
       ipisr_cs : out STD_LOGIC;
       ipier_cs : out STD_LOGIC;
       reg_rack : in STD_LOGIC;
       reg_read_enable : out STD_LOGIC;
       reg_rdata : in STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
       reg_rerror : in STD_LOGIC := '0';
       reg_wack : in STD_LOGIC := '0';
       reg_wdata : out STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0);
       reg_wstb : out STD_LOGIC_VECTOR (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
       reg_werror : in STD_LOGIC := '0';
       reg_write_data_en : out STD_LOGIC;
       reg_write_enable : out STD_LOGIC);
end component;

component REG_Wrapper is
    Generic (
				C_S_AXI_DATA_WIDTH : integer := 32;
				C_NUM_SS_BITS : integer := 8;
				C_NUM_TRANSFER_BITS : integer := 32			
            );
	
	Port ( 		reg_clock : in STD_LOGIC;
				reg_reset : in STD_LOGIC;
			
				reg_read_enable : in STD_LOGIC;
				reg_rack : out STD_LOGIC;
				reg_rdata : out STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0);
				reg_rerror : out STD_LOGIC;
			
				reg_write_enable : in STD_LOGIC;
				reg_wstb : in STD_LOGIC_VECTOR (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
				reg_wack : out STD_LOGIC;
				reg_wdata : in STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0);
				reg_werror : out STD_LOGIC;						
				
				--Chip select
				srr_cs : in STD_LOGIC;
				spicr_cs : in STD_LOGIC;
				spisr_cs : in STD_LOGIC;
				spissr_cs : in STD_LOGIC;
				spidtr_cs : in STD_LOGIC;
				spidrr_cs : in STD_LOGIC;
				tx_fifo_ocy_cs : in STD_LOGIC;
				rx_fifo_ocy_cs : in STD_LOGIC;
				dgier_cs : in STD_LOGIC;
				ipisr_cs : in STD_LOGIC;
				ipier_cs : in STD_LOGIC;
				
				--SRR output
				soft_reset : out STD_LOGIC;
				
				--SPICR outputs
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

				--SPISR inputs
				--slave_mode_select	:	in 		std_logic;
				--mode_fault_error	:	in		std_logic;
				tx_full				:	in		std_logic;
				tx_empty			:	in		std_logic;
				rx_full				:	in		std_logic;
				rx_empty			:	in		std_logic;
				
				--SPISSR output
				slave_select		:	out		std_logic_vector ((C_NUM_SS_BITS - 1) downto 0);
				
				--FIFO Data
				tx_fifo_data		:	out		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
				rx_fifo_data		:	in		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
				tx_fifo_occupancy	:	in		std_logic_vector (3 downto 0);
				rx_fifo_occupancy	:	in		std_logic_vector (3 downto 0);
				
				--FIFO access signals
				rx_r_enable			:	out		std_logic;
				tx_w_enable 		:	out		std_logic;
				
				--Interrupt Outputs
				gi_en				:	out 	std_logic;
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
				Ss_mode_int_en			:	out		std_logic;
				Tx_fifo_half_int_en		:	out		std_logic;
				Drr_overrun_int_en		:	out		std_logic;
				Drr_full_int_en			:	out		std_logic;
				Dtr_underrun_int_en		:	out		std_logic;
				Dtr_empty_int_en		:	out		std_logic;
				Slave_mode_fault_int_en	:	out		std_logic;
				Mode_fault_int_en		:	out		std_logic			);
end component;

component SYNCH_WRAPPER is
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
	
    --REGISTER I/O
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
    Ss_mode_int_en			:	out		std_logic;
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
    Ss_mode_int_en_i		 :	in		std_logic;
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
end component;

component SPI_IF is
    Generic( C_NUM_TRANSFER_BITS : integer := 32; 
             C_NUM_SS_BITS : integer := 8;
             C_SCK_RATIO : integer := 32
           );
    Port ( tx_data : in STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1) downto 0);
           rx_data : out STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1) downto 0);
           IP2INTC_Irpt : out STD_LOGIC;
           int_clk : out STD_LOGIC;
           SCK_I : in STD_LOGIC;
           SCK_O : out STD_LOGIC;
           SCK_T : out STD_LOGIC;
           MOSI_I : in STD_LOGIC;
           MOSI_O : out STD_LOGIC;
           MOSI_T : out STD_LOGIC;
           MISO_I : in STD_LOGIC;
           MISO_O : out STD_LOGIC;
           MISO_T : out STD_LOGIC;
           SPISEL : in STD_LOGIC;
           SS_I : in STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
           SS_O : out STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
           SS_T : out STD_LOGIC;
           resetn : in STD_LOGIC;
           S_AXI_ACLK : in STD_LOGIC;
           lsb_first : in STD_LOGIC;
           master_inhibit : in STD_LOGIC;
           manual_ss_en : in STD_LOGIC;
           cpha : in STD_LOGIC;
           cpol : in STD_LOGIC;
           spi_master_en : in STD_LOGIC;
           spi_system_en : in STD_LOGIC;
           loopback_en : in STD_LOGIC;
           slave_mode_select : out STD_LOGIC;
           mode_fault_error : out STD_LOGIC;
           tx_empty : in STD_LOGIC;
           rx_full : in STD_LOGIC;
           slave_select : in STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
           gi_en : in STD_LOGIC;
           --slave_select_mode : in STD_LOGIC;
           slave_mode_fault_error : out STD_LOGIC;
           --ss_mode_fault_int_en : in STD_LOGIC;
           mode_fault_error_en : in STD_LOGIC;
           fifo_rw : out STD_LOGIC;
           slave_mode_fault_int_en : in STD_LOGIC);
end component;

--AXI signals (going towards REG)
signal srr_cs, spicr_cs, spisr_cs, spidtr_cs, spidrr_cs, spissr_cs, tx_fifo_ocy_cs, rx_fifo_ocy_cs, 
       dgier_cs, ipisr_cs, ipier_cs, reg_rack, reg_read_enable, reg_rerror, reg_wack, 
       reg_werror, reg_write_data_en, reg_write_enable: STD_LOGIC := '0';
signal reg_reset : STD_LOGIC := '1';
signal reg_wdata, reg_rdata : STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal reg_wstb : STD_LOGIC_VECTOR (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0) := (others => '0');

--REG signals(going towards SYNCH)
signal reg_soft_reset, reg_Lsb_first, reg_Master_inhibit, reg_Manual_ss_en, reg_Rx_fifo_reset, reg_Tx_fifo_reset, reg_Cpha, reg_Cpol, reg_Spi_master_en, reg_Spi_system_en, 
       reg_Loopback_en, reg_tx_full, reg_tx_empty, reg_rx_full, reg_rx_empty, reg_gi_en, reg_drr_not_empty, reg_tx_fifo_half, reg_drr_overrun, reg_drr_full, reg_dtr_underrun, 
       reg_dtr_empty, reg_slave_mode_fault_error,reg_Drr_not_empty_int_en, reg_Ss_mode_int_en, reg_Tx_fifo_half_int_en, reg_Drr_overrun_int_en, reg_Drr_full_int_en, 
       reg_Dtr_underrun_int_en, reg_Dtr_empty_int_en, reg_Slave_mode_fault_int_en, reg_Mode_fault_int_en: STD_LOGIC := '0';
signal reg_slave_select: STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0) := (others => '0');
signal reg_tx_fifo_data, reg_rx_fifo_data: std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0) := (others => '0');
signal reg_tx_fifo_occupancy, reg_rx_fifo_occupancy: std_logic_vector (3 downto 0) := (others => '0');
signal reg_slave_mode_select, reg_mode_fault_error : std_logic := '0';

--SYNCH signals (going towards SPI)
signal resetn, int_clk : STD_LOGIC := '0';
signal Lsb_first, Master_inhibit, Manual_ss_en, Rx_fifo_reset, Tx_fifo_reset, Cpha, Cpol, Spi_master_en,Spi_system_en, Loopback_en: STD_LOGIC := '0';
signal tx_full, tx_empty, rx_full,  rx_empty: STD_LOGIC := '0';
signal slave_select: STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0) := (others => '0');
signal gi_en, drr_not_empty, tx_fifo_half, drr_overrun, drr_full, dtr_underrun, dtr_empty, slave_mode_fault_error, 
       Drr_not_empty_int_en, Ss_mode_int_en, Tx_fifo_half_int_en, Drr_overrun_int_en, Drr_full_int_en, 
       Dtr_underrun_int_en, Dtr_empty_int_en, Slave_mode_fault_int_en, Mode_fault_int_en: STD_LOGIC := '0';
signal rx_w_enable, rx_r_enable, rx_empty_flag, rx_full_flag, tx_w_enable, tx_r_enable, tx_full_flag, tx_empty_flag: STD_LOGIC := '0';
signal tx_data, rx_data: std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0) := (others => '0');
signal slave_mode_select, mode_fault_error : std_logic := '0';

--SPI signals
signal fifo_rw : STD_LOGIC := '0';
begin

AXI_IF_inst: AXI_IF
    Generic Map(
                C_BASEADDR => C_BASEADDR,
                C_HIGHADDR => C_HIGHADDR,
                C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,
                C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH
               )
    Port Map( 
       S_AXI_ACLK => S_AXI_ACLK,
       S_AXI_ARESETN => S_AXI_ARESETN,
       S_AXI_AWADDR => S_AXI_AWADDR,
       S_AXI_AWVALID => S_AXI_AWVALID,
       S_AXI_AWREADY => S_AXI_AWREADY,
       S_AXI_WDATA => S_AXI_WDATA,
       S_AXI_WSTB => S_AXI_WSTB,
       S_AXI_WVALID => S_AXI_WVALID,
       S_AXI_WREADY => S_AXI_WREADY,
       S_AXI_BRESP => S_AXI_BRESP,
       S_AXI_BVALID => S_AXI_BVALID,
       S_AXI_BREADY => S_AXI_BREADY,
       S_AXI_ARADDR => S_AXI_ARADDR,
       S_AXI_ARVALID => S_AXI_ARVALID,
       S_AXI_ARREADY => S_AXI_ARREADY,
       S_AXI_RDATA => S_AXI_RDATA,
       S_AXI_RRESP => S_AXI_RRESP,
       S_AXI_RVALID => S_AXI_RVALID,
       S_AXI_RREADY => S_AXI_RREADY,
       srr_cs => srr_cs,
       spicr_cs => spicr_cs,
       spisr_cs => spisr_cs,
       spidtr_cs => spidtr_cs,
       spidrr_cs => spidrr_cs,
       spissr_cs => spissr_cs,
       tx_fifo_ocy_cs => tx_fifo_ocy_cs,
       rx_fifo_ocy_cs => rx_fifo_ocy_cs,
       dgier_cs => dgier_cs,
       ipisr_cs => ipisr_cs,
       ipier_cs => ipier_cs,
       reg_rack => reg_rack,
       reg_read_enable => reg_read_enable,
       reg_rdata => reg_rdata,
       reg_rerror => reg_rerror,
       reg_wack => reg_wack,
       reg_wdata => reg_wdata,
       reg_wstb => reg_wstb,
       reg_werror => reg_werror,
       reg_write_data_en => reg_write_data_en,
       reg_write_enable => reg_write_enable
        );   
REG_Wrapper_inst: REG_Wrapper
    Generic Map(
				C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
				C_NUM_SS_BITS => C_NUM_SS_BITS,
				C_NUM_TRANSFER_BITS => C_NUM_TRANSFER_BITS		
            )
	
	Port Map(   reg_clock => S_AXI_ACLK,
				reg_reset => reg_reset,
			
				reg_read_enable => reg_read_enable,
				reg_rack => reg_rack,
				reg_rdata => reg_rdata,
				reg_rerror => reg_rerror,
			
				reg_write_enable => reg_write_enable,
				reg_wstb => reg_wstb,
				reg_wack => reg_wack,
				reg_wdata => reg_wdata,
				reg_werror => reg_werror,				
				
				--Chip select
				srr_cs => srr_cs,
				spicr_cs => spicr_cs,
				spisr_cs => spisr_cs,
				spissr_cs => spissr_cs,
				spidtr_cs => spidtr_cs,
				spidrr_cs => spidrr_cs,
				tx_fifo_ocy_cs => tx_fifo_ocy_cs,
				rx_fifo_ocy_cs => rx_fifo_ocy_cs,
				dgier_cs => dgier_cs,
				ipisr_cs => ipisr_cs,
				ipier_cs => ipier_cs,
				
				--SRR output
				soft_reset => reg_soft_reset,
				
				--SPICR outputs
				Lsb_first			=> reg_Lsb_first,
				Master_inhibit		=> reg_Master_inhibit,
				Manual_ss_en		=> reg_Manual_ss_en,
				Rx_fifo_reset		=> reg_Rx_fifo_reset,
				Tx_fifo_reset		=> reg_Tx_fifo_reset,
				Cpha				=> reg_Cpha,
				Cpol				=> reg_Cpol,
				Spi_master_en		=> reg_Spi_master_en,
				Spi_system_en		=> reg_Spi_system_en,
				Loopback_en			=> reg_Loopback_en,

				--SPISR inputs
				--slave_mode_select	  => reg_slave_mode_select,
				--mode_fault_error	  => reg_mode_fault_error, 
				tx_full				=> reg_tx_full,
				tx_empty			=> reg_tx_empty,
				rx_full				=> reg_rx_full,
				rx_empty			=> reg_rx_empty,
				
				--SPISSR output
				slave_select		=> reg_slave_select,
				
				--FIFO Data
				tx_fifo_data		=> reg_tx_fifo_data,
				rx_fifo_data		=> reg_rx_fifo_data,
				tx_fifo_occupancy	=> reg_tx_fifo_occupancy,
				rx_fifo_occupancy	=> reg_rx_fifo_occupancy,
				
				--FIFO access signals
				rx_r_enable			=> rx_r_enable,
				tx_w_enable 		=> tx_w_enable,
				
				--Interrupt Outputs
				gi_en				=> reg_gi_en,
				drr_not_empty			=> reg_drr_not_empty,
				--slave_mode_select		: 	out		std_logic;
				tx_fifo_half			=> reg_tx_fifo_half,
				drr_overrun				=> reg_drr_overrun,
				drr_full				=> reg_drr_full,
				dtr_underrun			=> reg_dtr_underrun,
				dtr_empty				=> reg_dtr_empty,
				slave_mode_fault_error  => reg_slave_mode_fault_error,
				--mode_fault_error		: 	out		std_logic;
				Drr_not_empty_int_en	=> reg_Drr_not_empty_int_en,
				Ss_mode_int_en			=> reg_Ss_mode_int_en,
				Tx_fifo_half_int_en		=> reg_Tx_fifo_half_int_en,
				Drr_overrun_int_en		=> reg_Drr_overrun_int_en,
				Drr_full_int_en			=> reg_Drr_full_int_en,
				Dtr_underrun_int_en		=> reg_Dtr_underrun_int_en,
				Dtr_empty_int_en		=> reg_Dtr_empty_int_en,
				Slave_mode_fault_int_en	=> reg_Slave_mode_fault_int_en,
				Mode_fault_int_en		=> reg_Mode_fault_int_en	
            );
            
SYNCH_WRAPPER_inst: SYNCH_WRAPPER
generic map(
			C_FIFO_EXIST => C_FIFO_EXIST,
			C_NUM_SS_BITS => C_NUM_SS_BITS,
			C_NUM_TRANSFER_BITS => C_NUM_TRANSFER_BITS
		   )
		
port map( 
            --CLOCK SIGNALS
            reg_clk 	=> S_AXI_ACLK,
            spi_clk		=> int_clk,
            reset		=> reg_reset,
            
            --REGISTER I/O
            --SRR (REG -> SPI)
            soft_reset => resetn,
            soft_reset_i => reg_soft_reset,
                        
            --SPICR (REG -> SPI)
            Lsb_first			=> Lsb_first,
            Master_inhibit		=> Master_inhibit,
            Manual_ss_en		=> Manual_ss_en,
            Rx_fifo_reset		=> Rx_fifo_reset,
            Tx_fifo_reset		=> Tx_fifo_reset,
            Cpha				=> Cpha,
            Cpol				=> Cpol,
            Spi_master_en		=> Spi_master_en,
            Spi_system_en		=> Spi_system_en,
            Loopback_en			=> Loopback_en,
            -----------------------------------------------
            Lsb_first_i			=> reg_Lsb_first,
            Master_inhibit_i	=> reg_Master_inhibit,
            Manual_ss_en_i		=> reg_Manual_ss_en,
            Rx_fifo_reset_i		=> reg_Rx_fifo_reset,
            Tx_fifo_reset_i		=> reg_Tx_fifo_reset,
            Cpha_i				=> reg_Cpha,
            Cpol_i				=> reg_Cpol,
            Spi_master_en_i		=> reg_Spi_master_en,
            Spi_system_en_i		=> reg_Spi_system_en,
            Loopback_en_i		=> reg_Loopback_en,
        
            --SPISR (SPI -> REG)
            --slave_mode_select	  => reg_slave_mode_select, 
            --mode_fault_error	  => reg_mode_fault_error,
            tx_full				=> reg_tx_full,
            tx_empty			=> reg_tx_empty,
            rx_full				=> reg_rx_full,
            rx_empty			=> reg_rx_empty,
            --slave_mode_select_i	=> slave_mode_select,
            --mode_fault_error_i	=> mode_fault_error,
            tx_full_i				=> tx_full,
            tx_empty_i			    => tx_empty,
            rx_full_i				=> rx_full,
            rx_empty_i			    => rx_empty,
                        
            --SPISSR (REG -> SPI)
            slave_select		=> slave_select,
            slave_select_i		=> reg_slave_select,
        
        --SPI INTERFACE PORTS				
        --slave_mode_select : out STD_LOGIC;
        --mode_fault_error : out STD_LOGIC;
        --slave_mode_fault_error : out STD_LOGIC;
        
            --Interrupt Registers (REG -> SPI)
            gi_en				    => gi_en,
            drr_not_empty			=> drr_not_empty,
            --slave_mode_select		: 	out		std_logic;
            tx_fifo_half			=> tx_fifo_half,
            drr_overrun				=> drr_overrun,
            drr_full				=> drr_full,
            dtr_underrun			=> dtr_underrun,
            dtr_empty				=> dtr_empty,
            slave_mode_fault_error	=> slave_mode_fault_error,
            --mode_fault_error		: 	out		std_logic;
            Drr_not_empty_int_en	=> Drr_not_empty_int_en,
            Ss_mode_int_en			=> Ss_mode_int_en,
            Tx_fifo_half_int_en		=> Tx_fifo_half_int_en,
            Drr_overrun_int_en		=> Drr_overrun_int_en,
            Drr_full_int_en			=> Drr_full_int_en,
            Dtr_underrun_int_en		=> Dtr_underrun_int_en,
            Dtr_empty_int_en		=> Dtr_empty_int_en,
            Slave_mode_fault_int_en	=> Slave_mode_fault_int_en,
            Mode_fault_int_en		=> Mode_fault_int_en,
            ------------------------------------------------------
            gi_en_i				     => reg_gi_en,
            drr_not_empty_i			 => reg_drr_not_empty,
            --slave_mode_select_i	 : 	in		std_logic;
            tx_fifo_half_i			 => reg_tx_fifo_half,
            drr_overrun_i		     => reg_drr_overrun,
            drr_full_i				 => reg_drr_full,
            dtr_underrun_i		     => reg_dtr_underrun,
            dtr_empty_i				 => reg_dtr_empty,
            slave_mode_fault_error_i => reg_slave_mode_fault_error,
            --mode_fault_error_i	 : 	in		std_logic;
            Drr_not_empty_int_en_i	 => reg_Drr_not_empty_int_en,
            Ss_mode_int_en_i		 => reg_Ss_mode_int_en,
            Tx_fifo_half_int_en_i	 => reg_Tx_fifo_half_int_en,
            Drr_overrun_int_en_i	 => reg_Drr_overrun_int_en,
            Drr_full_int_en_i		 => reg_Drr_full_int_en,
            Dtr_underrun_int_en_i	 => reg_Dtr_underrun_int_en,
            Dtr_empty_int_en_i		 => reg_Dtr_empty_int_en,
            Slave_mode_fault_int_en_i   => reg_Slave_mode_fault_int_en,
            Mode_fault_int_en_i		    => reg_Mode_fault_int_en,
            
        
            --TX DATA (REG -> SPI)
            tx_data    => tx_data,
            tx_data_i  => reg_tx_fifo_data,
            
            --RX DATA (SPI -> REG)
            rx_data    => reg_rx_fifo_data,
            rx_data_i  => rx_data,
            
            --FIFO I/O
            rx_w_enable       => rx_w_enable,
            rx_r_enable       => rx_r_enable,
            rx_empty_flag     => rx_empty_flag,
            rx_full_flag      => rx_full_flag,
            rx_occupancy      => reg_rx_fifo_occupancy,		
            tx_w_enable       => tx_w_enable,
            tx_r_enable       => tx_r_enable,
            tx_full_flag      => tx_full_flag,
            tx_empty_flag     => tx_empty_flag,
            tx_occupancy      => reg_tx_fifo_occupancy
		);
SPI_IF_inst: SPI_IF
    Generic Map( C_NUM_TRANSFER_BITS => C_NUM_TRANSFER_BITS, 
                 C_NUM_SS_BITS => C_NUM_SS_BITS,
                 C_SCK_RATIO => C_SCK_RATIO
               )
    Port Map(  tx_data => tx_data,
               rx_data => rx_data,
               IP2INTC_Irpt => IP2INTC_Irpt,
               int_clk => int_clk,
               SCK_I => SCK_I,
               SCK_O => SCK_O,
               SCK_T => SCK_T,
               MOSI_I => MOSI_I,
               MOSI_O => MOSI_O,
               MOSI_T => MOSI_T,
               MISO_I => MISO_I,
               MISO_O => MISO_O,
               MISO_T => MISO_T,
               SPISEL => SPISEL,
               SS_I => SS_I,
               SS_O => SS_O,
               SS_T => SS_T,
               resetn => resetn,
               S_AXI_ACLK => S_AXI_ACLK,
               lsb_first => lsb_first,
               master_inhibit => master_inhibit,
               manual_ss_en => manual_ss_en,
               cpha => cpha,
               cpol => cpol,
               spi_master_en => spi_master_en,
               spi_system_en => spi_system_en,
               loopback_en => loopback_en,
               slave_mode_select => slave_mode_select,
               mode_fault_error => mode_fault_error,
               tx_empty => tx_empty,
               rx_full => rx_full,
               slave_select => slave_select,
               gi_en => gi_en,
               --slave_select_mode => '0', --to-do
               slave_mode_fault_error => slave_mode_fault_error,
               --ss_mode_fault_int_en => '0', --to-do
               mode_fault_error_en => Mode_fault_int_en,
               fifo_rw => fifo_rw,
               slave_mode_fault_int_en => slave_mode_fault_int_en 
            );
rx_w_enable <= fifo_rw;
tx_r_enable <= fifo_rw;
reg_reset <= (not S_AXI_ARESETN) or reg_soft_reset;
end Behavioral;
