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

entity SPI_CU is
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
           slave_select_mode : in STD_LOGIC; --(IPISR)ss mode fault error generation, to be implemented
           slave_mode_fault_error : in STD_LOGIC;
           mode_fault_error_en : in STD_LOGIC;
           ss_mode_fault_int_en : in STD_LOGIC;
           loopback_en : in STD_LOGIC := '0';
           slave_mode_fault_int_en : in STD_LOGIC);
end SPI_CU;

architecture Behavioral of SPI_CU is
signal sck_origin : STD_LOGIC := '0';
signal irpt_temp : STD_LOGIC := '0';
signal mode_fault_error_temp : STD_LOGIC := '0';
begin
    
    --interrupt generation
    IP2INTC_Irpt <= 'Z'                 when spi_system_en = '0' else
                    '0'                 when resetn = '0'        else
                    irpt_temp and gi_en;
                    
    irpt_temp <= (not spi_system_en) and (      
                                          (slave_select_mode and ss_mode_fault_int_en) 
                                          or
                                          (slave_mode_fault_int_en and slave_mode_fault_error) 
                                          or
                                          (mode_fault_error_temp and mode_fault_error_en)
                                         );
                 
    --clock polarity and phase setup
    sck_origin <= '0'       when resetn = '0'        else
                  BRG_SCK_O when spi_master_en = '1' else 
                  SCK_I     when spi_master_en = '0' else
                  '0';
                  
    int_clk <=     'Z'        when spi_system_en = '0'       else
                   '0'        when resetn = '0'              else
                   sck_origin when cpha = '0' and cpol = '0' else
               not sck_origin when cpha = '0' and cpol = '1' else
               not sck_origin when cpha = '1' and cpol = '0' else
                   sck_origin when cpha = '1' and cpol = '1' else
                   '0';
    --SCK_O master mode generation and SCK_T
    SCK_O <= 'Z'       when spi_system_en = '0' else
             '0'       when resetn = '0'        else
             BRG_SCK_O when spi_master_en = '1' else
             'Z';
    SCK_T <= '1'               when spi_system_en = '0' else
             '1'               when resetn = '0'        else --SCK_T is active low
             not spi_master_en;
    
    --Slave Mode select generation
    slave_mode_select <= 'Z'               when spi_system_en = '0' else
                         '0'               when resetn = '0'        else
                         not spi_master_en;
    
    --Loopback functionality
    int_MOSI_I <= '0'        when resetn = '0'      else
                  MOSI_I     when loopback_en = '0' else
                  int_MISO_O;
    int_MISO_I <= '0'        when resetn = '0'      else
                  MISO_I     when loopback_en = '0' else
                  int_MOSI_O;
    MOSI_O     <= 'Z'        when spi_system_en = '0' else
                  '0'        when resetn = '0'        else
                  int_MOSI_O when loopback_en = '0'   else
                  'Z'; 
    MISO_O     <= 'Z'        when spi_system_en = '0' else
                  '0'        when resetn = '0'        else
                  int_MISO_O when loopback_en = '0'   else
                  'Z';
    --Mode Fault Error generation
    mode_fault_error_temp <= 'Z'  when spi_system_en = '0'                  else
                             '0'  when resetn = '0'                         else
                             '1'  when spi_master_en = '1' and SPISEL = '0' else
                             '0';
    mode_fault_error <= mode_fault_error_temp;
end Behavioral;
