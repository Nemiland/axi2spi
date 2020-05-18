library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;


entity AXI_IF_tb is
           Generic (
           C_S_AXI_ADDR_WIDTH : integer := 32;
           C_S_AXI_DATA_WIDTH : integer := 32);
end AXI_IF_tb;

architecture behave of AXI_IF_tb is

component AXI_IF
        Generic (
           C_BASEADDR : unsigned := X"100";
           C_HIGHADDR : unsigned := X"200";
           C_S_AXI_ADDR_WIDTH : integer := 32;
           C_S_AXI_DATA_WIDTH : integer := 32);
        Port ( 
           S_AXI_ACLK : in STD_LOGIC := '0';
           S_AXI_ARESETN : in STD_LOGIC := '0';
           S_AXI_AWADDR : in STD_LOGIC_VECTOR ((C_S_AXI_ADDR_WIDTH - 1) downto 0) := (others => '0');
           S_AXI_AWVALID : in STD_LOGIC := '0';
           S_AXI_AWREADY : out STD_LOGIC;
           S_AXI_WDATA : in STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
           S_AXI_WSTB : in STD_LOGIC_VECTOR (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0) := (others => '0');
           S_AXI_WVALID : in STD_LOGIC := '0';
           S_AXI_WREADY : out STD_LOGIC;
           S_AXI_BRESP : out STD_LOGIC_VECTOR (1 downto 0);
           S_AXI_BVALID : out STD_LOGIC;
           S_AXI_BREADY : in STD_LOGIC := '0';
           S_AXI_ARADDR : in STD_LOGIC_VECTOR ((C_S_AXI_ADDR_WIDTH - 1) downto 0) := (others => '0');
           S_AXI_ARVALID : in STD_LOGIC := '0';
           S_AXI_ARREADY : out STD_LOGIC;
           S_AXI_RDATA : out STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
           S_AXI_RRESP : out STD_LOGIC_VECTOR (1 downto 0);
           S_AXI_RVALID : out STD_LOGIC;
           S_AXI_RREADY : in STD_LOGIC := '0';
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
           reg_rdata : in STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
           reg_rerror : in STD_LOGIC := '0';
           reg_wack : in STD_LOGIC := '0';
           reg_wdata : out STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0);
           reg_wstr : out STD_LOGIC_VECTOR (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0);
           reg_werror : in STD_LOGIC := '0';
           reg_write_enable : out STD_LOGIC);
end component;

