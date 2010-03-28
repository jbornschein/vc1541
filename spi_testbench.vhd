----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:39:13 11/12/2006 
-- Design Name: 
-- Module Name:    spi_testbench - Behavioral 
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

entity spi_testbench is
end spi_testbench;

architecture Behavioral of spi_testbench is

signal reset : std_logic;
signal clk : std_logic;

signal cs : std_logic;
signal mimo : std_logic;

begin

spi0: entity work.spi
    Port map ( reset => reset,
				clk => clk,
				adr => "0000",
				data_i => "11001010",
				--data_o =>
				cs => cs,
				we => '1',
				--spi_sck
				spi_mosi => mimo, 
				spi_miso => mimo
				--spi_cs
				);
				
				
	
	clkproc: process is
	begin
		clk <= '1', '0' after 125ns;
		wait for 125ns;
	end process;

	cs <= '0', '1' after 200ns, '0' after 300ns;

	reset <= '1', '0' after 100ns;


end Behavioral;

