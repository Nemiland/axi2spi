--Author: Devon Stedronsky
--Date: April 2020
--
--Description : AXI2SPI ASYNCH FIFO MODULE


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AXI2SPI_AFIFO is
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
end AXI2SPI_AFIFO;

architecture behavior of AXI2SPI_AFIFO is

type FIFO_array is array (0 to 15) of std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
signal fifo : FIFO_array;
signal wpointer, rpointer, wpointer_sync, rpointer_sync, Qr, Qw, ptr_diff : std_logic_vector (4 downto 0);
signal r_round, Qrr, r_round_sync, w_round, Qrw, w_round_sync: std_logic;
signal fflag_temp_s, eflag_temp_s: std_logic;

begin
-- Write:
process(wclk, reset)
begin
    if (reset = '1' ) then
        wpointer <= (others => '0');
		w_round  <= '0';
     else
        if rising_edge(wclk) then
            if w_enable = '1' and fflag_temp_s /= '1' then
                fifo(conv_integer(wpointer(3 downto 0))) <= wdata;
				wpointer <= wpointer + "00001";
            end if;
        end if;
    end if;
end process;

-- Read:
process(rclk, reset)
begin
    if (reset = '1') then
        rpointer <= (others => '0');
		r_round <= '0';
    else
         if rising_edge(rclk) then
            if r_enable = '1' and eflag_temp_s /= '1' then
                rdata <= fifo(conv_integer(rpointer(3 downto 0)));
				rpointer <= rpointer + "00001";
            end if;
        end if;
    end if;
end process;

-- wr_ptr Synchronization for read side
process(rclk, reset)
begin
    if reset = '1' then
         Qw <= (others => '0');
		wpointer_sync <= (others => '0');
    else
        if rising_edge(rclk) then
            Qw <= wpointer;
			wpointer_sync <= Qw;
        end if;
    end if;
end process;

-- rd_ptr Synchronization:
process(wclk,  reset)
begin
    if reset = '1' then
        rpointer_sync <= (others => '0') ;
        Qr <= (others => '0');
    else
        if rising_edge(wclk) then
            Qr <= rpointer;
            rpointer_sync <= Qr;
        end if;
    end if;
end process;

--occupancy output


fflag_temp_s  <= '1' when ((wpointer(3 downto 0) = rpointer_sync(4 downto 0)) and (wpointer (4) /= rpointer_sync(4))) else '0';
eflag_temp_s  <= '1' when ((wpointer_sync - rpointer) = "00000")  else '0';

full_flag <= fflag_temp_s;
empty_flag <= eflag_temp_s;

end behavior;








