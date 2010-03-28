----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:30:43 11/12/2006 
-- Design Name: 
-- Module Name:    spi - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi is
    Port ( reset : in std_logic;
				clk : in std_logic;
				adr : in  STD_LOGIC_VECTOR (3 downto 0);
           data_i : in  STD_LOGIC_VECTOR (7 downto 0);
           data_o : out  STD_LOGIC_VECTOR (7 downto 0);
           cs : in  STD_LOGIC;
           we : in  STD_LOGIC;
           spi_sck : out  STD_LOGIC;
           spi_mosi : out  STD_LOGIC;
           spi_miso : in  STD_LOGIC;
           spi_cs : out  STD_LOGIC);
end spi;

architecture rtl of spi is

signal bitcount : std_logic_vector(2 downto 0);
signal ilatch : std_logic;
signal run : std_logic;
signal sck : std_logic;

signal prescaler : std_logic_vector(3 downto 0);
signal divisor : std_logic_vector(3 downto 0);

signal sreg : std_logic_vector(7 downto 0);

begin

	spi_sck <= sck;
	spi_mosi <= sreg(7);

	process(reset, clk)
	begin
		if reset = '1' then
			sck <= '0';
			bitcount <= "000";
			run <= '0';
			prescaler <= (others => '0');
			divisor <= "1000";
		elsif clk'event and clk = '0' then
			prescaler <= prescaler + 1;
			if prescaler = divisor then
				prescaler <= (others => '0');
				if run = '1' then
					sck <= not sck;
					if sck = '1' then
						bitcount <= bitcount + 1;
						if bitcount = "111" then
							run <= '0';
						end if;
						
						sreg (7) <= sreg(6);
						sreg (6) <= sreg(5);
						sreg (5) <= sreg(4);
						sreg (4) <= sreg(3);
						sreg (3) <= sreg(2);
						sreg (2) <= sreg(1);
						sreg (1) <= sreg(0);
						sreg (0) <= ilatch;
					else
						ilatch <= spi_miso;
					end if;
					
				end if;
			end if;
			if cs = '1' and we = '0' then
				case adr is
					when "0000" => data_o <= sreg;
					when "0001" => data_o <= "0000000" & run;
					when others => null;
				end case;
			end if;
			if cs = '1' and we = '1' then
				case adr is
					when "0000" => sreg <= data_i; run <= '1';
					when "0010" => spi_cs <= data_i(0);
					when "0100" => divisor <= data_i(3 downto 0);
					when others => null;
				end case;
			end if;
		end if;
	end process;

end rtl;

