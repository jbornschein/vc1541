----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:22:52 10/10/2006 
-- Design Name: 
-- Module Name:    par_io - Behavioral 
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

entity par_io is
    Port ( addr : in  STD_LOGIC_VECTOR (4 downto 0);
           reset : in std_logic;
			  clk : in  STD_LOGIC;
           cs : in  STD_LOGIC;
           we : in  STD_LOGIC;
           data_i : in  STD_LOGIC_VECTOR (7 downto 0);
           data_o : out  STD_LOGIC_VECTOR (7 downto 0);
           par_i_a : in  STD_LOGIC_VECTOR (31 downto 0);
			  par_i_b : in  STD_LOGIC_VECTOR (31 downto 0); 
           par_o_a : out  STD_LOGIC_VECTOR (31 downto 0);
			  
			  disp_o_a : out std_logic_vector(5 downto 0);
			  disp_io_b : inout std_logic_vector(7 downto 0)
	);
		
end par_io;

architecture rtl of par_io is

signal disp_b_latch : std_logic_vector(7 downto 0);
signal disp_a_latch : std_logic_vector(7 downto 0);

signal disp_b_ddr : std_logic_vector(7 downto 0);


begin

	disp_o_a <= disp_a_latch(5 downto 0);

	disp_io_b(0) <= disp_b_latch(0) when disp_b_ddr(0) = '1' else 'Z';
	disp_io_b(1) <= disp_b_latch(1) when disp_b_ddr(1) = '1' else 'Z';
	disp_io_b(2) <= disp_b_latch(2) when disp_b_ddr(2) = '1' else 'Z';
	disp_io_b(3) <= disp_b_latch(3) when disp_b_ddr(3) = '1' else 'Z';
	disp_io_b(4) <= disp_b_latch(4) when disp_b_ddr(4) = '1' else 'Z';
	disp_io_b(5) <= disp_b_latch(5) when disp_b_ddr(5) = '1' else 'Z';
	disp_io_b(6) <= disp_b_latch(6) when disp_b_ddr(6) = '1' else 'Z';
	disp_io_b(7) <= disp_b_latch(7) when disp_b_ddr(7) = '1' else 'Z';
	
	process(clk, reset, cs, we)
	begin
	if reset = '1' then
		par_o_a <= (others => '0');
	elsif clk'event and clk = '0' then
		if cs = '1' and we = '0' then
			case addr is
				when "00000" => data_o <= par_i_a(7 downto 0);
				when "00001" => data_o <= par_i_a(15 downto 8);
				when "00010" => data_o <= par_i_a(23 downto 16);
				when "00011" => data_o <= par_i_a(31 downto 24);
				when "01000" => data_o <= par_i_b(7 downto 0);
				when "01001" => data_o <= par_i_b(15 downto 8);
				when "01010" => data_o <= par_i_b(23 downto 16);
				when "01011" => data_o <= par_i_b(31 downto 24);
				
				when "10000" => data_o <= disp_a_latch;
				when "10001" => data_o <= disp_io_b;
				when others => null;
			end case;
			
		end if;
		if cs = '1' and we = '1' then
			case addr is
				when "00100" => par_o_a(7 downto 0) <= data_i;
				when "00101" => par_o_a(15 downto 8) <= data_i;
				when "00110" => par_o_a(23 downto 16) <= data_i;
				when "00111" => par_o_a(31 downto 24) <= data_i;
				
				when "10000" => disp_a_latch <= data_i;
				when "10001" => disp_b_latch <= data_i;
				when "10010" => disp_b_ddr <= data_i;
				when others => null;
			end case;
		end if;
	end if;
	end process;

end rtl;
