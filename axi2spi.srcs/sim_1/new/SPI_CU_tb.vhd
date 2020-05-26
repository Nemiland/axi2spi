library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;


entity SPI_CU_tb is
end SPI_CU_tb;

architecture behave of SPI_CU_tb is

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
           slave_select_mode : in STD_LOGIC;
           slave_mode_fault_error : in STD_LOGIC;
           mode_fault_error_en : in STD_LOGIC;
           ss_mode_fault_int_en : in STD_LOGIC;
           loopback_en : in STD_LOGIC := '0';
           slave_mode_fault_int_en : in STD_LOGIC);
end component;

signal SCK_I, SCK_O, SCK_T,
       int_MOSI_I, int_MOSI_O, int_MISO_I, int_MISO_O,
       MOSI_I, MOSI_O, MOSI_T,
       MISO_I, MISO_O, MISO_T, SPISEL,
       IP2INTC_Irpt, resetn,
       int_clk, BRG_SCK_O, cpha, cpol,
       spi_system_en, spi_master_en,
       slave_mode_select, mode_fault_error,
       gi_en, slave_select_mode, slave_mode_fault_error, 
       mode_fault_error_en, ss_mode_fault_int_en,
       loopback_en, slave_mode_fault_int_en : STD_LOGIC := '0';
           
begin

SPI_CU_inst: SPI_CU
         Port Map (SCK_I                   => SCK_I,
                   SCK_O                   => SCK_O,
                   SCK_T                   => SCK_T,
                   int_MOSI_I              => int_MOSI_I,
                   int_MOSI_O              => int_MOSI_O,
                   int_MISO_I              => int_MISO_I,
                   int_MISO_O              => int_MISO_O,
                   MOSI_I                  => MOSI_I,
                   MOSI_O                  => MOSI_O,
                   MOSI_T                  => MOSI_T,
                   MISO_I                  => MISO_I,
                   MISO_O                  => MISO_O,
                   MISO_T                  => MISO_T,
                   SPISEL                  => SPISEL,
                   IP2INTC_Irpt            => IP2INTC_Irpt,
                   resetn                  => resetn,
                   int_clk                 => int_clk,
                   BRG_SCK_O               => BRG_SCK_O,
                   cpha                    => cpha,
                   cpol                    => cpol,
                   spi_system_en           => spi_system_en,
                   spi_master_en           => spi_master_en,
                   slave_mode_select       => slave_mode_select,
                   mode_fault_error        => mode_fault_error,
                   gi_en                   => gi_en,
                   slave_select_mode       => slave_select_mode,
                   slave_mode_fault_error  => slave_mode_fault_error,
                   mode_fault_error_en     => mode_fault_error_en,
                   ss_mode_fault_int_en    => ss_mode_fault_int_en,
                   loopback_en             => loopback_en,
                   slave_mode_fault_int_en => slave_mode_fault_int_en);
  
-- clock gen
process
begin
   wait for 500 ps;
   BRG_SCK_O <= not BRG_SCK_O;
end process; 
 
process
begin
    wait until falling_edge(BRG_SCK_O);
    resetn <= '1';
    spi_system_en <= '1';
    
    --------------------------------------SPI_CU_01--------------------------------------------------
    --SPI_CU_01_1
    wait until falling_edge(BRG_SCK_O);
    SPISEL <= '1';
    spi_master_en <= '1';
    wait until falling_edge(BRG_SCK_O);
    assert mode_fault_error = '0'
       report "SPI_CU_01_1 FAIL: mode_fault_error = '0'"
       severity error;
    
    --SPI_CU_01_2
    wait until falling_edge(BRG_SCK_O);
    SPISEL <= '0';
    spi_master_en <= '1';
    wait until falling_edge(BRG_SCK_O);
    assert mode_fault_error = '1'
       report "SPI_CU_01_2 FAIL: mode_fault_error = '1'"
       severity error;
    SPISEL <= '0';
    
    --------------------------------------SPI_CU_02--------------------------------------------------
    --SPI_CU_02_1
    wait until falling_edge(BRG_SCK_O);
    spi_master_en <= '1';
    wait until falling_edge(BRG_SCK_O);
    assert slave_mode_select = '0'
       report "SPI_CU_02_1 FAIL: slave_mode_select = '0'"
       severity error;
    
    --SPI_CU_02_2
    wait until falling_edge(BRG_SCK_O);
    spi_master_en <= '0';
    wait until falling_edge(BRG_SCK_O);
    assert slave_mode_select = '1'
       report "SPI_CU_02_2 FAIL: slave_mode_select = '1'"
       severity error;
    spi_master_en <= '1';
    
    --------------------------------------SPI_CU_03--------------------------------------------------
    --SPI_CU_03_1
    wait until falling_edge(BRG_SCK_O);
    cpol <= '0';
    wait until falling_edge(BRG_SCK_O);
    assert int_clk = SCK_O
       report "SPI_CU_03_1 FAIL: int_clk != SCK_O"
       severity error;
    
    --SPI_CU_03_2
    wait until falling_edge(BRG_SCK_O);
    cpol <= '1';
    wait until falling_edge(BRG_SCK_O);
    assert int_clk = not SCK_O
       report "SPI_CU_03_2 FAIL: int_clk != SCK_O"
       severity error;
    cpol <= '0';
    
    --------------------------------------SPI_CU_04--------------------------------------------------
    --SPI_CU_04_1
    wait until falling_edge(BRG_SCK_O);
    spi_system_en <= '1';
    wait until falling_edge(BRG_SCK_O);
    report "SPI_CU_04_1 Check that system is on"
       severity error;
    
    --SPI_CU_04_2
    wait until falling_edge(BRG_SCK_O);
    spi_system_en <= '0';
    wait until falling_edge(BRG_SCK_O);
    report "SPI_CU_04_2 Check that system is off"
       severity error;
    spi_system_en <= '1';
    
    --------------------------------------SPI_CU_05--------------------------------------------------
    --prep
    MOSI_I <= '0';
    MISO_I <= '0';
    int_MOSI_O <= '1';
    int_MISO_O <= '1';
    
    --SPI_CU_05_1
    wait until falling_edge(BRG_SCK_O);
    loopback_en <= '1';
    wait until falling_edge(BRG_SCK_O);
    assert int_MOSI_I = int_MISO_O
       report "SPI_CU_05_1 FAIL: int_MOSI_I != int_MISO_O"
       severity error;
    assert int_MISO_I = int_MOSI_O
       report "SPI_CU_05_1 FAIL: int_MISO_I != int_MOSI_O"
       severity error;
       
    --SPI_CU_05_2
    wait until falling_edge(BRG_SCK_O);
    loopback_en <= '0';
    wait until falling_edge(BRG_SCK_O);
    assert int_MOSI_I /= int_MISO_O
       report "SPI_CU_05_2 FAIL: int_MOSI_I = int_MISO_O"
       severity error;
    assert int_MISO_I /= int_MOSI_O
       report "SPI_CU_05_2 FAIL: int_MISO_I = int_MOSI_O"
       severity error;
       
    
end process;

 stop_sim : process
   begin
     wait for 22 ns; --run
     assert false
       report "simulation ended"
       severity failure;
   end process stop_sim;

end behave;
