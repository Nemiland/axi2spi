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
           shift_tx_port : in STD_LOGIC;
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
end SPI_Master;

architecture Behavioral of SPI_Master is
type state is (busy, idle, off);
signal master_state : state := idle;
signal nxt_state : state := idle;
signal MOSI_O_temp : STD_LOGIC := '0';
signal shift_rx_port_temp : STD_LOGIC := '0';
signal ss_temp : STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0) := (others=> '0');
signal ss_t_temp : STD_LOGIC := '1';
begin

    SPI_PROC : process(int_clk, resetn)
    begin
        if(rising_edge(int_clk)) then
           if(resetn = '0') then
                MOSI_O_temp <= '0';
                shift_rx_port_temp <= '0';
            else
                if(master_state = off) then
                    MOSI_O_temp <= '0';
                    shift_rx_port_temp <= '0';
                elsif(nxt_state = busy) then
                    MOSI_O_temp <= shift_tx_port;
                    shift_rx_port_temp <= MISO_I;
                else
                    MOSI_O_temp <= '0';
                    shift_rx_port_temp <= '0';
                end if;
            end if;
        end if;
    end process;
    
    SS_PROC : process(int_clk, resetn)
    variable ss_count : integer range 0 to (C_NUM_SS_BITS - 1) := 0;
    begin
        if(rising_edge(int_clk)) then
           if(resetn = '0') then
                ss_temp <= (others => '1');
                ss_t_temp <= '1';
                ss_count := 0;
            else
                if(master_state = off) then
                    ss_temp <= (others => '1');
                    ss_t_temp <= '1';
                else
                    ss_t_temp <= '0';
                    if(manual_ss_en = '1') then
                        ss_temp <= slave_select;
                    else
                        ss_temp <= (others => '1');
                        ss_temp(ss_count) <= '0';
                        if(ss_count = (C_NUM_SS_BITS - 1)) then
                            ss_count := 0;
                        else
                            ss_count := ss_count + 1;
                        end if;             
                    end if;
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
end Behavioral;
