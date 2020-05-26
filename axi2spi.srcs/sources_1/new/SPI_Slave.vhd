library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_Slave is
    Generic( 
			C_NUM_TRANSFER_BITS : integer := 32; 
            C_NUM_SS_BITS : integer := 8
           );
    Port ( tx_data : in STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1) downto 0);
           rx_data : out STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1) downto 0);
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
           resetn : in STD_LOGIC;
           S_AXI_ACLK : in STD_LOGIC;
           int_clk : in STD_LOGIC;
           lsb_first : in STD_LOGIC;
           master_inhibit : in STD_LOGIC;
           manual_ss_en : in STD_LOGIC;
           cpha : in STD_LOGIC;
           cpol : in STD_LOGIC;
           spi_master_en : in STD_LOGIC;
           loopback_en : in STD_LOGIC;
           slave_mode_select : out STD_LOGIC;
           mode_fault_error : out STD_LOGIC;
           tx_empty : in STD_LOGIC;
           rx_full : in STD_LOGIC;
           slave_select : in STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
           gi_en : in STD_LOGIC;
           slave_select_mode : in STD_LOGIC;
           slave_mode_fault_error : out STD_LOGIC;
           ss_mode_fault_int_en : in STD_LOGIC;
           mode_fault_error_en : in STD_LOGIC;
           slave_mode_fault_int_en : in STD_LOGIC);
end SPI_Slave;

architecture Behavioral of SPI_Slave is
	component shift_reg is
		Generic (
			C_NUM_TRANSFER_BITS : integer := 32
		);
		Port (  
			clk			: in STD_LOGIC;
			resetn 		: in STD_LOGIC;
			shift_en	: in STD_LOGIC;
			cpha 		: in STD_LOGIC; --0 for rising edge, 1 for falling edge
			shift_in 	: in STD_LOGIC_VECTOR(C_NUM_TRANSFER_BITS -1 downto 0);
			shift_out 	: out STD_LOGIC_VECTOR(C_NUM_TRANSFER_BITS -1 downto 0);
			Cin 		: in STD_LOGIC;
			Cout 		: out STD_LOGIC
		);
	end component shift_reg;

	signal tx_buff, rx_buff : STD_LOGIC_VECTOR(C_NUM_TRANSFER_BITS -1 downto 0);
	
	signal ic : integer range 0 to C_NUM_TRANSFER_BITS := 0;

begin

	
	inst_shift_reg : shift_reg
		Generic Map(
			C_NUM_TRANSFER_BITS => C_NUM_TRANSFER_BITS
		)
		Port Map(
			clk			=> int_clk,
			resetn 		=> resetn,
			shift_en	=> SPISEL,
			cpha 		=> cpha,
			shift_in	=> tx_buff,
			shift_out	=> rx_buff,
			Cin 		=> MOSI_I,
			Cout 		=> MISO_O
		);
			
	internal_counter : process (int_clk)
	begin
		if(int_clk'EVENT and int_clk = not cpha) then
			if(resetn = '0') then
				ic <= 0;
				tx_buff <= (others => 'Z');--Should tx buff be reset to tx data?
				rx_buff <= (others => 'Z');
			else
				if(ic > C_NUM_TRANSFER_BITS) then
					ic <= ic + 1;
				elsif(ic = C_NUM_TRANSFER_BITS) then
					tx_buff <= tx_data;
					rx_data <= rx_buff;
					
					ic <= 0;
				else
					ic <= 0;
				end if;
			end if;
		end if;
	end process internal_counter;
end Behavioral;