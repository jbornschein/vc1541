library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity RAM_2k is
   port (
      clk  : in  std_logic;
      cs   : in  std_logic;
      rw_l : in  std_logic;
      addr : in  std_logic_vector(10 downto 0);
      do   : out std_logic_vector(7 downto 0);
      di   : in  std_logic_vector(7 downto 0)
   );
end RAM_2k;

architecture RTL of RAM_2k is
type drom_type is array(0 to 2047) of std_logic_vector(7 downto 0);
signal data : drom_type;

begin

proc: process(clk)
begin
   if clk'event and clk='0' then
      if cs='1' then 
         if rw_l='0' then
            data( to_integer(unsigned(addr))) <= di;
            do <= di;
         else
            do <= data( to_integer(unsigned(addr)));         
         end if;
      end if;
   end if;
end process;

end RTL;

