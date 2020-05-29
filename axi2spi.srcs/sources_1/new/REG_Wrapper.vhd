--Author : Devon Stedronsky
--Date : May 2020
--
--Description : AXI2SPI Controller
--
--REGISTER INTERFACE WRAPPER


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG_Wrapper is
    Generic (
				C_S_AXI_DATA_WIDTH : integer := 32;
				C_NUM_SS_BITS : integer := 1;
				C_NUM_TRANSFER_BITS : integer := 32			);
	
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
				
				--FIFO access signals
				rx_r_enable			:	out		std_logic;
				tx_w_enable 		:	out		std_logic;
				
				--FIFO Data
				tx_fifo_data		:	out		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
				rx_fifo_data		:	in		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
				tx_fifo_occupancy	:	in		std_logic_vector (3 downto 0);
				rx_fifo_occupancy	:	in		std_logic_vector (3 downto 0);
				
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
end REG_Wrapper;

architecture Behavioral of REG_Wrapper is

---------------------------------------------------------------------------------------------------
COMPONENT SRR IS
    Generic	( C_S_AXI_DATA_WIDTH : integer := 32	);		
    Port (	reg_clk  :	in	std_logic;
			reg_rst  :	in 	std_logic;
			srr_cs   :	in	std_logic;
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			srr_wack			:	out		std_logic;
			srr_werror			:	out 	std_logic;
			soft_reset			:	out		std_logic		);
END COMPONENT;
---------------------------------------------------------------------------------------------------
COMPONENT SPICR IS
	Generic	( C_S_AXI_DATA_WIDTH : integer := 32	);		
    Port (	reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			spicr_cs		:	in	std_logic;
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			spicr_wack			:	out		std_logic;
			reg_read_enable		:	in		std_logic;
			spicr_rack			:	out 	std_logic;
			spicr_rdata         :   out     std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);

			Lsb_first			:	out		std_logic;
			Master_inhibit		:	out		std_logic;
			Manual_ss_en		:	out		std_logic;
			Rx_fifo_reset		:	out		std_logic;
			Tx_fifo_reset		:	out		std_logic;
			Cpha				:	out		std_logic;
			Cpol				:	out		std_logic;
			Spi_master_en		:	out		std_logic;
			Spi_system_en		:	out		std_logic;
			Loopback_en			:	out		std_logic		);
END COMPONENT;
---------------------------------------------------------------------------------------------------
COMPONENT SPISR IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32	);		
    Port (	reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			spisr_cs		:	in	std_logic;
			slave_mode_select	:	in 		std_logic;
			mode_fault_error	:	in		std_logic;
			tx_full				:	in		std_logic;
			tx_empty			:	in		std_logic;
			rx_full				:	in		std_logic;
			rx_empty			:	in		std_logic;
			reg_read_enable		:	in		std_logic;
			spisr_rdata			:	out		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			spisr_rack			:	out 	std_logic		);
END COMPONENT;
---------------------------------------------------------------------------------------------------
COMPONENT SPISSR IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32;
	            C_NUM_SS_BITS : integer := 1	);		
    Port (	reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			spissr_cs		:	in	std_logic;
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			spissr_wack			:	out		std_logic;
			reg_read_enable		:	in		std_logic;
			spissr_rack			:	out 	std_logic;
			spissr_rdata        :   out     std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			slave_select		:	out		std_logic_vector ((C_NUM_SS_BITS - 1) downto 0)			);
END COMPONENT;
---------------------------------------------------------------------------------------------------
COMPONENT SPIDTR IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32;
				C_NUM_TRANSFER_BITS	: integer := 32	);		
    Port (	reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			spidtr_cs		:	in	std_logic;
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			spidtr_wack			:	out		std_logic;
			tx_fifo_data		:	out		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0)			);
END COMPONENT;
---------------------------------------------------------------------------------------------------
COMPONENT SPIDRR IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32;
				C_NUM_TRANSFER_BITS : integer := 32		);			
    Port (	reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			spidrr_cs		:	in	std_logic;
			rx_fifo_data		:	in		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
			reg_read_enable		:	in		std_logic;
			spidrr_rdata		:	out		std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0);
			spidrr_rack			:	out 	std_logic		);
END COMPONENT;
---------------------------------------------------------------------------------------------------
COMPONENT TX_FIFO_OCY IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32	);		
    Port (	reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			tx_fifo_ocy_cs		:	in	std_logic;
			tx_fifo_occupancy	:	in		std_logic_vector (3 downto 0);
			reg_read_enable		:	in		std_logic;
			tx_fifo_ocy_rdata	:	out		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			tx_fifo_ocy_rack	:	out 	std_logic		);
