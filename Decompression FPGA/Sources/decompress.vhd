library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decompress is
    generic( d_size: integer:= 6;
             l_size: integer:= 2);
    Port ( clk: in STD_LOGIC;
           en: in STD_LOGIC;
           l: in STD_LOGIC_VECTOR(l_size - 1 downto 0);
           d: in STD_LOGIC_VECTOR(d_size - 1 downto 0);
           first_mis: in STD_LOGIC_VECTOR(7 downto 0);
           read_data: in STD_LOGIC_VECTOR(7 downto 0);
           done: out STD_LOGIC;
           address: out integer;
           w: out STD_LOGIC;
           write_data: out STD_LOGIC_VECTOR(7 downto 0));
end decompress;

architecture Behavioral of decompress is

signal load: std_logic :=  '1';
signal w_tmp, done_tmp : std_logic := '0';
signal counter, curr_address: integer;
signal curr_write_data: STD_LOGIC_VECTOR(7 downto 0);

begin

address <= curr_address;
curr_write_data <= first_mis when counter = 0 else read_data;
write_data <= curr_write_data;
w <= w_tmp;
done <= done_tmp;

process(clk)
begin
    if(rising_edge(clk)) then
        if(en = '1') then
            if(load = '1') then
                load <= '0';
                curr_address <= to_integer(unsigned(d)) - 1;                
                counter <= to_integer(unsigned(l));
                w_tmp <= '1';
            elsif(counter = 0) then
                done_tmp <= '1';
                w_tmp <= '0';
            else
                counter <= counter - 1;
            end if;
        else
            w_tmp <= '0';
            done_tmp <= '0';
            load <= '1';
        end if;
    end if;
end process;

end Behavioral;
