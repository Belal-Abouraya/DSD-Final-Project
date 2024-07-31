library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decompress_tb is
--  Port ( );
end decompress_tb;

architecture Behavioral of decompress_tb is

component decompress is
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
end component;

component RAM is
    generic( size: integer := 1024);
    port( clk, rst, write: in std_logic;
          address: in integer;
          in_data: in std_logic_vector(7 downto 0);
          out_data: out std_logic_vector(7 downto 0)
    );
end component;

constant l_size : integer := 3;
constant d_size : integer := 3;

signal clk, rst : STD_LOGIC;
signal en : STD_LOGIC;
signal l : STD_LOGIC_VECTOR(l_size - 1 downto 0);
signal d : STD_LOGIC_VECTOR(d_size - 1 downto 0);
signal first_mis : STD_LOGIC_VECTOR(7 downto 0);
signal write_data: STD_LOGIC_VECTOR(7 downto 0);
signal done : STD_LOGIC;
signal address: integer;
signal w : STD_LOGIC;
signal read_data : STD_LOGIC_VECTOR(7 downto 0);

begin

uut: decompress
generic map(l_size, d_size)
port map(clk, en, l, d, first_mis, read_data, done, address, w, write_data);

word: RAM
generic map(20)
port map(clk, rst, w, address, write_data, read_data);

clk_proc: process
begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
end process;

stim_proc: process
begin

en <= '0';rst <= '1'; wait for 10 ns;
rst <= '0';
en <= '1'; l <= "000"; d <= "000"; first_mis <= "00000011"; wait for 20 ns;
en <= '0';  wait for 10 ns;
en <= '1'; l <= "000"; d <= "000"; first_mis <= "00000001"; wait for 20 ns;
en <= '0';  wait for 10 ns;
en <= '1'; l <= "000"; d <= "000"; first_mis <= "00000010"; wait for 20 ns;
en <= '0';  wait for 10 ns;
en <= '1'; l <= "000"; d <= "000"; first_mis <= "00000101"; wait for 20 ns;
en <= '0';  wait for 10 ns;
en <= '1'; l <= "001"; d <= "011"; first_mis <= "00000011"; wait for 30 ns;
en <= '0';  wait for 10 ns;
en <= '1'; l <= "001"; d <= "010"; first_mis <= "00000100"; wait for 30 ns;
en <= '0';  wait for 10 ns;
en <= '1'; l <= "100"; d <= "111"; first_mis <= "00000101"; wait for 60 ns;
en <= '0';  wait for 10 ns;
en <= '1'; l <= "101"; d <= "011"; first_mis <= "00000100"; wait for 70 ns;
en <= '0';  wait for 10 ns;
wait;
end process;

end Behavioral;
