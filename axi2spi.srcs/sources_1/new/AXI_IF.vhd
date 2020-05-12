----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/12/2020 10:42:56 AM
-- Design Name: 
-- Module Name: AXI_IF - Behavioral
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

entity AXI_IF is
    Port ( S_AXI_ACLK : in STD_LOGIC;
           S_AXI_ARESETN : in STD_LOGIC;
           S_AXI_AWADDR : in STD_LOGIC_VECTOR (0 downto 0);
           S_AXI_AWVALID : in STD_LOGIC;
           S_AXI_AWREADY : out STD_LOGIC;
           S_AXI_WDATA : in STD_LOGIC_VECTOR (15 downto 0);
           S_AXI_WSTB : in STD_LOGIC;
           S_AXI_WVALID : in STD_LOGIC;
           S_AXI_WREADY : out STD_LOGIC;
           S_AXI_BRESP : out STD_LOGIC_VECTOR (1 downto 0);
           S_AXI_BVALID : out STD_LOGIC;
           S_AXI_BREADY : in STD_LOGIC;
           S_AXI_ARADDR : in STD_LOGIC_VECTOR (0 downto 0);
           S_AXI_ARVALID : in STD_LOGIC;
           S_AXI_ARREADY : out STD_LOGIC;
           S_AXI_RDATA : out STD_LOGIC_VECTOR (0 downto 0);
           S_AXI_RRESP : out STD_LOGIC_VECTOR (1 downto 0);
           S_AXI_RVALID : out STD_LOGIC;
           S_AXI_RREADY : in STD_LOGIC;
           srr_cs : out STD_LOGIC;
           spicr_cs : out STD_LOGIC;
           spisr_cs : out STD_LOGIC;
           spidtr_cs : out STD_LOGIC;
           spidrr_cs : out STD_LOGIC;
           spissr_cs : out STD_LOGIC;
           tx_fifo_ocy_cs : out STD_LOGIC;
           rx_fifo_ocy_cs : out STD_LOGIC;
           dgier_cs : out STD_LOGIC;
           ipisr_cs : out STD_LOGIC;
           ipier_cs : out STD_LOGIC;
           reg_rack : in STD_LOGIC;
           reg_read_enable : out STD_LOGIC;
           reg_rdata : in STD_LOGIC_VECTOR (0 downto 0);
           reg_rerror : in STD_LOGIC;
           reg_wack : in STD_LOGIC;
           reg_wdata : in STD_LOGIC_VECTOR (0 downto 0);
           reg_wstr : out STD_LOGIC_VECTOR (0 downto 0);
           reg_werror : in STD_LOGIC;
           reg_write_enable : out STD_LOGIC);
end AXI_IF;

architecture Behavioral of AXI_IF is

begin


end Behavioral;
