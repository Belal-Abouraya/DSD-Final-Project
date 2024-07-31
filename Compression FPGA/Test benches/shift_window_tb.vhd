library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_window_tb is
--  Port ( );
end shift_window_tb;

architecture Behavioral of shift_window_tb is

component shift_window is
    generic(l_size: integer);
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
end component;

component RAM is
    generic( size: integer := 1024);
    port( clk, rst, write: in std_logic;
          address: in integer;
          in_data: in std_logic_vector(7 downto 0);
          out_data: out std_logic_vector(7 downto 0)
    );
end component;

constant l_size : integer := 4;

signal clk : STD_LOGIC;
signal en : STD_LOGIC;
signal rst : STD_LOGIC;
signal l : STD_LOGIC_VECTOR(l_size - 1 downto 0);
signal start_address : integer;
signal in_data: STD_LOGIC_VECTOR(7 downto 0);
signal curr_address : integer;
signal w, w2 : STD_LOGIC;
signal out_data, tmp1, tmp2: STD_LOGIC_VECTOR(7 downto 0);
signal done : STD_LOGIC;

begin

clk_proc: process
begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
end process;


uut: shift_window 
generic map(l_size)
port map(clk, en, rst, l, start_address, in_data, curr_address, w, out_data, done);

comp_mem: RAM
generic map(10)
port map(clk, rst, w, 0, out_data, tmp1);

rec_mem: RAM
generic map(10)
port map(clk, rst, w2, curr_address, tmp2, in_data);


stim_proc: process
begin
l <= "0101"; start_address <= 5;
rst <= '1'; wait for 10 ns;
rst <= '0';
w2 <= '1';
tmp2 <= "00001010"; wait for 10 ns;
tmp2 <= "00001011"; wait for 10 ns;
tmp2 <= "00001001"; wait for 10 ns;
tmp2 <= "00000111"; wait for 10 ns;
tmp2 <= "00000001"; wait for 10 ns;
tmp2 <= "00000010"; wait for 10 ns;

w2 <= '0';

en <= '1'; wait;

end process;

end Behavioral;
