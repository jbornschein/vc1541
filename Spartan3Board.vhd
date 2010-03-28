library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Spartan3Board is
   port (
      clk_in       : in  std_logic;
      button       : in  std_logic_vector(3 downto 0);
		switch       : in  std_logic_vector(7 downto 0);
      led          : out std_logic_vector(7 downto 0);
      --Segments
      segments     : out std_logic_vector(7 downto 0);
      mux          : out std_logic_vector(3 downto 0);
      -- Bus
      bus_clk_in   : in  std_logic;      
      bus_clk_out  : out std_logic;      
      bus_data_in  : in  std_logic;
      bus_data_out : out std_logic;
      bus_atn_in   : in  std_logic;
		-- SRAM
      ram_ce_n : out std_logic_vector(1 downto 0);
      ram_be_n : out std_logic_vector(3 downto 0);
      ram_we_n : out std_logic;
      ram_oe_n : out std_logic;
      ram_addr : out std_logic_vector(17 downto 0);
      ram_io   : inout std_logic_vector(31 downto 0);
		--UART
		rxd : in std_logic;
		txd : out std_logic;
		--SPI
		spi_cs : out std_logic;
		spi_mosi : out std_logic;
		spi_miso : in std_logic;
		spi_sck : out std_logic;
		--LCD
		disp_o_a : out std_logic_vector(5 downto 0);
		disp_io_b : inout std_logic_vector(7 downto 0)

		);
end Spartan3Board;


architecture rtl of Spartan3Board is

signal clk32   : std_logic;
signal clk16   : std_logic;
signal res_n  : std_logic;
signal reset_floppy : std_logic;
signal reset_controller  : std_logic;
signal reset_master  : std_logic;
signal locked : std_logic;
signal bus_data_out_int : std_logic;
signal bus_clk_out_int : std_logic;

signal ram_do : std_logic_vector(7 downto 0);
signal rom_do : std_logic_vector(7 downto 0);


-- Whishbone signals
signal wb_adr    : std_logic_vector(23 downto 0);
signal wb_dat_r  : std_logic_vector(7 downto 0);
signal wb_dat_w  : std_logic_vector(7 downto 0);
signal wb_sel    : std_logic_vector( 7 downto 0);
signal wb_we     : std_logic;
signal wb_stb    : std_logic;
signal wb_ack    : std_logic;
signal wb_cyc    : std_logic;

signal wb_vdisk_adr_o  : std_logic_vector(23 downto 0);
signal wb_vdisk_dat_o  : std_logic_vector(7 downto 0);
signal wb_vdisk_we_o     : std_logic;
signal wb_vdisk_stb_o    : std_logic;
signal wb_vdisk_ack_i    : std_logic;

signal wb_ctrl_adr_o  : std_logic_vector(23 downto 0);
signal wb_ctrl_dat_o  : std_logic_vector(7 downto 0);
signal wb_ctrl_we_o     : std_logic;
signal wb_ctrl_stb_o    : std_logic;
signal wb_ctrl_ack_i    : std_logic;

signal wb_flp_adr_o  : std_logic_vector(23 downto 0);
signal wb_flp_dat_o  : std_logic_vector(7 downto 0);
signal wb_flp_we_o     : std_logic;
signal wb_flp_stb_o    : std_logic;
signal wb_flp_ack_i    : std_logic;

--arbiter
type master_sel_type is (controller, vdisk, floppy);
signal master_sel : master_sel_type;

--vdisk signals
signal bitclk : std_logic;
signal bitstream_w : std_logic;
signal bitstream_r : std_logic;
signal disk_write : std_logic;
signal disk_ds : std_logic_vector(1 downto 0);
signal stepper : std_logic_vector(1 downto 0);
signal track_number : std_logic_vector(5 downto 0);

signal wpe : std_logic; --opto - 1=light

--parallel controller ports
signal par_o_a : std_logic_vector(31 downto 0);
signal par_i_a : std_logic_vector(31 downto 0);
signal par_i_b : std_logic_vector(31 downto 0);

