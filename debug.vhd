----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:08:12 10/31/2006 
-- Design Name: 
-- Module Name:    debug - Behavioral 
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

entity debug is
    Port ( c_clk : in std_logic;
				c_reset : in std_logic;
           c_addr : in  STD_LOGIC_VECTOR (7 downto 0);
           c_dat_o : out  STD_LOGIC_VECTOR (7 downto 0);
           c_dat_i : in  STD_LOGIC_VECTOR (7 downto 0);
           c_cs : in  STD_LOGIC;
           c_we : in  STD_LOGIC;
           d_addr : in  STD_LOGIC_VECTOR (15 downto 0);
--           d_dat_i : in  STD_LOGIC_VECTOR (7 downto 0);
--           d_dat_o : in  STD_LOGIC_VECTOR (7 downto 0);
			  d_clk : in  STD_LOGIC;
			  --address history
			  log_addr_count : in std_logic_vector(14 downto 0);
			  --registers from processor
			  d_akk_i :in std_logic_vector(7 downto 0);
			  d_x_i :in std_logic_vector(7 downto 0);
			  d_y_i :in std_logic_vector(7 downto 0);
			  d_p_i :in std_logic_vector(7 downto 0);
			  --clock to target
			  gate_clk_i : in  STD_LOGIC;
           gate_clk_o : out  STD_LOGIC);
end debug;

architecture Behavioral of debug is

signal d_clk_old : std_logic;

signal bpx0 : std_logic_vector (15 downto 0);

signal bpx_enable : std_logic_vector (7 downto 0);
signal bpx_flag : std_logic_vector (7 downto 0);

signal clk_gate : std_logic;

begin	
	
	process(c_clk, c_cs, c_we)
	begin
		if c_reset = '1' then
			bpx_enable <= (others => '0');
			bpx_flag <= (others => '0');
		elsif c_clk'event and c_clk = '0' then
			--read registers
			if c_cs = '1' and c_we = '0' then
				case c_addr is
					when x"10" => c_dat_o <= bpx_enable;
					when x"11" => c_dat_o <= bpx_flag;
					when x"20" => c_dat_o <= d_akk_i;
					when x"21" => c_dat_o <= d_x_i;
					when x"22" => c_dat_o <= d_y_i;
					when x"23" => c_dat_o <= d_p_i;
					when x"30" => c_dat_o <= log_addr_count(6 downto 0) & "0";
					when x"31" => c_dat_o <= log_addr_count(14 downto 7);
					when others => null;
				end case;
				
			end if;
			--write registers
			if c_cs = '1' and c_we = '1' then
				case c_addr is
					when x"00" => bpx0(7 downto 0) <= c_dat_i;
					when x"01" => bpx0(15 downto 8) <= c_dat_i;
					when x"10" => bpx_enable <= c_dat_i;
					when x"11" => bpx_flag <= bpx_flag and not c_dat_i;
					when others => null;
				end case;
			end if;
		
			d_clk_old <= d_clk;
			if d_clk_old = '1' and d_clk = '0' then
				if bpx0 = d_addr then
					bpx_flag(0) <= '1';
				end if;
			end if;
			
		end if;
	end process;
	
	clk_gate <= '0' when ((bpx_enable(0) and bpx_flag(0)) = '1') or
								((bpx_enable(1) and bpx_flag(1)) = '1') else
					'1';
					
	gate_clk_o <= gate_clk_i and clk_gate;
	
end Behavioral;

