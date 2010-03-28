----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:53:42 10/14/2006 
-- Design Name: 
-- Module Name:    rwl_testbench - Behavioral 
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

entity rwl_testbench is
end rwl_testbench;

architecture Behavioral of rwl_testbench is

signal res_n : std_logic;
signal reset : std_logic;
signal clk : std_logic;
signal bitstream_out : std_logic;
signal bitstream_in : std_logic;
signal bitclk : std_logic;
signal wb_stb_o : std_logic;
signal wb_ack_i : std_logic;


begin

rwl0: entity work.read_write_logic
    Port map( res_n => res_n,
				clk16_in => clk,
				ds => "11",
           bitclk_out => bitclk,
           bitstream_out => bitstream_out,
			  bitstream_in => bitstream_in,
--			  byte_out =>,
           byte_in => x"55",
           mode => '0',--write
--			  sync_n : out  STD_LOGIC;
--			  byte_n_out : out  STD_LOGIC;
           soe => '1');

vdisk0: entity work.vdisk
    Port map( clk16 => clk,
				reset => reset,
				--from floppy
				disk_write => '0',
				bitstream_in => bitstream_out,
           bitstream_out => bitstream_in,
			  bitclk => bitclk,
			  stepper => "00",
--			  track_number => "000000",
			  ds => "11",
			  --wishbone
				wb_stb_o => wb_stb_o,
				wb_ack_i => wb_ack_i,
--				wb_we_o   : out std_logic;
--				wb_adr_o  : out std_logic_vector(31 downto 0);
--				wb_dat_o  : out std_logic_vector( 7 downto 0);
				wb_dat_i => x"55"
			  );



	clkproc: process is
	begin
		clk <= '1', '0' after 31 ns;
		wait for 62ns;
	end process;

	wb_ack_i <= wb_stb_o;

	reset <= not res_n;
	res_n <= '0', '1' after 10 ns;
	
--	bitstream_in <= '0';

end Behavioral;

