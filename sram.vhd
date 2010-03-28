library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity sram is
   port (
       reset   : in    std_logic; 
       clk     : in    std_logic;
       --
       addr    : in    std_logic_vector(18 downto 0);
       io      : inout std_logic_vector(31 downto 0);
       be_n    : in    std_logic_vector(3 downto 0);
       ce_n    : in    std_logic;
       oe_n    : in    std_logic;
       we_n    : in    std_logic
   );
end sram;

architecture rtl of sram is
type data_type is array (0 to 16#3FFF#) of std_logic_vector(31 downto 0) ;
signal data : data_type := (
   16#1000# => "11110000110011001010101000100011", 
	others => (others => '0'));
signal i    : natural;
begin

io <= data(i) when oe_n='0' else
      (others => 'Z');

iproc: process(addr)
begin
  i <= to_integer(unsigned(addr(13 downto 0)));
end process;


memproc: process(reset, clk) is
variable datum : std_logic_vector(31 downto 0);
begin
   
   if reset'event then
      data( 16#3FFF# ) <= x"FFF0FFF0";
      data( 16#3FFE# ) <= x"00000000";
      data( 16#3FFD# ) <= x"00000000";
      data( 16#3FFC# ) <= x"00FFF04C";
   elsif we_n'event and we_n='0' then
      datum := data(i);
 
      if be_n(0)='0' then
         datum(7 downto 0) := io(7 downto 0);
      end if;
      if be_n(1)='0' then
         datum(15 downto 8) := io(15 downto 8);
      end if;
      if be_n(2)='0' then
         datum(23 downto 16) := io(23 downto 16);
      end if;
      if be_n(3)='0' then
         datum(31 downto 24) := io(31 downto 24);
      end if;

      data(i) <= datum;
   end if;
end process;

end rtl;