--debugging
signal led_1 : std_logic_vector(7 downto 0);
signal led_2 : std_logic_vector(7 downto 0);

signal atna : std_logic;
signal hex_out : std_logic_vector(15 downto 0);

signal c_addr : std_logic_vector(7 downto 0);
signal c_dat_r : std_logic_vector(7 downto 0);
signal c_dat_w : std_logic_vector(7 downto 0);
signal debug_cs : std_logic;
signal c_we : std_logic;

--user interface
signal button_u : std_logic_vector(3 downto 0);		
signal button_c : std_logic_vector(3 downto 0);

begin

	res_n <= not (button_c(3) or reset_floppy or not locked);
	reset_controller <= button_c(2) or not locked;
	reset_master <= not locked;

	button_u <= button when switch(5) = '1' else
					(others => '0');
					
	button_c <= button when switch(5) = '0' else
					(others => '0');
					
  clkgen: entity work.ClkGen
	  port map (
			clk50    => clk_in,
			clk16_out=> clk16,
			clk32_out=> clk32,
			switch   => switch (2 downto 0),
			pause    => button_c(0),
			reset		=> button_c(1),
			locked 	=> locked
			);
      
	segmux: entity work.SegmentMUX 
		Port map ( digit0 => hex_out(15 downto 12),
					digit1 => hex_out(11 downto 8),
					digit2 => hex_out(7 downto 4),
					digit3 => hex_out(3 downto 0),
					segments => segments,
					mux => mux,
					clk => clk_in );

	floppy0: entity work.vc1541
		port map(
			clk_wb_in		=> clk16,
			clk16_in			=> clk16,
			res_n      => res_n,
			-- Wishbone
			wb_adr_o   => wb_flp_adr_o,
			wb_dat_o   => wb_flp_dat_o,
			wb_dat_i   => wb_dat_r,
			wb_we_o    => wb_flp_we_o,
			wb_stb_o   => wb_flp_stb_o,
			wb_ack_i   => wb_flp_ack_i,
						--
			led        => led_1(7),
			motor      => led_1(6),
			--iec bus
			bus_clk_in  => bus_clk_in,
			bus_clk_out => bus_clk_out_int,
			bus_data_in => bus_data_in,
			bus_data_out=> bus_data_out_int,
			bus_atn_in  => bus_atn_in,
		
			--debugging
		
			c_reset => reset_controller, 
			c_addr => c_addr,
			c_dat_r => c_dat_r,
			c_dat_w => c_dat_w,
			debug_cs => debug_cs,
			c_we => c_we,
		
			--vdisk
			bitclk_out => bitclk,
			bitstream_out => bitstream_w,
			bitstream_in => bitstream_r,
			disk_write => disk_write,
			stepper_out => stepper,
			ds_out => disk_ds,
			
			wpe_in => wpe

		);
					
					
controller0: entity work.controller
   port map (
      clk        => clk16,
      reset      => reset_controller,
      irq        => '0',
      -- Wishbone
      wb_adr_o   => wb_ctrl_adr_o,
      wb_dat_o   => wb_ctrl_dat_o,
      wb_dat_i   => wb_dat_r,
      wb_we_o    => wb_ctrl_we_o,
      wb_stb_o   => wb_ctrl_stb_o,
      wb_ack_i   => wb_ctrl_ack_i, 
		
		--cpu bus (for debugging unit in floppy)
		c_addr => c_addr,
		c_dat_r => c_dat_r,
		c_dat_w => c_dat_w,
		debug_cs_o => debug_cs,
		c_we => c_we,
		
		--io
		rxd => rxd,
		txd => txd,
		par_o_a => par_o_a,
		par_i_a => par_i_a,
		par_i_b => par_i_b,
		
		disp_o_a => disp_o_a,
		disp_io_b => disp_io_b,
		
		spi_cs => spi_cs,
		spi_mosi => spi_mosi,
		spi_miso => spi_miso,
		spi_sck => spi_sck
		
		);
		
