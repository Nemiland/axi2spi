--Author: Devon Stedronsky
--Date: April/May 2020
--Description : AXI2SPI ASYNCH FIFO MODULE


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AXI2SPI_AFIFO is
generic (
			C_NUM_TRANSFER_BITS : integer := 32;
			C_FIFO_EXIST : std_logic := '0'
		);
		
port( 
		wdata : 						in std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0) := (others => '0');
		w_enable, r_enable, reset : 	in std_logic;
		wclk, rclk : 					in std_logic := '0';
		rdata : 						out std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
		full_flag, empty_flag : 		out std_logic;
		occupancy : 					out std_logic_vector (3 downto 0);
		fifo_half :                     out std_logic
		);
end AXI2SPI_AFIFO;

architecture behavior of AXI2SPI_AFIFO is

type FIFO_array is array (0 to 15) of std_logic_vector((C_NUM_TRANSFER_BITS - 1) downto 0);
signal occupancy_temp : std_logic_vector (3 downto 0) := (others => '0');
signal fifo_half_temp : std_logic := '0';
signal rdata_temp_f, rdata_sync, rdata_temp_s: std_logic_vector ((C_NUM_TRANSFER_BITS - 1) downto 0) := (others => '0');
signal fifo : FIFO_array := (others => (others => '0'));
signal wpointer, rpointer, wpointer_sync, rpointer_sync, Qr, Qw, ptr_diff : std_logic_vector (4 downto 0) := (others => '0');
signal r_round, Qrr, r_round_sync, w_round, Qrw, w_round_sync: std_logic := '0';
signal fflag_temp_s, eflag_temp_s: std_logic := '0';

begin
--STANDARD FIFO
-----------------------------------------------------------------------------
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
                rdata_temp_f <= fifo(conv_integer(rpointer(3 downto 0)));
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

--ADDED AXI2SPI FUNCTIONALITY
----------------------------------------------------------------------------------------
--occupancy output
process (wpointer, rpointer)
begin
    if (wpointer(4) = rpointer(4)) then
        occupancy_temp <= wpointer(3 downto 0) - rpointer(3 downto 0);
    elsif (wpointer(4) /= rpointer(4)) then
        occupancy_temp <= 16 - rpointer(3 downto 0) - wpointer(3 downto 0);
    end if;   
end process;

--sync bypass
process (rclk,  reset)
begin
    if (reset = '1') then	
		rdata_sync <= (others => '0');
		rdata_temp_s <= (others => '0');
	else
	   if (rising_edge(rclk)) then
	       rdata_sync <= wdata;
	       rdata_temp_s <= rdata_sync;
	   end if;
	end if;
end process;

--fifo_half
fifo_half_temp <= '1' when occupancy_temp = "1000" else '0';
-------------------------------------------------------------------------------------
--empty and full flags
fflag_temp_s  <= '1' when ((wpointer(3 downto 0) = rpointer_sync(4 downto 0)) and (wpointer (4) /= rpointer_sync(4))) else '0';
eflag_temp_s  <= '1' when ((wpointer_sync - rpointer) = "00000")  else '0';
full_flag <= fflag_temp_s;
empty_flag <= eflag_temp_s;
--------------------------------------------------------------------------------------------

occupancy <= occupancy_temp;
fifo_half <= fifo_half_temp;

--SYNC BYPASS
rdata <= rdata_temp_f when C_FIFO_EXIST = '1' else rdata_temp_s;

end behavior;



