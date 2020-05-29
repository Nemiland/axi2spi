--Author: Eric Wagner
--Date: May 2020
--
--Description : AXI2SPI SPI SHIFT REGISTER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift_reg is
Generic (
		C_NUM_TRANSFER_BITS : integer := 32
);
Port (  
		clk			: in STD_LOGIC;
		resetn 		: in STD_LOGIC;
		shift_en	: in STD_LOGIC;

		shift_in 	: in STD_LOGIC_VECTOR(C_NUM_TRANSFER_BITS -1 downto 0);
		shift_out 	: out STD_LOGIC_VECTOR(C_NUM_TRANSFER_BITS -1 downto 0);
		Cin 		: in STD_LOGIC;
        Cout 		: out STD_LOGIC
);
end shift_reg;

architecture Behavioral of shift_reg is
	signal cout_temp : STD_LOGIC := '0';
	signal shift_out_temp : STD_LOGIC_VECTOR(C_NUM_TRANSFER_BITS - 1 downto 0) := (others => '0');
begin
	process(clk)
	begin
		if(clk'EVENT and clk = '1') then
			if(resetn = '0') then
				shift_out_temp <= (others => '0');
				cout_temp <= '0';
			elsif(shift_en = '1') then
				cout_temp <= shift_in(C_NUM_TRANSFER_BITS - 1);
				shift_out_temp <= shift_in(C_NUM_TRANSFER_BITS - 2 downto 0) & cin;
			else
			    cout_temp <= 'Z';
				shift_out_temp <= (others => 'Z');
			
			end if;
		end if;
	end process;
	
	cout <= cout_temp;
	shift_out <= shift_out_temp;
		
end Behavioral;
