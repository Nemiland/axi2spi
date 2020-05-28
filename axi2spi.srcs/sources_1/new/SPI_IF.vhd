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
    Generic( C_NUM_TRANSFER_BITS : integer := 32; 
             C_NUM_SS_BITS : integer := 8;
             C_SCK_RATIO : integer := 32
           );
    Port ( tx_data : in STD_LOGIC_VECTOR (0 downto 0);
           rx_data : out STD_LOGIC_VECTOR (0 downto 0);
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
           spi_system_en : in STD_LOGIC;
           loopback_en : in STD_LOGIC;
           slave_mode_select : out STD_LOGIC;
           mode_fault_error : out STD_LOGIC;
           tx_empty : in STD_LOGIC;
           rx_full : in STD_LOGIC;
           slave_select : in STD_LOGIC_VECTOR (0 downto 0);
           gi_en : in STD_LOGIC;
           --slave_select_mode : in STD_LOGIC;
           slave_mode_fault_error : out STD_LOGIC;
           --ss_mode_fault_int_en : in STD_LOGIC;
           mode_fault_error_en : in STD_LOGIC;
           fifo_rw : out STD_LOGIC;
           slave_mode_fault_int_en : in STD_LOGIC);
end SPI_IF;

architecture Behavioral of SPI_IF is
component SPI_CU
    Port ( SCK_I : in STD_LOGIC;
           SCK_O : out STD_LOGIC;
           SCK_T : out STD_LOGIC;
           int_MOSI_I : out STD_LOGIC;
           int_MOSI_O : in STD_LOGIC := '0';
           int_MISO_I : out STD_LOGIC;
           int_MISO_O : in STD_LOGIC := '0';
           MOSI_I : in STD_LOGIC := '0';
           MOSI_O : out STD_LOGIC;
           MOSI_T : out STD_LOGIC;
           MISO_I : in STD_LOGIC := '0';
           MISO_O : out STD_LOGIC;
           MISO_T : out STD_LOGIC;
           SPISEL : in STD_LOGIC := '1';
           IP2INTC_Irpt : out STD_LOGIC;
           resetn : in STD_LOGIC := '0';
           int_clk : out STD_LOGIC; --internal clock that is adjusted to coincide with cpha and cpol settings
           BRG_SCK_O : in STD_LOGIC; --Clock generated from BRG
           cpha : in STD_LOGIC := '0';
           cpol : in STD_LOGIC := '0';
           spi_system_en : in STD_LOGIC := '0';
           spi_master_en : in STD_LOGIC := '1';
           slave_mode_select : out STD_LOGIC;
           mode_fault_error : out STD_LOGIC;
           gi_en : in STD_LOGIC := '0';
           --slave_select_mode : in STD_LOGIC;
           slave_mode_fault_error : in STD_LOGIC;
           mode_fault_error_en : in STD_LOGIC;
           --ss_mode_fault_int_en : in STD_LOGIC;
           loopback_en : in STD_LOGIC := '0';
           slave_mode_fault_int_en : in STD_LOGIC);
end component;

component SPI_BRG
    Generic (
           C_SCK_RATIO : integer := 32);
    Port ( S_AXI_ACLK : in STD_LOGIC := '0';
           resetn : in STD_LOGIC := '0';
           BRG_SCK_O : out STD_LOGIC);
end component;

component SPI_Master is
    Generic( C_NUM_TRANSFER_BITS : integer := 32; 
             C_NUM_SS_BITS : integer := 8
           );
    Port ( shift_rx : out STD_LOGIC_VECTOR(C_NUM_TRANSFER_BITS -1 downto 0);
           shift_tx : in STD_LOGIC_VECTOR(C_NUM_TRANSFER_BITS -1 downto 0) := (others => '0');
           MOSI_O : out STD_LOGIC;
           MISO_I : in STD_LOGIC := '0';
           SS_O : out STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
           fifo_rw : out STD_LOGIC := '0';
           resetn : in STD_LOGIC := '1';
           int_clk : in STD_LOGIC := '0';
           master_inhibit : in STD_LOGIC := '1';
           manual_ss_en : in STD_LOGIC := '0';
           spi_master_en : in STD_LOGIC := '0';
           tx_empty : in STD_LOGIC := '0';
           rx_full : in STD_LOGIC := '0';
           slave_select : in STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0) := (others => '0'));
end component;

signal BRG_SCK_O, int_MOSI_I, int_MOSI_O, int_MISO_I, int_MISO_O, slave_mode_fault_error_sig : STD_LOGIC := '0';
signal int_clk_temp : STD_LOGIC := '1';

begin

SPI_BRG_inst: SPI_BRG
    Generic Map(
               C_SCK_RATIO => C_SCK_RATIO
               )
    Port Map ( S_AXI_ACLK => S_AXI_ACLK,
               resetn => resetn,
               BRG_SCK_O => BRG_SCK_O
             );
SPI_CU_inst: SPI_CU
    Port Map ( SCK_I => SCK_I,
               SCK_O => SCK_O,
               SCK_T => SCK_T,
               int_MOSI_I => int_MOSI_I,
               int_MOSI_O => int_MOSI_O,
               int_MISO_I => int_MISO_I,
               int_MISO_O => int_MISO_O,
               MOSI_I => MOSI_I,
               MOSI_O => MOSI_O,
               MOSI_T => MOSI_T,
               MISO_I => MISO_I,
               MISO_O => MISO_O,
               MISO_T => MISO_T,
               SPISEL => SPISEL,
               IP2INTC_Irpt => IP2INTC_Irpt,
               resetn => resetn,
               int_clk => int_clk,
               BRG_SCK_O => BRG_SCK_O,
               cpha => cpha,
               cpol => cpol,
               spi_system_en => spi_system_en,
               spi_master_en => spi_master_en,
               slave_mode_select => slave_mode_select,
               mode_fault_error => mode_fault_error,
               gi_en => gi_en,
               --slave_select_mode => slave_select_mode,
               slave_mode_fault_error => slave_mode_fault_error_sig,
               mode_fault_error_en => mode_fault_error_en,
               --ss_mode_fault_int_en => ss_mode_fault_int_en,
               loopback_en => loopback_en,
               slave_mode_fault_int_en => slave_mode_fault_int_en
               );
   SPI_Master_inst: SPI_Master
        Generic Map( C_NUM_TRANSFER_BITS => C_NUM_TRANSFER_BITS,
                     C_NUM_SS_BITS => C_NUM_SS_BITS
                   )
        Port Map ( shift_rx => rx_data,
                   shift_tx => tx_data,
                   MOSI_O => MOSI_O,
                   MISO_I => MISO_I,
                   SS_O => SS_O,
                   fifo_rw => fifo_rw,
                   resetn => resetn,
                   int_clk => int_clk_temp,
                   master_inhibit => master_inhibit,
                   manual_ss_en => manual_ss_en,
                   spi_master_en => spi_master_en,
                   tx_empty => tx_empty,
                   rx_full => rx_full,
                   slave_select => slave_select
                 ); 
                 
    int_clk <= int_clk_temp;
end Behavioral;
