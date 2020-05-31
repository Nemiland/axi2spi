library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;


entity SPI_BRG_tb is
           Generic (
           C_BASEADDR : unsigned := X"100";
           C_HIGHADDR : unsigned := X"200";
           C_S_AXI_ADDR_WIDTH : integer := 32;
           C_S_AXI_DATA_WIDTH : integer := 32);
end SPI_BRG_tb;

architecture behave of SPI_BRG_tb is

component SPI_BRG
    Generic (
           C_SCK_RATIO : integer := 32);
    Port ( S_AXI_ACLK : in STD_LOGIC := '0';
           resetn : in STD_LOGIC := '0';
           BRG_SCK_O : out STD_LOGIC);
end component;
signal S_AXI_ACLK : STD_LOGIC := '0';
signal resetn_1, resetn_2, resetn_4, resetn_8, resetn_16, resetn_32 : STD_LOGIC := '0';
signal SCK_O_1, SCK_O_2, SCK_O_4, SCK_O_8, SCK_O_16, SCK_O_32 : STD_LOGIC := '0';
           
begin

spi_brg_inst_ratio_1: SPI_BRG Generic Map(
                      C_SCK_RATIO => 1)
                      Port Map( 
                      S_AXI_ACLK => S_AXI_ACLK,
                      resetn => resetn_1,
                      BRG_SCK_O => SCK_O_1
                      );
spi_brg_inst_ratio_2: SPI_BRG Generic Map(
                      C_SCK_RATIO => 2)
                      Port Map( 
                      S_AXI_ACLK => S_AXI_ACLK,
                      resetn => resetn_2,
                      BRG_SCK_O => SCK_O_2
                      );           
spi_brg_inst_ratio_4: SPI_BRG Generic Map(
                      C_SCK_RATIO => 4)
                      Port Map( 
                      S_AXI_ACLK => S_AXI_ACLK,
                      resetn => resetn_4,
                      BRG_SCK_O => SCK_O_4
                      );
spi_brg_inst_ratio_8: SPI_BRG Generic Map(
                      C_SCK_RATIO => 8)
                      Port Map( 
                      S_AXI_ACLK => S_AXI_ACLK,
                      resetn => resetn_8,
                      BRG_SCK_O => SCK_O_8
                      );
spi_brg_inst_ratio_16: SPI_BRG Generic Map(
                      C_SCK_RATIO => 16)
                      Port Map( 
                      S_AXI_ACLK => S_AXI_ACLK,
                      resetn => resetn_16,
                      BRG_SCK_O => SCK_O_16
                      );
spi_brg_inst_ratio_32: SPI_BRG Generic Map(
                      C_SCK_RATIO => 32)
                      Port Map( 
                      S_AXI_ACLK => S_AXI_ACLK,
                      resetn => resetn_32,
                      BRG_SCK_O => SCK_O_32
                      );                      
-- clock gen
process
  begin
   wait for 500 ps;
   S_AXI_ACLK <= not S_AXI_ACLK;
end process;




    process
	begin
	    --------------------------------------SPI_BRG_01--------------------------------------------------
	    --SPI_BRG_01_1
	    wait until falling_edge(S_AXI_ACLK);
	    resetn_1 <= '1';
	    for i in 0 to (1*2)-1 loop
	       wait until falling_edge(S_AXI_ACLK);
	    end loop;
	    report "SPI_BRG_01_1 Check that SCK_O_1 clock signal has the period of 1ns (total of two cycles generated)"
	       severity warning;
	    resetn_1 <= '0';
	    
	    --SPI_BRG_01_2
	    wait until falling_edge(S_AXI_ACLK);
	    resetn_2 <= '1';
	    for i in 0 to (2*2)-1 loop
	       wait until falling_edge(S_AXI_ACLK);
	    end loop;
	    report "SPI_BRG_01_2 Check that SCK_O_2 clock signal has the period of 2ns (total of two cycles generated)"
	       severity warning;
	    resetn_2 <= '0';
	    
	    --SPI_BRG_01_3
	    wait until falling_edge(S_AXI_ACLK);
	    resetn_4 <= '1';
	    for i in 0 to (4*2)-1 loop
	       wait until falling_edge(S_AXI_ACLK);
	    end loop;
	    report "SPI_BRG_01_3 Check that SCK_O_4 clock signal has the period of 4ns (total of two cycles generated)"
	       severity warning;
	    resetn_4 <= '0';
	    
	    --SPI_BRG_01_4
	    wait until falling_edge(S_AXI_ACLK);
	    resetn_8 <= '1';
	    for i in 0 to (8*2)-1 loop
	       wait until falling_edge(S_AXI_ACLK);
	    end loop;
	    report "SPI_BRG_01_4 Check that SCK_O_8 clock signal has the period of 8ns (total of two cycles generated)"
	       severity warning;
	    resetn_8 <= '0';
	    
	    --SPI_BRG_01_5
	    wait until falling_edge(S_AXI_ACLK);
	    resetn_16 <= '1';
	    for i in 0 to (16*2)-1 loop
	       wait until falling_edge(S_AXI_ACLK);
	    end loop;
	    report "SPI_BRG_01_5 Check that SCK_O_16 clock signal has the period of 16ns (total of two cycles generated)"
	       severity warning;
	    resetn_16 <= '0';
	    
	    --SPI_BRG_01_6
	    wait until falling_edge(S_AXI_ACLK);
	    resetn_32 <= '1';
	    for i in 0 to (32*2)-1 loop
	       wait until falling_edge(S_AXI_ACLK);
	    end loop;
	    report "SPI_BRG_01_6 Check that SCK_O_32 clock signal has the period of 32ns (total of two cycles generated)"
	       severity warning;
	    resetn_32 <= '0';
	    
	end process;

 stop_sim : process
   begin
     wait for 133 ns; --run
     assert false
       report "simulation ended"
       severity failure;
   end process stop_sim;

end behave;
