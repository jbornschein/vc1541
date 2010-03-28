----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:37:46 10/16/2006 
-- Design Name: 
-- Module Name:    bin2gcr - Behavioral 
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

entity bin2gcr is
    Port ( bin : in  STD_LOGIC_VECTOR (31 downto 0);
           gcr : out  STD_LOGIC_VECTOR (39 downto 0));
end bin2gcr;

architecture Behavioral of bin2gcr is

begin


with bin(31 downto 28) select
	  gcr (39 downto 35) <=
			"01010" when "0000",
			"01011" when "0001",
			"10010" when "0010",
			"10011" when "0011",
			"01110" when "0100",
			"01111" when "0101",
			"10110" when "0110",
			"10111" when "0111",
			"01001" when "1000",
			"11001" when "1001",
			"11010" when "1010",
			"11011" when "1011",
			"01101" when "1100",
			"11101" when "1101",
			"11110" when "1110",
			"10101" when others;

with bin(27 downto 24) select
	  gcr (34 downto 30) <=
			"01010" when "0000",
			"01011" when "0001",
			"10010" when "0010",
			"10011" when "0011",
			"01110" when "0100",
			"01111" when "0101",
			"10110" when "0110",
			"10111" when "0111",
			"01001" when "1000",
			"11001" when "1001",
			"11010" when "1010",
			"11011" when "1011",
			"01101" when "1100",
			"11101" when "1101",
			"11110" when "1110",
			"10101" when others;

with bin(23 downto 20) select
	  gcr (29 downto 25) <=
			"01010" when "0000",
			"01011" when "0001",
			"10010" when "0010",
			"10011" when "0011",
			"01110" when "0100",
			"01111" when "0101",
			"10110" when "0110",
			"10111" when "0111",
			"01001" when "1000",
			"11001" when "1001",
			"11010" when "1010",
			"11011" when "1011",
			"01101" when "1100",
			"11101" when "1101",
			"11110" when "1110",
			"10101" when others;

with bin(19 downto 16) select
	  gcr (24 downto 20) <=
			"01010" when "0000",
			"01011" when "0001",
			"10010" when "0010",
			"10011" when "0011",
			"01110" when "0100",
			"01111" when "0101",
			"10110" when "0110",
			"10111" when "0111",
			"01001" when "1000",
			"11001" when "1001",
			"11010" when "1010",
			"11011" when "1011",
			"01101" when "1100",
			"11101" when "1101",
			"11110" when "1110",
			"10101" when others;

with bin(15 downto 12) select
	  gcr (19 downto 15) <=
			"01010" when "0000",
			"01011" when "0001",
			"10010" when "0010",
			"10011" when "0011",
			"01110" when "0100",
			"01111" when "0101",
			"10110" when "0110",
			"10111" when "0111",
			"01001" when "1000",
			"11001" when "1001",
			"11010" when "1010",
			"11011" when "1011",
			"01101" when "1100",
			"11101" when "1101",
			"11110" when "1110",
			"10101" when others;

with bin(11 downto 8) select
	  gcr (14 downto 10) <=
			"01010" when "0000",
			"01011" when "0001",
			"10010" when "0010",
			"10011" when "0011",
			"01110" when "0100",
			"01111" when "0101",
			"10110" when "0110",
			"10111" when "0111",
			"01001" when "1000",
			"11001" when "1001",
			"11010" when "1010",
			"11011" when "1011",
			"01101" when "1100",
			"11101" when "1101",
			"11110" when "1110",
			"10101" when others;

with bin(7 downto 4) select
	  gcr (9 downto 5) <=
			"01010" when "0000",
			"01011" when "0001",
			"10010" when "0010",
			"10011" when "0011",
			"01110" when "0100",
			"01111" when "0101",
			"10110" when "0110",
			"10111" when "0111",
			"01001" when "1000",
			"11001" when "1001",
			"11010" when "1010",
			"11011" when "1011",
			"01101" when "1100",
			"11101" when "1101",
			"11110" when "1110",
			"10101" when others;

with bin(3 downto 0) select
	  gcr (4 downto 0) <=
			"01010" when "0000",
			"01011" when "0001",
			"10010" when "0010",
			"10011" when "0011",
			"01110" when "0100",
			"01111" when "0101",
			"10110" when "0110",
			"10111" when "0111",
			"01001" when "1000",
			"11001" when "1001",
			"11010" when "1010",
			"11011" when "1011",
			"01101" when "1100",
			"11101" when "1101",
			"11110" when "1110",
			"10101" when others;


end Behavioral;

