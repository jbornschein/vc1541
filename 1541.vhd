library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity vc1541 is
generic (
     drive_id : std_logic_vector(1 downto 0) := "00" 
);
port (
	clk16_in			: in std_logic;
	clk_wb_in		: in std_logic;
	res_n          : in std_logic;
   -- Status & Motor
	led            : out std_logic;
	motor          : out std_logic;
   -- Bus
   bus_clk_out    : out std_logic;
   bus_clk_in     : in  std_logic;
   bus_data_out   : out std_logic;
   bus_data_in    : in  std_logic;
   bus_atn_in     : in  std_logic;
	
	--debugging
	cpu_di_out : out std_logic_vector(7 downto 0);
	c_reset : in std_logic;
   c_addr : in  STD_LOGIC_VECTOR (7 downto 0);
   c_dat_r : out  STD_LOGIC_VECTOR (7 downto 0);
   c_dat_w : in  STD_LOGIC_VECTOR (7 downto 0);
   debug_cs : in  STD_LOGIC;
   c_we : in  STD_LOGIC;
   	
	--disk controll
	bitclk_out : out std_logic;
	bitstream_out : out std_logic;
	bitstream_in : in std_logic;
	stepper_out : out std_logic_vector (1 downto 0);
	ds_out : out std_logic_vector (1 downto 0);
	disk_write : out std_logic;
	
	wpe_in : in std_logic;--opto - 1=light
	
	--wishbone
	wb_stb_o  : out std_logic;
   wb_ack_i  : in  std_logic;
   wb_we_o   : out std_logic;
   wb_adr_o  : out std_logic_vector(23 downto 0);
   wb_dat_o  : out std_logic_vector( 7 downto 0);
   wb_dat_i  : in  std_logic_vector( 7 downto 0)
);
end vc1541;

architecture rtl of vc1541 is

signal clk_wb : std_logic;
signal clk_dbg : std_logic;

signal clk32_1 : std_logic;
signal clk16_1 : std_logic; --non gated
signal clk16 : std_logic; --gated by debug unit
signal clk8 : std_logic;
signal clk4 : std_logic;
signal clk2 : std_logic;
signal clk : std_logic;
signal clk_old : std_logic;

signal addr : std_logic_vector(23 downto 0);
signal cpu_di : std_logic_vector(7 downto 0);
signal cpu_do : std_logic_vector(7 downto 0);
signal rom_do : std_logic_vector(7 downto 0);

signal ram_do : std_logic_vector(7 downto 0);
signal ram_cs : std_logic;

signal rw_n : std_logic;

signal wb_dat_i_latch : std_logic_vector(7 downto 0);
signal wb_stb : std_logic;
signal wb_count : std_logic_vector(3 downto 0);

signal cpu_irq_n : std_logic;

signal via1_pa_in  : std_logic_vector(7 downto 0);
signal via1_pa_out : std_logic_vector(7 downto 0);
signal via1_pa_oe_l: std_logic_vector(7 downto 0);
signal via1_pb_in  : std_logic_vector(7 downto 0);
signal via1_pb_out : std_logic_vector(7 downto 0);
signal via1_pb_oe_l: std_logic_vector(7 downto 0);
signal via1_do     : std_logic_vector(7 downto 0);
signal via1_ca1_in : std_logic;
signal via1_irq_n : std_logic;
signal via1_cs : std_logic;



signal via2_pa_in : std_logic_vector(7 downto 0);
signal via2_pa_out : std_logic_vector(7 downto 0);
signal via2_pa_oe_l: std_logic_vector(7 downto 0);
signal via2_pb_in : std_logic_vector(7 downto 0);
signal via2_pb_out : std_logic_vector(7 downto 0);
signal via2_pb_oe_l: std_logic_vector(7 downto 0);
signal via2_cb2_in : std_logic;
signal via2_cb2_out : std_logic;
signal via2_cb2_oe_l : std_logic;
signal via2_do : std_logic_vector(7 downto 0);
signal via2_irq_n : std_logic;
signal via2_cs : std_logic;

signal atna       : std_logic;
signal data_out_n : std_logic;

signal mode : std_logic; --read or write
signal sync_n : std_logic; --sync mark is being read
signal byte_ready_n : std_logic; --byte complete
signal ds : std_logic_vector(1 downto 0);--density select
signal soe : std_logic; --set overflow enable: gates byte_n

--registers for debugging
signal d_AKK : std_logic_vector(7 downto 0);
signal d_X : std_logic_vector(7 downto 0);
signal d_Y : std_logic_vector(7 downto 0);
signal d_p : std_logic_vector(7 downto 0);

--counter for address logging
signal addr_count : std_logic_vector(14 downto 0);

--internal bus signals

signal bus_clk_out_i : std_logic;
signal bus_data_out_i : std_logic;

