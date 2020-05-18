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

entity SPI_IF is
    Port ( tx_data : in STD_LOGIC_VECTOR (0 downto 0);
           rx_data : out STD_LOGIC_VECTOR (0 downto 0);
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
           SS_I : in STD_LOGIC_VECTOR (0 downto 0);
           SS_O : out STD_LOGIC_VECTOR (0 downto 0);
           SS_T : out STD_LOGIC;
           resetn : in STD_LOGIC;
           S_AXI_ACLK : in STD_LOGIC;
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
           slave_select : in STD_LOGIC_VECTOR (0 downto 0);
           gi_en : in STD_LOGIC;
           slave_select_mode : in STD_LOGIC;
           slave_mode_fault_error : out STD_LOGIC;
           mode_fault_error : out STD_LOGIC;
           ss_mode_fault_int_en : in STD_LOGIC;
           slave_mode_fault_int_en : in STD_LOGIC);
end SPI_IF;

architecture Behavioral of SPI_IF is

begin


end Behavioral;
