library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity wb_test is
   port (
      clk      : in std_logic;
      reset    : in std_logic;
      -- Debug & Status
      button       : in  std_logic_vector(3 downto 0);
		switch       : in  std_logic_vector(7 downto 0);
      led          : out std_logic_vector(7 downto 0);
      -- Segments
      segments     : out std_logic_vector(7 downto 0);
      mux          : out std_logic_vector(3 downto 0);
      -- SRAM
      ram_ce_n : out std_logic_vector(1 downto 0);
      ram_be_n : out std_logic_vector(3 downto 0);
      ram_we_n : out std_logic;
      ram_oe_n : out std_logic;
      ram_addr : out std_logic_vector(18 downto 0);
      ram_io   : inout std_logic_vector(31 downto 0)
  );
end wb_test;

architecture rtl of wb_test is

-- Whishbone signals
signal wb_adr    : std_logic_vector(31 downto 0);
signal wb_dat_r  : std_logic_vector(7 downto 0);
signal wb_dat_w  : std_logic_vector(7 downto 0);
signal wb_sel    : std_logic_vector( 7 downto 0);
signal wb_we     : std_logic;
signal wb_stb    : std_logic;
signal wb_ack    : std_logic;
signal wb_cyc    : std_logic;

signal wb_vdisk_adr_o  : std_logic_vector(31 downto 0);
signal wb_vdisk_dat_o  : std_logic_vector(7 downto 0);
signal wb_vdisk_we_o     : std_logic;
signal wb_vdisk_stb_o    : std_logic;
signal wb_vdisk_ack_i    : std_logic;

signal wb_ctrl_adr_o  : std_logic_vector(31 downto 0);
signal wb_ctrl_dat_o  : std_logic_vector(7 downto 0);
signal wb_ctrl_we_o     : std_logic;
signal wb_ctrl_stb_o    : std_logic;
signal wb_ctrl_ack_i    : std_logic;

--serial
signal rxd : std_logic;

signal bitclk  : std_logic;
type master_sel_type is (controller, vdisk);
signal master_sel : master_sel_type;

begin

controller0: entity work.controller
   port map (
      clk        => clk,
      reset      => reset,
      irq        => '0',
      -- Wishbone
      wb_adr_o   => wb_ctrl_adr_o,
      wb_dat_o   => wb_ctrl_dat_o,
      wb_dat_i   => wb_dat_r,
      wb_we_o    => wb_ctrl_we_o,
      wb_stb_o   => wb_ctrl_stb_o,
      wb_ack_i   => wb_ctrl_ack_i, 
		
		par_i_a => (others => '0'),
		
		rxd => rxd,
		txd => rxd
		);
      
ramctrl0: entity work.wb_sram
   port map (
      clk        => clk,
      -- Wishbone
      wb_adr_i   => wb_adr,
      wb_dat_i   => wb_dat_w,
      wb_dat_o   => wb_dat_r,
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
		
vdisk0: entity work.vdisk
    Port map( 
		clk16 => clk,
		reset => reset,
		--from floppy
		disk_write => '0',
		track_number => (others => '0'),
		bitstream_in => '0',
--      bitstream_out =>,
	   bitclk => bitclk,
		stepper => "00",
		ds => "00",
	   --wishbone
		wb_stb_o => wb_vdisk_stb_o,
		wb_ack_i => wb_vdisk_ack_i,
		wb_we_o  => wb_vdisk_we_o,
		wb_adr_o => wb_vdisk_adr_o,
		wb_dat_o => wb_vdisk_dat_o,
		wb_dat_i => wb_dat_r
	  );		
		


	--arbiter
	master_sel <= vdisk when wb_vdisk_stb_o = '1' else
						controller;
	
	wb_cyc <= '1';
	
	wb_adr <= 	wb_vdisk_adr_o when master_sel = vdisk else
					wb_ctrl_adr_o;
	wb_dat_w <= wb_vdisk_dat_o when master_sel = vdisk else
					wb_ctrl_dat_o;
	wb_we <= 	wb_vdisk_we_o when master_sel = vdisk else
					wb_ctrl_we_o;
	wb_stb <= 	wb_vdisk_stb_o when master_sel = vdisk else
					wb_ctrl_stb_o;
	
	wb_vdisk_ack_i <= wb_ack when master_sel = vdisk else
							'0';
	wb_ctrl_ack_i <= wb_ack when master_sel = controller else
							'0';
							


segmux: entity work.SegmentMUX 
    Port map ( digit0 => wb_adr(15 downto 12),
					digit1 => wb_adr(11 downto 8),
					digit2 => wb_adr(7 downto 4),
					digit3 => wb_adr(3 downto 0),
					segments => segments,
					mux => mux,
					clk => clk );







led <= (others => '0');


clkproc: process is
begin
	bitclk <= '1', '0' after 500 ns;
	wait for 1000 ns;
end process;

end rtl;

