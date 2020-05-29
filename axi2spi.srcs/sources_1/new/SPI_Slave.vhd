--Author: Eric Wagner
--Date: May 2020
--
--Description : AXI2SPI SPI SLAVE CONTROLLER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_Slave is
    Generic( 
			C_NUM_TRANSFER_BITS : integer := 32
           );
    Port ( tx_data : in STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1) downto 0);
           rx_data : out STD_LOGIC_VECTOR ((C_NUM_TRANSFER_BITS - 1) downto 0);
           MOSI_I : in STD_LOGIC;
           MISO_O : out STD_LOGIC;
           SPISEL : in STD_LOGIC;
           resetn : in STD_LOGIC;
           S_AXI_ACLK : in STD_LOGIC;
           int_clk : in STD_LOGIC;
           lsb_first : in STD_LOGIC;
           tx_empty : in STD_LOGIC;
           rx_full : in STD_LOGIC;
		   fifo_r : out STD_LOGIC;
		   fifo_w : out STD_LOGIC
		   );
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
			reg_write   : in STD_LOGIC;
			shift_in 	: in STD_LOGIC_VECTOR(C_NUM_TRANSFER_BITS -1 downto 0);
			shift_out 	: out STD_LOGIC_VECTOR(C_NUM_TRANSFER_BITS -1 downto 0);
			Cin 		: in STD_LOGIC;
			Cout 		: out STD_LOGIC
		);
	end component shift_reg;

	signal tx_buff, rx_buff : STD_LOGIC_VECTOR(C_NUM_TRANSFER_BITS -1 downto 0);
	signal reg_write : STD_LOGIC := '0';

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
			reg_write   => reg_write,
			shift_in	=> tx_buff,
			shift_out	=> rx_buff,
			Cin 		=> MOSI_I,
			Cout 		=> MISO_O
		);
			
	internal_counter : process (int_clk)
	begin
		if(int_clk'EVENT and int_clk = '1') then
		fifo_r <= 'Z';
			if(resetn = '0') then
				ic <= 0;
				tx_buff <= (others => 'Z');
				rx_buff <= (others => 'Z');
				fifo_r <= 'Z';
				reg_write <= '0';
			elsif(SPISEL = '1') then
			    fifo_r <= '0';
			    reg_write <= '0';
				if(ic < C_NUM_TRANSFER_BITS) then
					ic <= ic + 1;
				elsif(ic = C_NUM_TRANSFER_BITS) then
					fifo_r <= '1';
					reg_write <= '1';
					if(tx_empty = '0') then
						if(lsb_first = '0') then
							tx_buff <= tx_data((C_NUM_TRANSFER_BITS - 1) downto 0);
						else
							tx_buff <= tx_data(0 to (C_NUM_TRANSFER_BITS - 1));
						end if;
					end if;
					
					if(rx_full = '0') then 
						rx_data <= rx_buff;
					end if;
					
					ic <= 0;
				else
					ic <= 0;
				end if;
			else
			     rx_data <= (others => 'Z');
			     fifo_r <= 'Z';
		         fifo_w <= 'Z';
			end if;
		end if;
	end process internal_counter;
end Behavioral;