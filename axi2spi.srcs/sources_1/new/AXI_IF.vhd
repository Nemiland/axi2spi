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
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AXI_IF is
        Generic (
           C_BASEADDR : unsigned := X"100";
           C_HIGHADDR : unsigned := X"200";
           C_S_AXI_ADDR_WIDTH : integer := 32;
           C_S_AXI_DATA_WIDTH : integer := 32);
        Port ( 
           S_AXI_ACLK : in STD_LOGIC;
           S_AXI_ARESETN : in STD_LOGIC;
           S_AXI_AWADDR : in STD_LOGIC_VECTOR ((C_S_AXI_ADDR_WIDTH - 1) downto 0);
           S_AXI_AWVALID : in STD_LOGIC;
           S_AXI_AWREADY : out STD_LOGIC;
           S_AXI_WDATA : in STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0);
           S_AXI_WSTB : in STD_LOGIC_VECTOR (((C_S_AXI_DATA_WIDTH)-1) downto 0);
           S_AXI_WVALID : in STD_LOGIC;
           S_AXI_WREADY : out STD_LOGIC;
           S_AXI_BRESP : out STD_LOGIC_VECTOR (1 downto 0);
           S_AXI_BVALID : out STD_LOGIC;
           S_AXI_BREADY : in STD_LOGIC;
           S_AXI_ARADDR : in STD_LOGIC_VECTOR ((C_S_AXI_ADDR_WIDTH - 1) downto 0);
           S_AXI_ARVALID : in STD_LOGIC;
           S_AXI_ARREADY : out STD_LOGIC;
           S_AXI_RDATA : out STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0);
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
signal srr_cs_temp, spicr_cs_temp, spisr_cs_temp, spidtr_cs_temp,
       spidrr_cs_temp, spissr_cs_temp, tx_fifo_ocy_cs_temp, 
       rx_fifo_ocy_cs_temp, dgier_cs_temp, ipisr_cs_temp,
       ipier_cs_temp, reg_read_enable_temp, reg_write_enable_temp,
       rerror_temp, werror_temp : std_logic := '0';
