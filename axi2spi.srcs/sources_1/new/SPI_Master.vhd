----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/18/2020 12:55:29 PM
-- Design Name: 
-- Module Name: SPI_IF - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI_Master is
    Generic( C_NUM_TRANSFER_BITS : integer := 32; 
             C_NUM_SS_BITS : integer := 8
           );
    Port ( shift_rx_port : out STD_LOGIC;
           shift_tx_port : in STD_LOGIC := '0';
           shift_enable : out STD_LOGIC;
           MOSI_O : out STD_LOGIC;
           MISO_I : in STD_LOGIC := '0';
           SS_O : out STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
           resetn : in STD_LOGIC := '1';
           int_clk : in STD_LOGIC := '0';
           master_inhibit : in STD_LOGIC := '1';
           manual_ss_en : in STD_LOGIC := '0';
           spi_master_en : in STD_LOGIC := '0';
           tx_empty : in STD_LOGIC := '0';
           rx_full : in STD_LOGIC := '0';
           slave_select : in STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0) := (others => '0'));
end SPI_Master;

architecture Behavioral of SPI_Master is
type state is (busy, idle, off);
signal master_state : state := idle;
signal nxt_state : state := idle;
signal MOSI_O_temp : STD_LOGIC := '0';
signal shift_enable_temp, shift_rx_port_temp : STD_LOGIC := '0';
signal ss_temp, slave_select_latch : STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0) := (others=> '1');
signal ss_t_temp : STD_LOGIC := '1';
signal ss_count : integer range 0 to (C_NUM_SS_BITS - 1) := 0;
signal element_count : integer range 0 to (C_NUM_TRANSFER_BITS - 1) := 0;
    
begin

    SPI_PROC : process(int_clk, resetn)
    begin
        if(rising_edge(int_clk)) then
           if(resetn = '0') then
                MOSI_O_temp <= '0';
                shift_rx_port_temp <= '0';
                shift_enable_temp <= '0';
            else
               if(nxt_state = busy) then
                    MOSI_O_temp <= shift_tx_port;
                    shift_rx_port_temp <= MISO_I;
                    shift_enable_temp <= '1';
                else
                    MOSI_O_temp <= '0';
                    shift_rx_port_temp <= '0';
                    shift_enable_temp <= '0';
                end if;
            end if;
        end if;
    end process;
    
    SS_PROC : process(int_clk, resetn)
    begin
        if(rising_edge(int_clk)) then
           if(resetn = '0') then
                ss_temp <= (others => '1');
                ss_t_temp <= '1';
                ss_count <= 0;
                element_count <= 0;
            else
                if(master_state = off) then
                    ss_temp <= (others => '1');
                    ss_t_temp <= '1';
                    element_count <= 0;
                    ss_count <= 0;
                else
                    ss_t_temp <= '0';
                    if (element_count = C_NUM_TRANSFER_BITS - 1) then
                        element_count <= 0;
                    elsif(element_count = 0) then
                        element_count <= element_count + 1;
                        if(manual_ss_en = '1') then
                            slave_select_latch <= slave_select;
                        else
                            slave_select_latch <= (others => '1');
                            slave_select_latch(ss_count) <= '0';
                            if(ss_count = (C_NUM_SS_BITS - 1)) then
                                ss_count <= 0;
                            else
                                ss_count <= ss_count + 1;
                            end if;             
                        end if;
                    else
                        element_count <= element_count + 1;
                    end if;
                    ss_temp <= slave_select_latch;
                end if;
            end if;
        end if;
    end process;

    FSM_PROC : process(int_clk, resetn)
    begin
        if(rising_edge(int_clk)) then
           if(resetn = '0') then
                master_state <= off;
            else
                master_state <= nxt_state;
            end if;
        end if;    
    end process;
    
    NEXT_STATE_LOGIC : process(int_clk, resetn)
    begin
        if(rising_edge(int_clk)) then
            if(resetn = '0') then
                if(spi_master_en = '1') then
                    nxt_state <= idle;
                else
                    nxt_state <= off;
                end if;
            else
                case master_state is
                    when idle =>
                        if(spi_master_en = '0') then
                            nxt_state <= off;
                        elsif(master_inhibit = '1') then
                            nxt_state <= idle;
                        elsif(tx_empty = '1') then
                            nxt_state <= idle;
                        elsif(rx_full = '1') then
                            nxt_state <= idle;
                        else
                            nxt_state <= busy;
                        end if;
                    when busy =>
                        if(spi_master_en = '0') then
                            nxt_state <= off;
                        elsif(master_inhibit = '1') then
                            nxt_state <= idle;
                        elsif(tx_empty = '1') then
                            nxt_state <= idle;
                        elsif(rx_full = '1') then
                            nxt_state <= idle;
                        else
                            nxt_state <= busy;
                        end if;
                    when off =>	
                        if(spi_master_en = '0') then
                            nxt_state <= off;
                        elsif(master_inhibit = '1') then
                            nxt_state <= idle;
                        elsif(tx_empty = '1') then
                            nxt_state <= idle;
                        elsif(rx_full = '1') then
                            nxt_state <= idle;
                        else
                            nxt_state <= idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

    --I/O
    SS_O <= ss_temp;
    MOSI_O <= MOSI_O_temp;
    shift_rx_port <= shift_rx_port_temp;
    shift_enable <= shift_enable_temp;
end Behavioral;
