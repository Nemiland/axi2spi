--Author: Andrew Newman
--Date: May 2020
--
--Description : AXI2SPI BAUD RATE GENERATOR

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

entity SPI_BRG is
    Generic (
           C_SCK_RATIO : integer := 32);
    Port ( S_AXI_ACLK : in STD_LOGIC := '0';
           resetn : in STD_LOGIC := '0';
           BRG_SCK_O : out STD_LOGIC);
end SPI_BRG;

architecture Behavioral of SPI_BRG is
signal clock_counter : integer range 0 to C_SCK_RATIO-1 := 0;
signal clock_div_1_toggle : boolean := false;
signal int_clk_temp : STD_LOGIC := '0';
begin
    
    process(S_AXI_ACLK, resetn)
    begin
        if(resetn = '0') then
            clock_div_1_toggle <= false;
        else
            if(rising_edge(S_AXI_ACLK)) then
                if(C_SCK_RATIO = 1) then
                    clock_div_1_toggle <= true;
                else 
                    clock_div_1_toggle <= false;
                end if;
            end if;
        end if;
    end process;
    
    
    process(S_AXI_ACLK, resetn)
    begin
        if(resetn = '0') then
            clock_counter <= 0;
            int_clk_temp <= '0';
        else
            if(rising_edge(S_AXI_ACLK)) then
                if(C_SCK_RATIO = 2) then
                    int_clk_temp <= not int_clk_temp;
                else
                    if(clock_counter = ((C_SCK_RATIO / 2) - 1)) then
                        int_clk_temp <= not int_clk_temp;
                        clock_counter <= C_SCK_RATIO / 2;
                    elsif(clock_counter = (C_SCK_RATIO - 1)) then
                        int_clk_temp <= not int_clk_temp;
                        clock_counter <= 0;
                    else
                        clock_counter <= clock_counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    BRG_SCK_O <= S_AXI_ACLK when clock_div_1_toggle else
               int_clk_temp;
    end Behavioral;
