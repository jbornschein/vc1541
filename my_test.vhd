----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:31:23 10/01/2006 
-- Design Name: 
-- Module Name:    my_test - Behavioral 
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

entity my_test is
end my_test;

architecture Behavioral of my_test is

signal clk   : std_logic;
signal res_n : std_logic;
signal led   : std_logic;
signal motor : std_logic;
signal bus_clk_in       : std_logic;
signal bus_clk_out_int  : std_logic;
signal bus_data_in      : std_logic;
signal bus_data_out_int : std_logic;
signal bus_atn_in       : std_logic;


begin

	floppy: entity work.vc1541
		port map(clk4       => clk,
					res_n      => res_n,
               --
               led        => led,
               motor      => motor,
               -- 
               bus_clk_in  => bus_clk_in,
               bus_clk_out => bus_clk_out_int,
               bus_data_in => bus_data_in,
               bus_data_out=> bus_data_out_int,
               bus_atn_in  => bus_atn_in );

	clkproc: process is
	begin
		clk <= '1', '0' after 125ns;
		wait for 250ns;
	end process;

	res_n <= '0', '1' after 2000ns;
	
	bus_clk_in <= '1';
	bus_data_in <='1';
	bus_atn_in <='1';

end Behavioral;