vdisk0: entity work.vdisk
   Port map( 
		clk => clk16,
		reset => reset_controller,
		--from floppy
		disk_write => disk_write,
		bitstream_in => bitstream_w,
		bitstream_out => bitstream_r,
	   bitclk => bitclk,
		stepper => stepper,
		track_number_out => track_number,
		ds => disk_ds,
	   --wishbone
		wb_stb_o => wb_vdisk_stb_o,
		wb_ack_i => wb_vdisk_ack_i,
		wb_we_o  => wb_vdisk_we_o,
		wb_adr_o => wb_vdisk_adr_o,
		wb_dat_o => wb_vdisk_dat_o,
		wb_dat_i => wb_dat_r
);		

      
	ramctrl0: entity work.wb_sram
   port map (
		reset      => reset_master,
      clk        => clk16,
		-- Wishbone
      wb_adr_i   => wb_adr,
      wb_dat_i   => wb_dat_w,
      wb_dat_o   => ram_do,
      wb_we_i    => wb_we,
      wb_cyc_i   => wb_cyc,
      wb_stb_i   => wb_stb,
      wb_ack_o   => wb_ack,
      -- RAM
      ram_ce_n   => ram_ce_n,
      ram_be_n   => ram_be_n,
      ram_we_n   => ram_we_n,
      ram_oe_n   => ram_oe_n,
      ram_addr   => ram_addr,
      ram_io     => ram_io
      );

--	rom: entity work.rom
--	port map(addr => wb_adr(13 downto 0),
--				data => rom_do,
--				clk => clk16);

--rom selection

--	wb_dat_r <= rom_do when wb_adr(19 downto 15) = "11111" else
--					ram_do;

wb_dat_r <= ram_do;

--arbiter
	master_sel <=  floppy when wb_flp_stb_o = '1' else
						vdisk when wb_vdisk_stb_o = '1' else
						controller;

	wb_cyc <= '1';
	
	wb_adr <= 	wb_vdisk_adr_o when master_sel = vdisk else
					wb_flp_adr_o   when master_sel = floppy else
					wb_ctrl_adr_o;
	wb_dat_w <= wb_vdisk_dat_o when master_sel = vdisk else
					wb_flp_dat_o   when master_sel = floppy else
					wb_ctrl_dat_o;
	wb_we <= 	wb_vdisk_we_o when master_sel = vdisk else
					wb_flp_we_o   when master_sel = floppy else
					wb_ctrl_we_o;
	wb_stb <= 	wb_vdisk_stb_o when master_sel = vdisk else
					wb_flp_stb_o   when master_sel = floppy else
					wb_ctrl_stb_o;
	
	wb_vdisk_ack_i <= wb_ack when master_sel = vdisk else
							'0';
	wb_ctrl_ack_i <= wb_ack when master_sel = controller else
							'0';
	wb_flp_ack_i <= wb_ack when master_sel = floppy else
							'0';

	--serial bus
	bus_data_out <= bus_data_out_int;
	bus_clk_out  <= bus_clk_out_int;

	with switch(3) select
		led <=	led_2 when '1',
					led_1 when others;
	
	with switch(4) select
		hex_out <= wb_flp_adr_o(15 downto 0) when '0',
					  wb_ctrl_adr_o(15 downto 0) when others;

led_1(5) <= not bus_atn_in;
		
led_1(4) <= not bus_data_out_int;      
led_1(3) <= not bus_clk_out_int;      

led_1(2) <= not bus_data_in;      
led_1(1) <= not bus_clk_in;

led_1(0) <= clk16;

led_2 <= par_o_a(7 downto 0);

reset_floppy <= not par_o_a(8);
wpe <= par_o_a(16);

par_i_a(7 downto 0) <= "000000" & stepper;
par_i_a(15 downto 8) <= disk_ds & track_number;
par_i_a(23 downto 16) <= "0000" & button_u;
par_i_a(31 downto 24) <= switch;

par_i_b <= "00000000" & wb_vdisk_adr_o;

end rtl;

