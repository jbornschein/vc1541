----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:10:38 10/06/2006 
-- Design Name: 
-- Module Name:    read_write_logic - Behavioral 
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

entity read_write_logic is
    Port ( res_n : in std_logic;
				clk16_in : in  STD_LOGIC;
				ds : in std_logic_vector (1 downto 0);
           bitclk_out : out  STD_LOGIC;
           bitstream_out : out  STD_LOGIC;
           bitstream_in : in  STD_LOGIC;
           byte_out : out  STD_LOGIC_VECTOR (7 downto 0);
           byte_in : in  STD_LOGIC_VECTOR (7 downto 0);
           mode : in  STD_LOGIC;
           sync_n : out  STD_LOGIC;
			  byte_n_out : out  STD_LOGIC;
           soe : in  STD_LOGIC);
end read_write_logic;

architecture rtl of read_write_logic is
	signal clkh_cnt : std_logic_vector(3 downto 0);
	signal clkh : std_logic;
	signal clka : std_logic;
	signal bitclk : std_logic;
	signal byte_cnt : std_logic_vector(2 downto 0);
	signal byte : std_logic;
	signal sync : std_logic;

	signal wbyte : std_logic_vector(7 downto 0);
	signal rshreg : std_logic_vector(8 downto 0);
begin

	
	--generate bitclock
	process(clk16_in, res_n)
	begin	
		if res_n = '0' then
			clkh <= '0';
			clkh_cnt <= "0001";
		elsif clk16_in'event and clk16_in = '1' then
			clkh <= '0';
			clkh_cnt <= clkh_cnt + 1;
			if clkh_cnt = "1111" then
				clkh <= '1';
				case ds is  
					when "00" => clkh_cnt <= "0000";
					when "01" => clkh_cnt <= "0001";
					when "10" => clkh_cnt <= "0010";
					when "11" => clkh_cnt <= "0011";
					when others => null;
				end case;
			end if;
		end if;
	end process;

	process(clkh, res_n)
	begin
		if res_n = '0' then
			clka <= '0';
			bitclk <= '0';
		elsif clkh'event and clkh = '1' then
			clka <= not clka;
				if clka = '1' then
					bitclk <= not bitclk;
				end if;
		end if;
	end process;
	
	bitclk_out <= bitclk;
					
	byte_n_out <= not (byte and soe and (not bitclk));
				
	--write shift register
	process(bitclk, byte, byte_in, clka)
	begin
		if bitclk'event and bitclk = '1' then
			--counts the 8 bits in a byte
			byte_cnt <= byte_cnt + 1;
			
			--write shift register
			bitstream_out <= wbyte(7);
			wbyte(7) <= wbyte(6);
			wbyte(6) <= wbyte(5);
			wbyte(5) <= wbyte(4);
			wbyte(4) <= wbyte(3);
			wbyte(3) <= wbyte(2);
			wbyte(2) <= wbyte(1);
			wbyte(1) <= wbyte(0);
			wbyte(0) <= '0';
			
			if byte_cnt = "111" then
				wbyte <= byte_in;
			end if;
	
			--read shift register
			rshreg(8) <= rshreg(7);
			rshreg(7) <= rshreg(6);
			rshreg(6) <= rshreg(5);
			rshreg(5) <= rshreg(4);
			rshreg(4) <= rshreg(3);
			rshreg(3) <= rshreg(2);
			rshreg(2) <= rshreg(1);
			rshreg(1) <= rshreg(0);
			if mode = '1' then
				rshreg(0) <= bitstream_in;
			else
				rshreg(0) <= '0';
			end if;
			--sync detection
			sync <= '0';
			byte <= '0';
			if rshreg = "111111111" and bitstream_in = '1' and mode = '1' then
				sync <= '1';
				byte_cnt <= "000";
			elsif byte_cnt = "111" then
				byte <= '1';
			end if;
		end if;
	end process;
	
	byte_out <= rshreg(7 downto 0);
	
	sync_n <= not sync;
	
end rtl;
