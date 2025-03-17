library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decompression_controller is
generic( d_size: integer:= 6;
         l_size: integer:= 2;
         width: integer:= 80);
Port ( clk, rst : in STD_LOGIC;
       Rx_done: in STD_LOGIC;
       Rx_data: in STD_LOGIC_VECTOR(7 downto 0);
       read_data: in STD_LOGIC_VECTOR(7 downto 0);
       address : out integer;
       w : out STD_LOGIC;
       write_data : out STD_LOGIC_VECTOR(7 downto 0);
       all_done : out STD_LOGIC:= '0');
end decompression_controller;

architecture Behavioral of decompression_controller is

component decompress is
    generic( d_size: integer:= 6;
             l_size: integer:= 2);
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           l : in STD_LOGIC_VECTOR(l_size - 1 downto 0);
           d : in STD_LOGIC_VECTOR(d_size - 1 downto 0);
           first_mis : in STD_LOGIC_VECTOR(7 downto 0);
           read_data: in STD_LOGIC_VECTOR(7 downto 0);
           done : out STD_LOGIC;
           address: out integer;
           w : out STD_LOGIC;
           write_data : out STD_LOGIC_VECTOR(7 downto 0));
end component;

constant word_size : integer := 3 * width * width / 2;

signal got_l_d, got_mis, got_data, decomp_en, decomp_done: std_logic := '0';
signal l_d, first_mis : std_logic_vector(7 downto 0) := (others => '0');
signal tmp_w: std_logic;
signal bytes_done: integer := 0;

begin

decomp_unit: decompress
generic map(d_size => d_size,
            l_size => l_size)
port map(clk => clk,
         en => decomp_en,
         l => l_d(7 downto 7 - l_size + 1),
         d => l_d(d_size - 1 downto 0),
         first_mis => first_mis,
         read_data => read_data,
         done => decomp_done,
         address => address,
         w => tmp_w,
         write_data => write_data);

w <= tmp_w;
all_done <= '1' when bytes_done = word_size else '0';

process(clk)
begin
    if(rst = '1') then
        got_l_d <= '0';
        got_data <= '0';
        got_mis <= '0';
        decomp_en <= '0';
        l_d <= (others => '0');
        first_mis <= (others => '0');
        bytes_done <= 0;
    elsif(rising_edge(clk)) then
        if(Rx_done = '1' and got_data = '0') then -- got a new byte
            got_data <= '1';
            if(got_l_d = '0') then
                got_l_d <= '1';
                l_d <= Rx_data;
            else
                got_mis <= '1';
                first_mis <= Rx_data;
            end if;
        end if;
        if(got_data = '1' and Rx_done = '0') then --save the byte
            got_data <= '0';
        end if;
        
        
        if(got_l_d = '1' and got_mis = '1') then -- got the l, d and mismatch
            decomp_en <= '1';
            got_l_d <= '0';
            got_mis <= '0';
        end if;
        if(decomp_done = '1' and decomp_en = '1') then -- decompressed the data
            decomp_en <= '0';
        end if;
        
        --count done bytes
        if(tmp_w = '1') then
            bytes_done <= bytes_done + 1;
        end if;
        
    end if;
end process;

end Behavioral;