signal S_AXI_ACLK, S_AXI_ARESETN, S_AXI_AWVALID, S_AXI_AWREADY : STD_LOGIC := '0';
signal S_AXI_AWADDR : STD_LOGIC_VECTOR ((C_S_AXI_ADDR_WIDTH - 1) downto 0) := (others => '0');
signal S_AXI_WDATA : STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal S_AXI_WSTB : STD_LOGIC_VECTOR (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0) := (others => '0');
signal S_AXI_WVALID, S_AXI_WREADY, S_AXI_BVALID, S_AXI_BREADY : STD_LOGIC := '0';
signal S_AXI_BRESP : STD_LOGIC_VECTOR (1 downto 0);
signal S_AXI_ARADDR : STD_LOGIC_VECTOR ((C_S_AXI_ADDR_WIDTH - 1) downto 0) := (others => '0');
signal S_AXI_ARVALID, S_AXI_RVALID, S_AXI_RREADY, S_AXI_ARREADY: STD_LOGIC := '0';
signal S_AXI_RDATA : STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal S_AXI_RRESP : STD_LOGIC_VECTOR (1 downto 0);
signal srr_cs, spicr_cs, spisr_cs, spidtr_cs, spidrr_cs: STD_LOGIC;
signal spissr_cs, tx_fifo_ocy_cs, rx_fifo_ocy_cs : STD_LOGIC;
signal dgier_cs, ipisr_cs, ipier_cs : STD_LOGIC;
signal reg_rack, reg_read_enable, reg_rerror : STD_LOGIC := '0';
signal reg_rdata, reg_wdata : STD_LOGIC_VECTOR ((C_S_AXI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal reg_wstr : STD_LOGIC_VECTOR (((C_S_AXI_DATA_WIDTH / 8) - 1) downto 0) := (others => '0');
signal reg_wack, reg_write_enable, reg_werror : STD_LOGIC := '0';

signal reg_to_test : STD_LOGIC_VECTOR ((C_S_AXI_ADDR_WIDTH - 1) downto 0) := X"00000160";
           
begin

axi_tb_inst: AXI_IF Port Map( 
           S_AXI_ACLK => S_AXI_ACLK,
           S_AXI_ARESETN => S_AXI_ARESETN,
           S_AXI_AWADDR => S_AXI_AWADDR,
           S_AXI_AWVALID => S_AXI_AWVALID,
           S_AXI_AWREADY => S_AXI_AWREADY,
           S_AXI_WDATA => S_AXI_WDATA,
           S_AXI_WSTB => S_AXI_WSTB,
           S_AXI_WVALID => S_AXI_WVALID,
           S_AXI_WREADY => S_AXI_WREADY,
           S_AXI_BRESP => S_AXI_BRESP,
           S_AXI_BVALID => S_AXI_BVALID,
           S_AXI_BREADY => S_AXI_BREADY,
           S_AXI_ARADDR => S_AXI_ARADDR,
           S_AXI_ARVALID => S_AXI_ARVALID,
           S_AXI_ARREADY => S_AXI_ARREADY,
           S_AXI_RDATA => S_AXI_RDATA,
           S_AXI_RRESP => S_AXI_RRESP,
           S_AXI_RVALID => S_AXI_RVALID,
           S_AXI_RREADY => S_AXI_RREADY,
           srr_cs => srr_cs,
           spicr_cs => spicr_cs,
           spisr_cs => spisr_cs,
           spidtr_cs => spidtr_cs,
           spidrr_cs => spidrr_cs,
           spissr_cs => spissr_cs,
           tx_fifo_ocy_cs => tx_fifo_ocy_cs,
           rx_fifo_ocy_cs => rx_fifo_ocy_cs,
           dgier_cs => dgier_cs,
           ipisr_cs => ipisr_cs,
           ipier_cs => ipier_cs,
           reg_rack => reg_rack,
           reg_read_enable => reg_read_enable,
           reg_rdata => reg_rdata,
           reg_rerror => reg_rerror,
           reg_wack => reg_wack,
           reg_wdata => reg_wdata,
           reg_wstr => reg_wstr,
           reg_werror => reg_werror,
           reg_write_enable => reg_write_enable);

-- reset process
process
begin
    wait for 10 ns;
    S_AXI_ARESETN <= '1';
end process;

-- clock gen
process
  begin
   wait for 10 ns;
   S_AXI_ACLK <= not S_AXI_ACLK;
end process;




    process
	begin
	    --run read
	    wait until falling_edge(S_AXI_ACLK);
	    S_AXI_ARADDR <= reg_to_test;
	    S_AXI_ARVALID <= '1';
	    wait until S_AXI_ARREADY = '1';
	    wait until falling_edge(S_AXI_ACLK);
	    S_AXI_ARVALID <= '0';
	    --read done, do write
	    --do write
	    S_AXI_AWADDR <= reg_to_test;
	    S_AXI_AWVALID <= '1';
	    S_AXI_WDATA <= "01010101010101010101010101010101";
        S_AXI_WSTB <= "0101";
        S_AXI_WVALID <= '1';
        --------------SIMULATES REGISTER BEHAVIOUR------------------------------
        wait until reg_write_enable = '1';
        wait until falling_edge(S_AXI_ACLK);
	    wait until falling_edge(S_AXI_ACLK);
	    reg_wack <= '1';
        --------------SIMULATES REGISTER BEHAVIOUR END---------------------------
        wait until S_AXI_AWREADY = '1' and S_AXI_WREADY = '1';
	    wait until falling_edge(S_AXI_ACLK);
	    S_AXI_AWVALID <= '0';
	    reg_wack <= '0';
        S_AXI_AWVALID <= '0';
	    S_AXI_WVALID <= '0';
	    --write done, run read
	    wait until falling_edge(S_AXI_ACLK);
	    S_AXI_ARADDR <= reg_to_test;
	    S_AXI_ARVALID <= '1';
	    --------------SIMULATES REGISTER BEHAVIOUR------------------------------
        wait until reg_read_enable = '1';
        wait until falling_edge(S_AXI_ACLK);
	    wait until falling_edge(S_AXI_ACLK);
	    reg_rack <= '1';
        --------------SIMULATES REGISTER BEHAVIOUR END---------------------------
	    wait until S_AXI_ARREADY = '1';
	    wait until falling_edge(S_AXI_ACLK);
	    reg_rack <= '0';
	    S_AXI_ARVALID <= '0';
	    --read done
    end process;
  
   



 stop_sim : process
   begin
     wait for 1000 ns; --run
     assert false
       report "simulation ended"
       severity failure;
   end process stop_sim;

end behave;
