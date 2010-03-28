
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller is
   port (
      clk       : in std_logic;
      reset     : in std_logic;
      irq       : in std_logic;
      --wishbone
      wb_stb_o  : out std_logic;
      wb_ack_i  : in  std_logic;
      wb_we_o   : out std_logic;
      wb_adr_o  : out std_logic_vector(23 downto 0);
      wb_dat_o  : out std_logic_vector( 7 downto 0);
      wb_dat_i  : in  std_logic_vector( 7 downto 0);
	
		--cpu bus (for debugging unit in floppy)
		c_addr : out  STD_LOGIC_VECTOR (7 downto 0);
		c_dat_r : in  STD_LOGIC_VECTOR (7 downto 0);
		c_dat_w : out  STD_LOGIC_VECTOR (7 downto 0);
		debug_cs_o : out  STD_LOGIC;
		c_we : out  STD_LOGIC;

	
		--io
		rxd	: in std_logic;
		txd	: out std_logic;

		par_o_a : out std_logic_vector(31 downto 0);
		par_i_a : in std_logic_vector(31 downto 0);
		par_i_b : in std_logic_vector(31 downto 0);
		
		disp_o_a : out std_logic_vector(5 downto 0);
		disp_io_b : inout std_logic_vector(7 downto 0);
		
		spi_cs : out std_logic;
		spi_mosi : out std_logic;
		spi_miso : in std_logic;
		spi_sck : out std_logic
	);      
end controller;

architecture Behavioral of controller is
signal cpu_adr  : std_logic_vector(23 downto 0);
signal cpu_rw_n : std_logic;
signal cpu_rdata   : std_logic_vector(7 downto 0);
signal cpu_wdata   : std_logic_vector(7 downto 0);
signal we : std_logic;

signal rdy      : std_logic;
signal res_n    : std_logic;
signal irq_n    : std_logic;

signal uart_wdata : std_logic_vector(7 downto 0);
signal uart_cs : std_logic;
signal rom_rdata   : std_logic_vector(7 downto 0);

signal pario_wdata : std_logic_vector(7 downto 0);
signal pario_cs : std_logic;

signal bs_cs : std_logic;
signal bank_reg : std_logic_vector(15 downto 0);

signal gcr_cs : std_logic;
signal gcr_wdata : std_logic_vector(7 downto 0);
signal gcr_gcr : std_logic_vector(39 downto 0);
signal gcr_bin : std_logic_vector(31 downto 0);

signal debug_cs : std_logic;

signal spi_wdata : std_logic_vector(7 downto 0);
signal spimod_cs : std_logic;

signal wb_req      : std_logic;
begin

res_n <= not reset;
irq_n <= not irq;

wb_we_o  <= not cpu_rw_n;

we <= not cpu_rw_n;

cpu: entity work.t65
   port map (
      Mode    => "00",
      Res_n   => res_n,
      Clk     => clk,
      --
      Rdy     => rdy,
      Abort_n => '1',
      IRQ_n   => irq_n,
      NMI_n   => '1',
      SO_n    => '1',
      R_W_n   => cpu_rw_n,
      A       => cpu_adr,
      DI      => cpu_rdata,
      DO      => cpu_wdata );

rom: entity work.CtrlRom
   port map (
      clk     => clk,
      --
      addr    => cpu_adr(13 downto 0),
      data    => rom_rdata ) ;

uart: entity work.uart
	Port map ( reset => reset,
					clk => clk,
					cs => uart_cs,
					we => we,
					addr => cpu_adr(2 downto 0),
					data_in => cpu_wdata,
					data_out => uart_wdata,
					rxd => rxd,
					txd => txd
			  );

pario: entity work.par_io
	Port map (	
					reset => reset,
					clk => clk,
					cs => pario_cs,
					we => we,
					addr => cpu_adr(4 downto 0),
					data_i => cpu_wdata,
					data_o => pario_wdata,
					par_o_a => par_o_a,
					par_i_a => par_i_a,
					par_i_b => par_i_b,

					disp_o_a => disp_o_a,
					disp_io_b => disp_io_b
			  );
			  