signal module_address_select : std_logic := '0';
begin
    module_address_select <= '1' when signed(S_AXI_ARADDR) - signed(C_BASEADDR) > 0 AND
                                      signed(S_AXI_ARADDR) - signed(C_HIGHADDR) < 0 else
                             '1' when signed(S_AXI_AWADDR) - signed(C_BASEADDR) > 0 AND
                                      signed(S_AXI_AWADDR) - signed(C_HIGHADDR) < 0 else
                             '0';
    process(S_AXI_ACLK, S_AXI_ARESETN)
    begin
        if(rising_edge(S_AXI_ACLK)) then
            if(S_AXI_ARESETN = '0') then
                srr_cs_temp           <= '0';
                spicr_cs_temp         <= '0';
                spisr_cs_temp         <= '0';
                spidtr_cs_temp        <= '0';
                spidrr_cs_temp        <= '0';
                spissr_cs_temp        <= '0';
                tx_fifo_ocy_cs_temp   <= '0';
                rx_fifo_ocy_cs_temp   <= '0';
                dgier_cs_temp         <= '0';
                ipisr_cs_temp         <= '0';
                ipier_cs_temp         <= '0';
                reg_read_enable_temp  <= '0';
                reg_write_enable_temp <= '0';
                rerror_temp           <= '0';
                werror_temp           <= '0';
            else
                if(S_AXI_ARVALID = '1') then
                    --read scenarios
                    if(S_AXI_ARADDR = conv_std_logic_vector(C_BASEADDR + 64, C_S_AXI_ADDR_WIDTH)) then  --0x40 = 64
                        --SRR is Write only
                        --srr_cs               <= '1';
                        rerror_temp          <= '1';
                        reg_read_enable_temp <= '1';
                    elsif(S_AXI_ARADDR = conv_std_logic_vector(C_BASEADDR + 96, C_S_AXI_ADDR_WIDTH)) then  --0x60 = 96
                        --SPICR is R/W
                        spicr_cs             <= '1';
                        --rerror_temp          <= '1';
                        reg_read_enable_temp <= '1';
                    elsif(S_AXI_ARADDR = conv_std_logic_vector(C_BASEADDR + 100, C_S_AXI_ADDR_WIDTH)) then  --0x64 = 100
                        --SPISR is Read only
                        spisr_cs             <= '1';
                        --rerror_temp          <= '1';
                        reg_read_enable_temp <= '1';
                    elsif(S_AXI_ARADDR = conv_std_logic_vector(C_BASEADDR + 104, C_S_AXI_ADDR_WIDTH)) then  --0x68 = 104
                        --SPIDTR is Write only
                        --spidtr_cs             <= '1';
                        rerror_temp          <= '1';
                        reg_read_enable_temp <= '1';
                    elsif(S_AXI_ARADDR = conv_std_logic_vector(C_BASEADDR + 108, C_S_AXI_ADDR_WIDTH)) then  --0x6c = 108
                        --SPIDRR is Read only
                        spidrr_cs            <= '1';
                        --rerror_temp          <= '1';
                        reg_read_enable_temp <= '1';
                    elsif(S_AXI_ARADDR = conv_std_logic_vector(C_BASEADDR + 112, C_S_AXI_ADDR_WIDTH)) then  --0x70 = 112
                        --SPISSR is R/W
                        spissr_cs            <= '1';
                        --rerror_temp          <= '1';
                        reg_read_enable_temp <= '1';
                    elsif(S_AXI_ARADDR = conv_std_logic_vector(C_BASEADDR + 116, C_S_AXI_ADDR_WIDTH)) then  --0x74 = 116
                        --Tx_fifo_ocy is Read only
                        tx_fifo_ocy_cs       <= '1';
                        --rerror_temp          <= '1';
                        reg_read_enable_temp <= '1';
                    elsif(S_AXI_ARADDR = conv_std_logic_vector(C_BASEADDR + 120, C_S_AXI_ADDR_WIDTH)) then  --0x78 = 120
                        --Rx_fifo_ocy is Read only
                        rx_fifo_ocy_cs       <= '1';
                        --rerror_temp          <= '1';
                        reg_read_enable_temp <= '1';
                    elsif(S_AXI_ARADDR = conv_std_logic_vector(C_BASEADDR + 28, C_S_AXI_ADDR_WIDTH)) then  --0x1c = 28
                        --DGIER is R/W
                        dgier_cs             <= '1';
                        --rerror_temp          <= '1';
                        reg_read_enable_temp <= '1';
                    elsif(S_AXI_ARADDR = conv_std_logic_vector(C_BASEADDR + 32, C_S_AXI_ADDR_WIDTH)) then  --0x20 = 32
                        --IPISR is R/TOW
                        ipisr_cs             <= '1';
                        --rerror_temp          <= '1';
                        reg_read_enable_temp <= '1';
                    elsif(S_AXI_ARADDR = conv_std_logic_vector(C_BASEADDR + 40, C_S_AXI_ADDR_WIDTH)) then  --0x28 = 40
                        --IPIER is R/W
                        ipier_cs             <= '1';
                        --rerror_temp          <= '1';
                        reg_read_enable_temp <= '1';
                        
                    end if;
                elsif(S_AXI_AWVALID = '1') then
                    --write scenarios
                    if(S_AXI_AWADDR = conv_std_logic_vector(C_BASEADDR + 64, C_S_AXI_ADDR_WIDTH)) then  --0x40 = 64
                        --SRR is Write only
                        srr_cs                <= '1';
                        --rerror_temp           <= '1';
                        reg_write_enable_temp <= '1';
                    elsif(S_AXI_AWADDR = conv_std_logic_vector(C_BASEADDR + 96, C_S_AXI_ADDR_WIDTH)) then  --0x60 = 96
                        --SPICR is R/W
                        spicr_cs              <= '1';
                        --rerror_temp           <= '1';
                        reg_write_enable_temp <= '1';
                    elsif(S_AXI_AWADDR = conv_std_logic_vector(C_BASEADDR + 100, C_S_AXI_ADDR_WIDTH)) then  --0x64 = 100
                        --SPISR is Read only
                        --spisr_cs             <= '1';
                        werror_temp           <= '1';
                        reg_write_enable_temp <= '1';
                    elsif(S_AXI_AWADDR = conv_std_logic_vector(C_BASEADDR + 104, C_S_AXI_ADDR_WIDTH)) then  --0x68 = 104
                        --SPIDTR is Write only
                        spidtr_cs             <= '1';
                        --werror_temp           <= '1';
                        reg_write_enable_temp <= '1';
                    elsif(S_AXI_AWADDR = conv_std_logic_vector(C_BASEADDR + 108, C_S_AXI_ADDR_WIDTH)) then  --0x6c = 108
                        --SPIDRR is Read only
                        --spidrr_cs            <= '1';
                        werror_temp           <= '1';
                        reg_write_enable_temp <= '1';
                    elsif(S_AXI_AWADDR = conv_std_logic_vector(C_BASEADDR + 112, C_S_AXI_ADDR_WIDTH)) then  --0x70 = 112
                        --SPISSR is R/W
                        spissr_cs             <= '1';
                        --werror_temp           <= '1';
                        reg_write_enable_temp <= '1';
                    elsif(S_AXI_AWADDR = conv_std_logic_vector(C_BASEADDR + 116, C_S_AXI_ADDR_WIDTH)) then  --0x74 = 116
                        --Tx_fifo_ocy is Read only
                        --tx_fifo_ocy_cs        <= '1';
                        werror_temp           <= '1';
                        reg_write_enable_temp <= '1';
                    elsif(S_AXI_AWADDR = conv_std_logic_vector(C_BASEADDR + 120, C_S_AXI_ADDR_WIDTH)) then  --0x78 = 120
                        --Rx_fifo_ocy is Read only
                        --rx_fifo_ocy_cs        <= '1';
                        werror_temp           <= '1';
                        reg_write_enable_temp <= '1';
                    elsif(S_AXI_AWADDR = conv_std_logic_vector(C_BASEADDR + 28, C_S_AXI_ADDR_WIDTH)) then  --0x1c = 28
                        --DGIER is R/W
                        dgier_cs              <= '1';
                        --werror_temp           <= '1';
                        reg_write_enable_temp <= '1';
                    elsif(S_AXI_AWADDR = conv_std_logic_vector(C_BASEADDR + 32, C_S_AXI_ADDR_WIDTH)) then  --0x20 = 32
                        --IPISR is R/TOW
                        ipisr_cs              <= '1';
                        --werror_temp           <= '1';
                        reg_write_enable_temp <= '1';
                    elsif(S_AXI_AWADDR = conv_std_logic_vector(C_BASEADDR + 40, C_S_AXI_ADDR_WIDTH)) then  --0x28 = 40
                        --IPIER is R/W
                        ipier_cs              <= '1';
                        --werror_temp           <= '1';
                        reg_write_enable_temp <= '1';
                    else
                        srr_cs_temp           <= '0';
                        spicr_cs_temp         <= '0';
                        spisr_cs_temp         <= '0';
                        spidtr_cs_temp        <= '0';
                        spidrr_cs_temp        <= '0';
                        spissr_cs_temp        <= '0';
                        tx_fifo_ocy_cs_temp   <= '0';
                        rx_fifo_ocy_cs_temp   <= '0';
                        dgier_cs_temp         <= '0';
                        ipisr_cs_temp         <= '0';
                        ipier_cs_temp         <= '0';
                        reg_read_enable_temp  <= '0';
                        reg_write_enable_temp <= '0';
                        rerror_temp           <= '0';
                        werror_temp           <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
