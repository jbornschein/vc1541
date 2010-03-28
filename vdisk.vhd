----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:45:23 10/09/2006 
-- Design Name: 
-- Module Name:    vdisk - Behavioral 
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

entity vdisk is
    Port ( clk : in std_logic;
				reset : in std_logic;
				--from floppy
				disk_write : in std_logic;
				bitstream_in : in  STD_LOGIC;
           bitstream_out : out  STD_LOGIC;
           bitclk : in  STD_LOGIC;
			  stepper : in std_logic_vector(1 downto 0);
			  track_number_out : out std_logic_vector(5 downto 0);
			  ds : in std_logic_vector(1 downto 0);
			  --wishbone
				wb_stb_o  : out std_logic;
				wb_ack_i  : in  std_logic;
				wb_we_o   : out std_logic;
				wb_adr_o  : out std_logic_vector(23 downto 0);
				wb_dat_o  : out std_logic_vector( 7 downto 0);
				wb_dat_i  : in  std_logic_vector( 7 downto 0)
			  );
end vdisk;

architecture rtl of vdisk is

	--for reading from vdisk
	signal r_buf : std_logic_vector(7 downto 0);
	signal r_buf_empty : std_logic;
	signal r_buf_empty_done : std_logic ;
	signal r_reg : std_logic_vector(7 downto 0);

	--for writing to vdisk
	signal w_buf : std_logic_vector(7 downto 0);
	signal w_buf_full : std_logic;
	signal w_buf_full_done : std_logic ;
	signal w_reg : std_logic_vector(7 downto 0);

	signal reg_valid : std_logic;

	signal addr_out : std_logic_vector(13 downto 0);
	signal byte_addr : std_logic_vector(13 downto 0);
	signal byte_w_addr : std_logic_vector(13 downto 0);

	signal bit_count : std_logic_vector(2 downto 0);
	
	signal bitstream_o : std_logic;

	signal track_number : std_logic_vector(5 downto 0);
	signal track_bytes : std_logic_vector(13 downto 0);
	signal trackchange : std_logic;
	signal step_o : std_logic_vector(1 downto 0);
	signal ds_o : std_logic_vector(1 downto 0);

	signal wb_stb : std_logic;

begin
	track_number_out <= track_number;

	track_bytes <= "01" & x"86A" when ds = "00" else
						"01" & x"A0A" when ds = "01" else
						"01" & x"BE6" when ds = "10" else
						"01" & x"E0C";

	wb_stb_o <= wb_stb;
	wb_adr_o <= "0000" & (track_number & addr_out);

	--only give data on full tracks
	bitstream_out <= bitstream_o when stepper(0) = '0' else
							'0';

	process(reset, bitclk)
	begin
		if reset = '1' then
			trackchange <= '1';
			step_o <= "00";
			track_number <= "010001";
		elsif bitclk'event and bitclk='1' then
			trackchange <= '0';
			step_o <= stepper;
			if (step_o = "01" and stepper = "00") or (step_o = "11" and stepper = "10") then
				if track_number /= "000000" then
					track_number <= track_number - 1;
					trackchange <= '1';
				end if;
			end if;
			if (step_o = "11" and stepper = "00") or (step_o = "01" and stepper = "10") then
				track_number <= track_number + 1;
				trackchange <= '1';
			end if;
			ds_o <= ds;
			if ds_o /= ds then
				trackchange <= '1';
			end if;
		end if;
	end process;
	


	--handle data exchange with wb bus
	process (clk, reset)
	begin
		if reset = '1' then
			r_buf_empty_done <= '0';
			w_buf_full_done <= '0';
			wb_stb <= '0';
		elsif clk'event and clk = '1' then
			if r_buf_empty = '1' and r_buf_empty_done = '0' then
				wb_stb <= '1';
				wb_we_o <= '0';
				if wb_ack_i = '1' then
					wb_stb <= '0';
					r_buf_empty_done <= '1';
					r_buf <= wb_dat_i;
				end if;
			elsif w_buf_full = '1' and w_buf_full_done = '0' then
				wb_stb <= '1';
				wb_we_o <= '1';
				wb_dat_o <= w_buf;
				if wb_ack_i = '1' then
					wb_stb <= '0';
					w_buf_full_done <= '1';
				end if;
			end if;
			
			if w_buf_full = '0' then
				w_buf_full_done <= '0';
			end if;
			if r_buf_empty = '0' then
				r_buf_empty_done <= '0';
			end if;
		end if;
	end process;

	--receive an txmit bitstreams
	process (bitclk, reset)
	begin
		if reset = '1' or trackchange = '1' then
			reg_valid <= '0';
			byte_addr <= (others => '0');
			bit_count <= (others => '0');
		elsif bitclk'event and bitclk = '0' then
			bit_count <= bit_count + 1;

			w_reg(7) <= w_reg(6);
			w_reg(6) <= w_reg(5);
			w_reg(5) <= w_reg(4);
			w_reg(4) <= w_reg(3);
			w_reg(3) <= w_reg(2);
			w_reg(2) <= w_reg(1);
			w_reg(1) <= w_reg(0);
			
			if disk_write = '1' then
				reg_valid <= '1';
				w_reg(0) <= bitstream_in;
			else
				w_reg(0) <=	r_reg(7);
			end if;

			bitstream_o <= r_reg(7);
			r_reg(7) <= r_reg(6);
			r_reg(6) <= r_reg(5);
			r_reg(5) <= r_reg(4);
			r_reg(4) <= r_reg(3);
			r_reg(3) <= r_reg(2);
			r_reg(2) <= r_reg(1);
			r_reg(1) <= r_reg(0);
				
			
			if  bit_count = "000" then
				w_buf <= w_reg;
				reg_valid <= '0';
				if reg_valid = '1' then
					w_buf_full <= '1';
				end if;
				addr_out <= byte_w_addr;
				byte_w_addr <= byte_addr;
				byte_addr <= byte_addr + 1;
				if byte_addr = track_bytes then
					byte_addr <= (others => '0');
				end if;
			elsif bit_count = "100" then
				w_buf_full <= '0';
				r_buf_empty <= '1';
				addr_out <= byte_addr;			
			elsif bit_count = "111" then
				r_reg <= r_buf;
				r_buf_empty <= '0';
			end if;
		end if;
	end process;
end rtl;

