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

entity SPI_CU is
    Port ( SCK_I : in STD_LOGIC;
           SCK_O : out STD_LOGIC;
           SCK_T : out STD_LOGIC;
           SS_I : in STD_LOGIC_VECTOR (0 downto 0);
           SS_O : out STD_LOGIC_VECTOR (0 downto 0);
           SS_T : out STD_LOGIC;
           IP2INTC_Irpt : out STD_LOGIC;
           resetn : in STD_LOGIC;
           int_clk : out STD_LOGIC; --internal clock that is adjusted to coincide with cpha and cpol settings
           BRG_SCK_O : in STD_LOGIC;
           manual_ss_en : in STD_LOGIC;
           cpha : in STD_LOGIC := '0';
           cpol : in STD_LOGIC := '0';
           spi_master_en : in STD_LOGIC := '1';
           slave_mode_select : out STD_LOGIC;
           mode_fault_error : in STD_LOGIC;
           tx_empty : in STD_LOGIC;
           rx_full : in STD_LOGIC;
           slave_select : in STD_LOGIC_VECTOR (0 downto 0);
           gi_en : in STD_LOGIC := '0';
           slave_select_mode : in STD_LOGIC;
           slave_mode_fault_error : in STD_LOGIC;
           mode_fault_error_en : in STD_LOGIC;
           ss_mode_fault_int_en : in STD_LOGIC;
           slave_mode_fault_int_en : in STD_LOGIC);
end SPI_CU;

architecture Behavioral of SPI_CU is
signal sck_origin : STD_LOGIC := '0';
signal irpt_temp : STD_LOGIC := '0';
begin
    
    --interrupt generation
    IP2INTC_Irpt <= irpt_temp and gi_en;
    irpt_temp <= (slave_select_mode and ss_mode_fault_int_en) or
                 (slave_mode_fault_int_en and slave_mode_fault_error) or
                 (mode_fault_error and mode_fault_error_en);
                 
    --clock polarity and phase setup
    sck_origin <= BRG_SCK_O when spi_master_en = '1' else 
                  SCK_I     when spi_master_en = '0' else
                  '0';
    int_clk <=     sck_origin when cpha = '0' and cpol = '0' else
               not sck_origin when cpha = '0' and cpol = '1' else
               not sck_origin when cpha = '1' and cpol = '0' else
                   sck_origin when cpha = '1' and cpol = '1' else
                   '0';

    
end Behavioral;
