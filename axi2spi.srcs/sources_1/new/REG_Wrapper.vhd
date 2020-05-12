----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/12/2020 10:42:56 AM
-- Design Name: 
-- Module Name: REG_Wrapper - Behavioral
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

entity REG_Wrapper is
    Port ( reg_rack : out STD_LOGIC;
           reg_read_enable : in STD_LOGIC;
           reg_rdata : out STD_LOGIC_VECTOR (0 downto 0);
           reg_rerror : out STD_LOGIC;
           reg_wack : out STD_LOGIC;
           reg_wdata : out STD_LOGIC_VECTOR (0 downto 0);
           reg_wstr : in STD_LOGIC_VECTOR (0 downto 0);
           reg_werror : out STD_LOGIC;
           reg_write_enable : in STD_LOGIC);
end REG_Wrapper;

architecture Behavioral of REG_Wrapper is

begin


end Behavioral;
