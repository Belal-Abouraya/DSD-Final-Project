library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM is
    generic( size: integer := 1024);
    port( clk, rst, write: in std_logic;
          address: in integer;
          in_data: in std_logic_vector(7 downto 0);
          out_data: out std_logic_vector(7 downto 0)
    );
end RAM;

architecture Behavioral of RAM is

type memory_type is array (0 to size - 1) of std_logic_vector(7 downto 0);
signal memory: memory_type;
signal safe: integer:= 0;

begin

out_data <= memory(safe);

process(address)
begin
    if(address < 0 or address >= size) then
        safe <= 0;
    else
        safe <= address;
    end if;
end process;

process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            for i in 0 to size - 1 loop
                memory(i) <= (others => '0');
            end loop;
        else
            if(write = '1') then
                memory <= in_data & memory(0 to size - 2);
            end if;
        end if;
    end if;
end process;

end Behavioral;
