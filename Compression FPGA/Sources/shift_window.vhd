library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shift_window is
    generic(l_size: integer:= 2);
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           l : in STD_LOGIC_VECTOR(l_size - 1 downto 0);
           start_address : in integer;
           in_data: in STD_LOGIC_VECTOR(7 downto 0);
           curr_address : out integer;
           w : out STD_LOGIC;
           out_data: out STD_LOGIC_VECTOR(7 downto 0);
           done : out STD_LOGIC);
end shift_window;

architecture Behavioral of shift_window is

signal counter, ca: integer;

begin

curr_address <= ca;
out_data <= in_data;

process(clk, en, rst)
begin
    if(rst = '1') then
        counter <= to_integer(unsigned(l)) + 1;
        done <= '0';
        w <= '0';
        ca <= start_address + 1;
    elsif(en = '1') then
        if(rising_edge(clk)) then
            if(counter = 0) then
                done <= '1';
                w <= '0';
            else
                w <= '1';
                counter <= counter - 1;
                ca <= ca - 1;
            end if;
        end if;
    end if;
end process;

end Behavioral;
