library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity find_match is
    generic( la_size: integer:= 4;
             db_size: integer:= 64;
             d_size: integer:= 6;
             l_size: integer:= 2);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           l_mx : in integer;
           curr_data: in std_logic_vector(7 downto 0);
           address: out integer;
           l: out std_logic_vector(l_size - 1 downto 0);
           d: out std_logic_vector(d_size - 1 downto 0);           
           first_mis: out std_logic_vector(7 downto 0);
           found : out STD_LOGIC);
end find_match;

architecture Behavioral of find_match is

type memory_type is array (0 to la_size - 1) of std_logic_vector(7 downto 0);
signal curr_string: memory_type;
signal curr_address, offset, start_address, cl, cd: integer;
signal load, curr_match: std_logic;

begin

d <= std_logic_vector(to_unsigned(cd, d'length));
l <= std_logic_vector(to_unsigned(cl, l'length));
address <= curr_address;

process(clk, en, rst)
begin
    if(rst = '1') then
        curr_address <= 0;
        cl <= l_mx;
        cd <= 0;
        load <= '1';
        found <= '0';
        first_mis <= (others => '0');
        offset <= 0;
        curr_match <= '1';
    elsif(en = '1') then
        if(rising_edge(clk)) then
            --load the LA buffer
            if(load = '1') then
                curr_string(curr_address) <= curr_data;
                if(curr_address + 1 = la_size) then
                    cl <= l_mx;
                    curr_address <= la_size - l_mx + 1;
                    start_address <= la_size - l_mx + 1;
                    load <= '0';
                    offset <= 0;
                    curr_match <= '1';
                else
                    curr_address <= curr_address + 1;
                end if;
            else
                --loop over all lengths
                if(cl = 0) then
                    cd <= 0;
                    found <= '1';
                    first_mis <= curr_string(la_size - 1);
                elsif(start_address = la_size + db_size - cl + 1) then
                    cl <= cl - 1;
                    start_address <= la_size - cl + 2;
                    curr_address <= la_size - cl + 2;
                    curr_match <= '1';
                    offset <= 0;
                --loop over memory
                elsif(offset = cl) then
                    if(curr_match = '1') then
                        found <= '1';
                        cd <= start_address + cl - la_size;
                        first_mis <= curr_string(la_size - cl - 1);
                    else
                        found <= '0';
                    end if;
                    start_address <= start_address + 1;
                    curr_address <= start_address + 1;
                    offset <= 0;
                    curr_match <= '1';
                --loop over the current string
                elsif(offset < cl) then
                    if(curr_string(la_size - cl + offset) /= curr_data) then
                        curr_match <= '0';
                    end if;
                    offset <= offset + 1;
                    curr_address <= curr_address + 1;
                end if;
            end if;
        end if;
    end if;
end process;

end Behavioral;
