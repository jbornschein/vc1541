----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:55:40 11/10/2006 
-- Design Name: 
-- Module Name:    t65_testbench - Behavioral 
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

entity t65_testbench is
end t65_testbench;

architecture Behavioral of t65_testbench is

signal clk : std_logic;
signal res_n : std_logic;

signal addr : std_logic_vector(23 downto 0);
signal cpu_di : std_logic_vector(7 downto 0);


begin

	cpu: entity work.t65
	port map (Mode => "00",
				Res_n => res_n,
				Clk => clk,
				Rdy => '1',
				Abort_n => '1',
				IRQ_n => '1',
				NMI_n => '1',
				SO_n => '1',
				--R_W_n => rw_n,
				A => addr,
				DI => cpu_di
				--DO => cpu_do,
				--registers
				--akk_o => d_akk,
				--x_o => d_x,
				--y_o => d_y,
				--p_o => d_p
				);
				
	rom: entity work.t65_testrom 
	port map (addr	=> addr(7 downto 0),
				data => cpu_di,
				clk => clk);



	clkproc: process is
	begin
		clk <= '1', '0' after 125ns;
		wait for 250ns;
	end process;

	res_n <= '0', '1' after 2000ns;
	

end Behavioral;