END COMPONENT;
---------------------------------------------------------------------------------------------------
COMPONENT RX_FIFO_OCY IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32	);		
    Port (	reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			rx_fifo_ocy_cs		:	in	std_logic;
			rx_fifo_occupancy	:	in		std_logic_vector (3 downto 0);
			reg_read_enable		:	in		std_logic;
			rx_fifo_ocy_rdata	:	out		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			rx_fifo_ocy_rack	:	out 	std_logic		);
END COMPONENT;
---------------------------------------------------------------------------------------------------
COMPONENT DGIER IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32	);		
    Port (	reg_clk		:	in	std_logic;
			reg_rst		:	in 	std_logic;
			dgier_cs		:	in	std_logic;
			reg_write_enable	:	in		std_logic;
			reg_wstb			:	in		std_logic_vector (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
			reg_wdata			:	in		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			dgier_wack			:	out		std_logic;
			reg_read_enable		:	in		std_logic;
			dgier_rdata			:	out		std_logic_vector ((C_S_AXI_DATA_WIDTH - 1) downto 0);
			dgier_rack			:	out 	std_logic;
			gi_en				:	out 	std_logic		);
END COMPONENT;
---------------------------------------------------------------------------------------------------
COMPONENT IPISR IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32	);		
    Port (	reg_clk		:	in	std_logic;
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
			mode_fault_error		: 	out		std_logic		);
END COMPONENT;
---------------------------------------------------------------------------------------------------
COMPONENT IPIER IS
	Generic	(	C_S_AXI_DATA_WIDTH : integer := 32	);			
    Port (	reg_clk		:	in	std_logic;
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
			Mode_fault_int_en		:	out		std_logic		);
