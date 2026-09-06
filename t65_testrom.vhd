----------------------------------------------------------------------------------
-- Minimal test ROM for t65_testbench.vhd
--
-- Fills the whole address space with NOP ($EA) and points the 6502 reset
-- vector ($FFFC/$FFFD, aliased here to $FC/$FD since only the low 8 address
-- bits are wired to this ROM in the testbench) back at address $00, so the
-- CPU core resets and then just free-runs through NOPs.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity t65_testrom is
    port (
        addr : in  std_logic_vector(7 downto 0);
        data : out std_logic_vector(7 downto 0);
        clk  : in  std_logic
    );
end t65_testrom;

architecture Behavioral of t65_testrom is
    type rom_t is array (0 to 255) of std_logic_vector(7 downto 0);

    function init_rom return rom_t is
        variable rom : rom_t := (others => x"EA"); -- NOP
    begin
        rom(16#FC#) := x"00"; -- reset vector low byte  -> $0000
        rom(16#FD#) := x"00"; -- reset vector high byte
        return rom;
    end function;

    constant rom : rom_t := init_rom;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            data <= rom(conv_integer(addr));
        end if;
    end process;
end Behavioral;