spi0: entity work.spi
    Port map ( reset => reset,
					clk => clk,
					cs => spimod_cs,
					we => we,
					adr => cpu_adr(3 downto 0),
					data_i => cpu_wdata,
					data_o => spi_wdata,
					spi_sck => spi_sck,
					spi_mosi => spi_mosi, 
					spi_miso => spi_miso,
					spi_cs => spi_cs
				);


uart_cs  <=	'1' when cpu_adr(15 downto 8) = x"B1" else
				'0';

pario_cs <=	'1' when cpu_adr(15 downto 8) = x"B2" else
				'0';
bs_cs 	<=	'1' when cpu_adr(15 downto 8) = x"BE" else
				'0';
gcr_cs 	<=	'1' when cpu_adr(15 downto 8) = x"B3" else
				'0';
debug_cs <=	'1' when cpu_adr(15 downto 8) = x"B4" else
				'0';
spimod_cs <='1' when cpu_adr(15 downto 8) = x"B5" else
				'0';


-- CPU reading
cpu_rdata <= rom_rdata   when cpu_adr(15 downto 14)="11" else
             uart_wdata  when uart_cs = '1' else
				 pario_wdata when pario_cs = '1' else
             gcr_wdata   when gcr_cs = '1' else
				 c_dat_r when debug_cs = '1' else
				 spi_wdata when spimod_cs = '1' else
				 wb_dat_i;
             
-- CPU writing
wb_dat_o <= cpu_wdata;

wb_stb_o <= wb_req;
rdy <= wb_ack_i when wb_req='1' else
       '1';

wb_req <= '1'  when ( ( cpu_adr(15 downto 14) /= "11" ) and (cpu_adr(15 downto 12) /= x"B") ) or (cpu_adr (15 downto 8) = x"BF") else 
          '0';

--connection of debugging unit
	c_addr <= cpu_adr(7 downto 0);
	c_dat_w <= cpu_wdata;
	c_we <= not cpu_rw_n;
	debug_cs_o <= debug_cs;

-- bank switching
-- BE01:BE00 selects adr(23 downto 8)
-- read/write from BF00-BFFF acesses block

process (clk, bs_cs, we)
begin
	if clk'event and clk = '0' then
		if bs_cs = '1' and we = '1' then
			if cpu_adr(0) = '0' then
				bank_reg(7 downto 0) <= cpu_wdata;
			else
				bank_reg(15 downto 8) <= cpu_wdata;
			end if;
		end if;
	end if;
end process;

wb_adr_o <= "00001110" & cpu_adr(15 downto 0) when cpu_adr(15 downto 8) /= x"BF" else
				bank_reg & cpu_adr (7 downto 0);


bin2gcr0: entity bin2gcr
    Port map( bin => gcr_bin,
				  gcr => gcr_gcr
				  );
				  
process (clk, gcr_cs, we)
begin
	if clk'event and clk = '0' then
		if gcr_cs = '1' and we = '1' then
			case cpu_adr(2 downto 0) is
				when "000" => gcr_bin(31 downto 24) <= cpu_wdata;
				when "001" => gcr_bin(23 downto 16) <= cpu_wdata;
				when "010" => gcr_bin(15 downto 8) <= cpu_wdata;
				when "011" => gcr_bin(7 downto 0) <= cpu_wdata;
				when others => null;
			end case;
		elsif gcr_cs = '1' and we = '0' then
			case cpu_adr(2 downto 0) is
				when "000" => gcr_wdata <= gcr_gcr(39 downto 32);
				when "001" => gcr_wdata <= gcr_gcr(31 downto 24);
				when "010" => gcr_wdata <= gcr_gcr(23 downto 16);
				when "011" => gcr_wdata <= gcr_gcr(15 downto 8);
				when "100" => gcr_wdata <= gcr_gcr(7 downto 0);
				when others => null;
			end case;
		end if;
	end if;
end process;

end Behavioral;