END COMPONENT;
---------------------------------------------------------------------------------------------------
--SIGNALS
signal srr_wack : std_logic := '0';
signal srr_werror : std_logic := '0';
signal spicr_wack : std_logic := '0';
signal spicr_rack : std_logic := '0';
signal spicr_rdata : std_logic_vector((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal spisr_rack : std_logic := '0';
signal spisr_rdata : std_logic_vector((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal spissr_wack : std_logic := '0';
signal spissr_rack : std_logic := '0';
signal spissr_rdata : std_logic_vector((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal spidtr_wack : std_logic := '0';
signal spidrr_rdata : std_logic_vector((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal spidrr_rack : std_logic := '0';
signal tx_fifo_ocy_rdata : std_logic_vector((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal tx_fifo_ocy_rack : std_logic := '0';
signal rx_fifo_ocy_rdata : std_logic_vector((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal rx_fifo_ocy_rack : std_logic := '0';
signal dgier_rack : std_logic := '0';
signal dgier_rdata : std_logic_vector((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal dgier_wack : std_logic := '0';
signal ipisr_rdata : std_logic_vector((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal ipisr_rack : std_logic := '0';
signal ipisr_wack : std_logic := '0';
signal ipier_rdata : std_logic_vector((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal ipier_rack : std_logic := '0';
signal ipier_wack : std_logic := '0';
signal cs_vector : std_logic_vector (10 downto 0) := (others => '0');

signal slave_mode_select_temp : std_logic := '0';
signal mode_fault_error_temp : std_logic := '0';	
---------------------------------------------------------------------------------------------------
begin

srr_inst : SRR
generic map ( C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH )
port map (
			reg_clk => reg_clock,
			reg_rst => reg_reset,
			srr_cs => srr_cs,
			reg_write_enable => reg_write_enable,
			reg_wstb => reg_wstb,
			reg_wdata => reg_wdata,
			srr_wack => srr_wack,
			srr_werror => srr_werror,
			soft_reset => soft_reset			);

spicr_inst : SPICR
generic map (C_S_AXI_DATA_WIDTH => 	C_S_AXI_DATA_WIDTH)
port map (
			reg_clk => reg_clock,
			reg_rst => reg_reset,
			spicr_cs => spicr_cs,
			reg_write_enable => reg_write_enable,
			reg_wstb => reg_wstb,
			reg_wdata => reg_wdata,
			spicr_wack => spicr_wack,
			reg_read_enable => reg_read_enable,
			spicr_rack => spicr_rack,
			spicr_rdata => spicr_rdata,

			Lsb_first => Lsb_first,
			Master_inhibit => Master_inhibit,
			Manual_ss_en => Manual_ss_en,
			Rx_fifo_reset => Rx_fifo_reset,
			Tx_fifo_reset => Tx_fifo_reset,
			Cpha => Cpha,
			Cpol => Cpol,
			Spi_master_en => Spi_master_en,
			Spi_system_en => Spi_system_en,
			Loopback_en	 => Loopback_en			);

spisr_inst : SPISR
generic map (C_S_AXI_DATA_WIDTH  => C_S_AXI_DATA_WIDTH	)
port map (
			reg_clk => reg_clock,
			reg_rst => reg_reset,
			spisr_cs => spisr_cs,
			slave_mode_select => slave_mode_select_temp,
			mode_fault_error => mode_fault_error_temp,
			tx_full => tx_full,
			tx_empty => tx_empty,
			rx_full	 => rx_full,
			rx_empty => rx_empty,
			reg_read_enable => reg_read_enable ,
			spisr_rdata => spisr_rdata,
			spisr_rack => spisr_rack				);

spissr_inst : SPISSR
generic map (C_S_AXI_DATA_WIDTH  => C_S_AXI_DATA_WIDTH,
	            C_NUM_SS_BITS => C_NUM_SS_BITS)
port map (
			reg_clk => reg_clock,
			reg_rst => reg_reset,
			spissr_cs => spissr_cs,
			reg_write_enable => reg_write_enable,
			reg_wstb => reg_wstb,
			reg_wdata => reg_wdata,
			spissr_wack	 => spissr_wack,
			reg_read_enable	 => reg_read_enable,
			spissr_rack	 => spissr_rack,
			spissr_rdata => spissr_rdata,
			slave_select => slave_select			);
			
spidtr_inst : SPIDTR
generic map (C_S_AXI_DATA_WIDTH  => C_S_AXI_DATA_WIDTH,
				C_NUM_TRANSFER_BITS => C_NUM_TRANSFER_BITS	)
port map (
			reg_clk => reg_clock,
			reg_rst	 => reg_reset,
			spidtr_cs => spidtr_cs,
			reg_write_enable => reg_write_enable,
			reg_wstb => reg_wstb,
			reg_wdata => reg_wdata,
			spidtr_wack	 => spidtr_wack,
			tx_fifo_data => tx_fifo_data			);

spidrr_inst : SPIDRR
generic map (C_S_AXI_DATA_WIDTH  => C_S_AXI_DATA_WIDTH,
				C_NUM_TRANSFER_BITS	 => C_NUM_TRANSFER_BITS	)
port map (
			reg_clk	=> reg_clock,
			reg_rst => reg_reset,
			spidrr_cs => spidrr_cs,
			rx_fifo_data => rx_fifo_data,
			reg_read_enable => reg_read_enable,
			spidrr_rdata => spidrr_rdata,
			spidrr_rack => spidrr_rack				);

tx_fifo_ocy_inst : TX_FIFO_OCY
generic map (C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH)
port map (
			reg_clk => reg_clock,
			reg_rst => reg_reset,
			tx_fifo_ocy_cs => tx_fifo_ocy_cs,
			tx_fifo_occupancy => tx_fifo_occupancy,
			reg_read_enable	 => reg_read_enable,
			tx_fifo_ocy_rdata => tx_fifo_ocy_rdata,
			tx_fifo_ocy_rack => tx_fifo_ocy_rack			);

rx_fifo_ocy_inst : RX_FIFO_OCY
generic map (C_S_AXI_DATA_WIDTH  => C_S_AXI_DATA_WIDTH)
port map (
			reg_clk => reg_clock,
			reg_rst	 => reg_reset,
			rx_fifo_ocy_cs => rx_fifo_ocy_cs,
			rx_fifo_occupancy => rx_fifo_occupancy,
			reg_read_enable => reg_read_enable,
			rx_fifo_ocy_rdata => rx_fifo_ocy_rdata,
			rx_fifo_ocy_rack => rx_fifo_ocy_rack 			);

dgier_inst : DGIER
generic map (C_S_AXI_DATA_WIDTH  => C_S_AXI_DATA_WIDTH)
port map (
			reg_clk => reg_clock,
			reg_rst => reg_reset,
			dgier_cs => dgier_cs,
			reg_write_enable => reg_write_enable,
			reg_wstb => reg_wstb,
			reg_wdata => reg_wdata,
			dgier_wack => dgier_wack,
			reg_read_enable	 => reg_read_enable,
			dgier_rdata => dgier_rdata,
			dgier_rack => dgier_rack,
			gi_en => gi_en			);

ipisr_inst : IPISR
generic map (C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH)
port map (
			reg_clk => reg_clock,
			reg_rst => reg_reset,
			ipisr_cs => ipisr_cs,
			reg_write_enable => reg_write_enable,
			reg_wstb => reg_wstb,
			reg_wdata => reg_wdata,
			ipisr_wack => ipisr_wack,
			reg_read_enable	 => reg_read_enable,
			ipisr_rack => ipisr_rack,
			ipisr_rdata => ipisr_rdata,
			
			drr_not_empty => drr_not_empty,
			slave_mode_select => slave_mode_select_temp,
			tx_fifo_half => tx_fifo_half,
			drr_overrun => drr_overrun,
			drr_full => drr_full,
			dtr_underrun => dtr_underrun,
			dtr_empty => dtr_empty,
			slave_mode_fault_error => slave_mode_fault_error,
			mode_fault_error => mode_fault_error_temp			);

ipier_inst : IPIER
generic map (C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH)
port map (
			reg_clk => reg_clock,
			reg_rst => reg_reset,
			ipier_cs => ipier_cs,
			reg_write_enable => reg_write_enable,
			reg_wstb => reg_wstb,
			reg_wdata => reg_wdata,
			ipier_wack => ipier_wack,
			reg_read_enable => reg_read_enable,
			ipier_rack => ipier_rack,
			ipier_rdata => ipier_rdata,
			
			Drr_not_empty_int_en => Drr_not_empty_int_en,
			Ss_mode_int_en => Ss_mode_int_en,
			Tx_fifo_half_int_en	 => Tx_fifo_half_int_en,
			Drr_overrun_int_en => Drr_overrun_int_en,
			Drr_full_int_en	 => Drr_full_int_en,
			Dtr_underrun_int_en	 => Dtr_underrun_int_en,
			Dtr_empty_int_en => Dtr_empty_int_en,
			Slave_mode_fault_int_en => Slave_mode_fault_int_en,
			Mode_fault_int_en => Mode_fault_int_en			);


--ACK and RDATA Assignment Based on CS
cs_vector <= ipier_cs & ipisr_cs & dgier_cs & rx_fifo_ocy_cs & tx_fifo_ocy_cs & spidrr_cs & spidtr_cs & spissr_cs & spisr_cs & spicr_cs & srr_cs;

process (reg_clock)
begin

CASE cs_vector is

--SRR Write only
WHEN "00000000001" =>
reg_rack <= '0';
reg_rdata <= (others => '0');
reg_wack <= srr_wack;
reg_werror <= srr_werror;
reg_rerror <= '0';

--SPICR R/W
WHEN "00000000010" =>
reg_wack <= spicr_wack;
reg_rdata <= spicr_rdata;
reg_rack <= spicr_rack;
reg_rerror <= '0';
reg_werror <= '0';

--SPISR Read only
WHEN "00000000100" =>
reg_wack <= '0';
reg_rdata <= spisr_rdata;
reg_rack <= spisr_rack;
reg_rerror <= '0';
reg_werror <= '0';

--SPISSR R/W
WHEN "00000001000" =>
reg_wack <= spissr_wack;
reg_rdata <= spissr_rdata;
reg_rack <= spissr_rack;
reg_rerror <= '0';
reg_werror <= '0';

--SPIDTR Write only
WHEN "00000010000" =>
reg_wack <= spidtr_wack;
reg_rdata <= (others => '0');
reg_rack <= '0';
reg_rerror <= '0';
reg_werror <= '0';

--SPIDRR Read only
WHEN "00000100000" =>
reg_wack <= '0';
reg_rdata <= spidrr_rdata;
reg_rack <= spidrr_rack;
reg_rerror <= '0';
reg_werror <= '0';

--TX_FIFO_OCY Read only
WHEN "00001000000" =>
reg_wack <= '0';
reg_rdata <= tx_fifo_ocy_rdata;
reg_rack <= tx_fifo_ocy_rack;
reg_rerror <= '0';
reg_werror <= '0';

--RX_FIFO_OCY Read Only
WHEN "00010000000" =>
reg_wack <= '0';
reg_rdata <= rx_fifo_ocy_rdata;
reg_rack <= rx_fifo_ocy_rack;
reg_rerror <= '0';
reg_werror <= '0';

--DGIER R/W
WHEN "00100000000" =>
reg_wack <= dgier_wack;
reg_rdata <= dgier_rdata;
reg_rack <= dgier_rack;
reg_rerror <= '0';
reg_werror <= '0';

--IPISR R/TOW
WHEN "01000000000" =>
reg_wack <= ipisr_wack;
reg_rdata <= ipisr_rdata;
reg_rack <= ipisr_rack;
reg_rerror <= '0';
reg_werror <= '0';

--IPIER R/W
WHEN "10000000000" =>
reg_wack <= ipier_wack;
reg_rdata <= ipier_rdata;
reg_rack <= ipier_rack;
reg_rerror <= '0';
reg_werror <= '0';

--Multiple Chip Select Error
WHEN OTHERS =>
reg_wack <= '0';
reg_rdata <= (others => '0');
reg_rack <= '0';
reg_rerror <= '1';
reg_werror <= '1';

END CASE;
END PROCESS;

--I/O 
rx_r_enable <= spidrr_cs and reg_read_enable and (NOT spidrr_rack);
tx_w_enable <= spidtr_wack;

end Behavioral;
