library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity wb_testbench is
end wb_testbench;

architecture Behavioral of wb_testbench is

signal clk   : std_logic;
signal clk_n : std_logic;
signal reset : std_logic;

-- RAM Signals
signal ram_be_n  : std_logic_vector(3 downto 0);
signal ram_ce_n  : std_logic_vector(1 downto 0);
signal ram_oe_n  : std_logic;
signal ram_we_n  : std_logic;
signal ram_addr  : std_logic_vector(18 downto 0);
signal ram_io    : std_logic_vector(31 downto 0);

begin

board: entity work.wb_test
   port map (
      clk        => clk,
      reset      => reset,
      --         
      button     => "0000",
      switch     => "00000000",
      led        => open,
      -- Segment 
      segments   => open,
      mux        => open,
      --
      ram_ce_n   => ram_ce_n,
      ram_be_n   => ram_be_n,
      ram_we_n   => ram_we_n,
      ram_oe_n   => ram_oe_n,
      ram_addr   => ram_addr,
      ram_io     => ram_io  );
      

sram: entity work.sram
   port map (
      clk        => clk_n,
      reset      => reset,
      --
      ce_n       => ram_ce_n(0),
      be_n       => ram_be_n,
      we_n       => ram_we_n,
      oe_n       => ram_oe_n,
      addr       => ram_addr,
      io         => ram_io  );
      
-- CLK Gen
clkproc: process is
begin
   clk <= '1', '0' after 250ns;
   wait for 500ns;
end process;

clk_n <= not clk;

reset <= '1', '0' after 65ns;

end Behavioral;

