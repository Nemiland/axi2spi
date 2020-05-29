library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;


entity AXI_2_SPI_tb is
   Generic( 
           C_BASEADDR : unsigned := X"100";
           C_HIGHADDR : unsigned := X"200";
           C_FIFO_EXIST : std_logic := '0';
           C_S_AXI_ADDR_WIDTH : integer := 32;
           C_S_AXI_DATA_WIDTH : integer := 32;
           C_NUM_TRANSFER_BITS : integer := 32; 
           C_NUM_SS_BITS : integer := 8;
           C_SCK_RATIO : integer := 32
          );
end AXI_2_SPI_tb;

architecture behave of AXI_2_SPI_tb is

component AXI_2_SPI
  Generic( C_BASEADDR : unsigned := X"100";
           C_HIGHADDR : unsigned := X"200";
           C_FIFO_EXIST : std_logic := '0';
           C_S_AXI_ADDR_WIDTH : integer := 32;
           C_S_AXI_DATA_WIDTH : integer := 32;
           C_NUM_TRANSFER_BITS : integer := 32; 
           C_NUM_SS_BITS : integer := 8;
           C_SCK_RATIO : integer := 32
         );
    Port ( 
           IP2INTC_Irpt : out STD_LOGIC;
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
           SS_I : in STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
           SS_O : out STD_LOGIC_VECTOR ((C_NUM_SS_BITS - 1) downto 0);
           SS_T : out STD_LOGIC;
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
           S_AXI_RREADY : in STD_LOGIC := '0'
         );
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
signal IP2INTC_Irpt, SCK_I, SCK_O, SCK_T, MOSI_I, MOSI_O, MOSI_T, MISO_I, MISO_O, MISO_T, SPISEL, SS_T: STD_LOGIC := '0';       
signal SS_I, SS_O : STD_LOGIC_VECTOR(C_NUM_SS_BITS-1 downto 0) := (others => '0');
begin

AXI_2_SPI_inst: AXI_2_SPI
  Generic Map ( 
                C_BASEADDR => C_BASEADDR,
                C_HIGHADDR => C_HIGHADDR,
                C_FIFO_EXIST => C_FIFO_EXIST,
                C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,
                C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
                C_NUM_TRANSFER_BITS => C_NUM_TRANSFER_BITS, 
                C_NUM_SS_BITS => C_NUM_SS_BITS,
                C_SCK_RATIO => C_SCK_RATIO
              )
    Port Map ( 
               IP2INTC_Irpt  => IP2INTC_Irpt,
               SCK_I         => SCK_I,
               SCK_O         => SCK_O,
               SCK_T         => SCK_T,
               MOSI_I        => MOSI_I,
               MOSI_O        => MOSI_O,
               MOSI_T        => MOSI_T,
               MISO_I        => MISO_I,
               MISO_O        => MISO_O,
               MISO_T        => MISO_T,
               SPISEL        => SPISEL,
               SS_I          => SS_I,
               SS_O          => SS_O,
               SS_T          => SS_T,
               S_AXI_ACLK    => S_AXI_ACLK,
               S_AXI_ARESETN => S_AXI_ARESETN,
               S_AXI_AWADDR  => S_AXI_AWADDR,
               S_AXI_AWVALID => S_AXI_AWVALID,
               S_AXI_AWREADY => S_AXI_AWREADY,
               S_AXI_WDATA   => S_AXI_WDATA,
               S_AXI_WSTB    => S_AXI_WSTB,
               S_AXI_WVALID  => S_AXI_WVALID,
               S_AXI_WREADY  => S_AXI_WREADY,
               S_AXI_BRESP   => S_AXI_BRESP,
               S_AXI_BVALID  => S_AXI_BVALID,
               S_AXI_BREADY  => S_AXI_BREADY,
               S_AXI_ARADDR  => S_AXI_ARADDR,
               S_AXI_ARVALID => S_AXI_ARVALID,
               S_AXI_ARREADY => S_AXI_ARREADY,
               S_AXI_RDATA   => S_AXI_RDATA,
               S_AXI_RRESP   => S_AXI_RRESP,
               S_AXI_RVALID  => S_AXI_RVALID,
               S_AXI_RREADY  => S_AXI_RREADY
             );

-- clock gen
process
  begin
   wait for 10 ns;
   S_AXI_ACLK <= not S_AXI_ACLK;
end process;




    process
	begin
	    --reset process
	    S_AXI_ARESETN <= '0';
	    wait until falling_edge(S_AXI_ACLK);
	    S_AXI_ARESETN <= '1';
	    
	    --Write test data into send register
	    wait until falling_edge(S_AXI_ACLK);
	    S_AXI_WDATA <= X"AAAACCCC";
	    S_AXI_AWADDR <= X"00000168"; --SPIDTR
	    S_AXI_WSTB <= "1111";
	    S_AXI_WVALID <= '1';
	    S_AXI_AWVALID <= '1';
	    S_AXI_BREADY <= '1';
	    wait until (S_AXI_BVALID = '1');
	    wait until falling_edge(S_AXI_ACLK);
	    S_AXI_WDATA <= X"00000000";
	    S_AXI_AWADDR <= X"00000000";
	    S_AXI_WSTB <= "0000";
	    S_AXI_WVALID <= '0';
	    S_AXI_AWVALID <= '0';
	    S_AXI_BREADY <= '0';
	    
	    --Set up manual Slave select destinaiton
	    wait until falling_edge(S_AXI_ACLK);
	    S_AXI_WDATA <= X"FFFFFF7F";
	    S_AXI_AWADDR <= X"00000170"; --SPISSR
	    S_AXI_WSTB <= "1111";
	    S_AXI_WVALID <= '1';
	    S_AXI_AWVALID <= '1';
	    S_AXI_BREADY <= '1';
	    wait until (S_AXI_BVALID = '1');
	    wait until falling_edge(S_AXI_ACLK);
	    S_AXI_WDATA <= X"00000000";
	    S_AXI_AWADDR <= X"00000000"; --SPIDTR
	    S_AXI_WSTB <= "0000";
	    S_AXI_WVALID <= '0';
	    S_AXI_AWVALID <= '0';
	    S_AXI_BREADY <= '0';
	    
	    --Update SPICR to setup loopback and start transmission
	    wait until falling_edge(S_AXI_ACLK);
	    S_AXI_WDATA <= X"000000A7";
	    S_AXI_AWADDR <= X"00000160"; --SPIDTR
	    S_AXI_WSTB <= "1111";
	    S_AXI_WVALID <= '1';
	    S_AXI_AWVALID <= '1';
	    S_AXI_BREADY <= '1';
	    wait until (S_AXI_BVALID = '1');
	    wait until falling_edge(S_AXI_ACLK);
	    S_AXI_WDATA <= X"00000000";
	    S_AXI_AWADDR <= X"00000000"; --SPIDTR
	    S_AXI_WSTB <= "0000";
	    S_AXI_WVALID <= '0';
	    S_AXI_AWVALID <= '0';
	    S_AXI_BREADY <= '0';
	    
	    --Wait until interrupt and read data from receiver register
	    
	end process;

 stop_sim : process
   begin
     wait for 1160 ns; --run
     assert false
       report "simulation ended"
       severity failure;
   end process stop_sim;

end behave;
