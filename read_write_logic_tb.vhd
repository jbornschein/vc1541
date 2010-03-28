----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:41:27 10/06/2006 
-- Design Name: 
-- Module Name:    read_write_logic_tb - Behavioral 
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

entity read_write_logic_tb is
end read_write_logic_tb;

architecture Behavioral of read_write_logic_tb is

	signal ds : std_logic_vector(1 downto 0);
	signal res_n : std_logic;
	signal clk16 : std_logic;
	
	signal bitstream_in : std_logic;
	signal bitstream_out : std_logic;
	


begin

	rwl: entity work.read_write_logic
    Port map ( res_n => res_n,
	 			clk16_in => clk16,
				ds => "00",
				bitstream_in => bitstream_in,
				bitstream_out => bitstream_out,
				byte_in => "11001010",
           mode => '1',
           soe => '1'
			  );


	clkproc: process is
	begin
		clk16 <= '1', '0' after 31.25ns;
		wait for 62.5ns;
	end process;
	
	res_n <= '0', '1' after 1ns;

	bitstream_in <= '1', bitstream_out after 10000ns;

end Behavioral;