begin
	cpu: entity work.t65
	port map (Mode => "00",
				Res_n => res_n,
				Clk => clk,
				Rdy => '1',
				Abort_n => '1',
				IRQ_n => cpu_irq_n,
				NMI_n => '1',
				SO_n => byte_ready_n,
				R_W_n => rw_n,
				A => addr,
				DI => cpu_di,
				DO => cpu_do,
				--registers
				akk_o => d_akk,
				x_o => d_x,
				y_o => d_y,
				p_o => d_p
				);
				
	ram: entity work.ram_2k
	port map(clk => clk,
				cs => ram_cs,
				rw_l => rw_n,
				addr => addr(10 downto 0),
				do => ram_do,
				di => cpu_do );
				
	via1: entity work.m6522
	port map(RESET_L => res_n,
				P2_H => clk,
				CLK_4 => clk4,
				RS => addr(3 downto 0),
				DATA_IN => cpu_do,
				DATA_OUT => via1_do,
				RW_L => rw_n,
				CS1 => via1_cs,
				CS2_L => '0',
				IRQ_L => via1_irq_n,
			-- port a
				CA1_IN => via1_ca1_in,
				CA2_IN => '1',
--				CA2_OUT =>,
--				CA2_OUT_OE_L
				PA_IN => via1_pa_in,
				PA_OUT => via1_pa_out,
			   PA_OUT_OE_L => via1_pa_oe_l,
			-- port b
				CB1_IN => '1',
--				CB1_OUT =>
--          CB1_OUT_OE_L
				CB2_IN => '1',
--			   CB2_OUT =>,
--		      CB2_OUT_OE_L
				PB_IN => via1_pb_in,
				PB_OUT => via1_pb_out,
		   	PB_OUT_OE_L  => via1_pb_oe_l
			);

	via2: entity work.m6522
	port map(RESET_L => res_n,
				P2_H => clk,
				CLK_4 => clk4,
				RS => addr(3 downto 0),
				DATA_IN => cpu_do,
				DATA_OUT => via2_do,
				RW_L => rw_n,
				CS1 => via2_cs,
				CS2_L => '0',
				IRQ_L => via2_irq_n,
			-- port a
				CA1_IN => byte_ready_n,
				CA2_IN => '1',
				CA2_OUT => soe,
--				CA2_OUT_OE_L
				PA_IN => via2_pa_in,
				PA_OUT => via2_pa_out,
--			   PA_OUT_OE_L => via2_pa_oe_l,
			-- port b
				CB1_IN => '0',
--				CB1_OUT =>
--          CB1_OUT_OE_L
				CB2_IN => via2_cb2_in,
			   CB2_OUT => via2_cb2_out,
		      CB2_OUT_OE_L => via2_cb2_oe_l,
				PB_IN => via2_pb_in,
				PB_OUT => via2_pb_out,
			   PB_OUT_OE_L => via2_pb_oe_l
			);
	
	rwl: entity work.read_write_logic
    Port map ( res_n => res_n,
					clk16_in => clk16,
					ds => ds, --density select
					bitclk_out => bitclk_out, --to virtual disk
					bitstream_out => bitstream_out, --to virtual disk
					bitstream_in => bitstream_in, --from virtual disk
					byte_out => via2_pa_in,
					byte_in => via2_pa_out,
					mode => mode,
					sync_n => sync_n,
					byte_n_out => byte_ready_n,
					soe => soe
				);
				
	debug: entity work.debug
    Port map( 	--connections to controlling cpu
					c_clk => clk_dbg,
					c_reset => c_reset,
					c_addr => c_addr,
					c_dat_o => c_dat_r,
					c_dat_i => c_dat_w,
					c_cs => debug_cs,
					c_we => c_we,
					--connections to floppy
					d_addr => addr(15 downto 0),
					d_clk => clk,
					d_akk_i => d_akk,
					d_x_i => d_x,
					d_y_i => d_y,
					d_p_i => d_p,
					log_addr_count => addr_count,
					--stop clock on breakpoint
					gate_clk_i => clk16_1,
					gate_clk_o => clk16
					);
	
   --XXXX DEBUG --
	
	cpu_di_out <= cpu_di;

	--cpu bus
	via1_cs <= '1' when addr(15) = '0' and addr(12 downto 10) = "110" else
					'0';

	via2_cs <= '1' when addr(15) = '0' and addr(12 downto 10) = "111" else
					'0';
					
	ram_cs  <= '1' when addr(15) = '0' and addr(12 downto 11) = "00" else
					'0';

	cpu_di <= 	via1_do when via1_cs = '1' else
					via2_do when via2_cs = '1' else
					wb_dat_i_latch;
					
	process(clk_wb, clk)
	begin
		if clk_wb'event and clk_wb = '1' then
			clk_old <= clk;
			wb_stb <= '0';
			if clk_old = '0' and clk = '1' then
				wb_count <= "0000";
				addr_count <= addr_count + 1;
			end if;
			if wb_count /= "1111" then
				wb_count <= wb_count + 1;
			end if;
			if wb_count = "0010" then
				wb_stb <= '1';
				wb_adr_o <= "0000110" & addr_count & "00" ;
				wb_dat_o <= addr(7 downto 0);
				wb_we_o <= '1';
			end if;
			if wb_count = "0011" then
				wb_stb <= '1';
				wb_adr_o <= "0000110" & addr_count & "01" ;
				wb_dat_o <= addr(15 downto 8);
			end if;
			if wb_count = "0100" then
				wb_stb <= '1';
				wb_adr_o <= "0000110" & addr_count & "10";
				wb_dat_o <= "000" & bus_atn_in & bus_data_in & bus_clk_in & bus_data_out_i & bus_clk_out_i;
			end if;
			if wb_count = "0101" then
				wb_stb <= '1';
				wb_adr_o <= "00001111" & addr(15 downto 0);
				wb_dat_o <= cpu_do;
				wb_we_o <= not rw_n;
			end if;
			if wb_count = "0110" then
				wb_dat_i_latch <= wb_dat_i;
			end if;
		end if;
	end process;
	
	wb_stb_o <= wb_stb;
	
	--irq		
	cpu_irq_n <= via1_irq_n and via2_irq_n;
	
	-- Via Inputs
	via1_pa_in <= (others => '0');
	via1_pb_in(1) <= via1_pb_out(1);
	via1_pb_in(3) <= via1_pb_out(3);
	via1_pb_in(4) <= via1_pb_out(4);   
	via1_pb_in(6 downto 5) <= drive_id;
	
	
	via2_pb_in(0) <= via2_pb_out(0) when via2_pb_oe_l(0)='0' else '1'; --step1
	via2_pb_in(1) <= via2_pb_out(1) when via2_pb_oe_l(1)='0' else '1'; --step0
	via2_pb_in(2) <= via2_pb_out(2) when via2_pb_oe_l(2)='0' else '1'; --motor
	via2_pb_in(3) <= via2_pb_out(3) when via2_pb_oe_l(3)='0' else '1'; --led
	via2_pb_in(4) <= wpe_in;-- 1: write possible															 --wps
	via2_pb_in(5) <= via2_pb_out(5) when via2_pb_oe_l(5)='0' else '1'; --DS0
	via2_pb_in(6) <= via2_pb_out(6) when via2_pb_oe_l(6)='0' else '1'; --DS1
	via2_pb_in(7) <= sync_n;															 --sync
	
	ds_out<= ds;
	ds <= via2_pb_in(6 downto 5);
	stepper_out <= via2_pb_in(1 downto 0);
	via2_cb2_in <= via2_cb2_out 	when via2_cb2_oe_l = '0' 
											else 						'1';
	mode <= via2_cb2_in;
	disk_write <= not mode;
	
   -- BUS 
   via1_pb_in(0) <= not bus_data_in;
   via1_pb_in(2) <= not bus_clk_in;
   via1_pb_in(7) <= not bus_atn_in;
   via1_ca1_in   <= not bus_atn_in;   

   -- BUS OUT
   bus_clk_out_i <= not via1_pb_out(3) when via1_pb_oe_l(3)='0' else
                  '0';
   
   atna <= via1_pb_out(4) when via1_pb_oe_l(4)='0' else
           '1';
   
   data_out_n <= not via1_pb_out(1)  when via1_pb_oe_l(1)='0' else
                 '0';

   bus_data_out_i <= data_out_n and not (atna xor (not bus_atn_in));

	bus_clk_out <= bus_clk_out_i;
	bus_data_out <= bus_data_out_i;
	
   -- Status Assignment
	led   <= via2_pb_in(3);
	motor <= via2_pb_in(2);
	
	
	clk_wb <= clk_wb_in;
	clk_dbg <= clk_wb_in;
	
	clk16_1 <= clk16_in;
	
	--clk4 generator
	clkproc3: process(res_n, clk16, clk8) is
	begin
		if res_n = '0' then
			clk4 <= '0';
			clk8 <= '0';
		elsif clk16'event and clk16='0' then 
			clk8 <= not clk8;
			if clk8 ='0' then
				clk4 <= not clk4;
			end if;
		end if;
	end process;

   -- clk4 => CLK generator
	clkproc: process (res_n, clk4)
	begin
	   if res_n='0' then
			clk2 <= '0';
			clk <= '0';
		elsif clk4'event and clk4 = '0' then
			if clk2 = '0' then 
			   clk <= not clk;
				clk2 <= '1';
			else
			   clk2 <= '0';
			end if;
		end if;
	end process;
	
end rtl;
