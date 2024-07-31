library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decompression_controller_tb is
--  Port ( );
end decompression_controller_tb;

architecture Behavioral of decompression_controller_tb is

component decompression_controller is
generic( d_size: integer:= 6;
         l_size: integer:= 2);
Port ( clk, rst : in STD_LOGIC;
       Rx_done: in STD_LOGIC;
       Rx_data: in STD_LOGIC_VECTOR(7 downto 0);
       read_data: in STD_LOGIC_VECTOR(7 downto 0);
       address : out integer;
       w : out STD_LOGIC;
       write_data : out STD_LOGIC_VECTOR(7 downto 0));
end component;

component RAM is
    generic( size: integer := 1024);
    port( clk, rst, write: in std_logic;
          address: in integer;
          in_data: in std_logic_vector(7 downto 0);
          out_data: out std_logic_vector(7 downto 0)
    );
end component;

signal clk, rst : STD_LOGIC;
signal Rx_done: STD_LOGIC;
signal Rx_data: STD_LOGIC_VECTOR(7 downto 0);
signal read_data: STD_LOGIC_VECTOR(7 downto 0);
signal address : integer;
signal w : STD_LOGIC;
signal write_data : STD_LOGIC_VECTOR(7 downto 0);

begin

clk_proc: process
begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
end process;


word: RAM
generic map(10)
port map(clk, rst, w, address, write_data, read_data);
uut: decompression_controller port map(clk, rst, Rx_done, Rx_data, read_data, address, w, write_data);

stim_proc: process
begin
    rst <= '1'; wait for 10 ns;
    rst <= '0';
    Rx_data <= "00000000"; Rx_done <= '1'; wait for 100 ns;
    Rx_done <= '0'; wait for 500 ns;
    Rx_data <= "00000001"; Rx_done <= '1'; wait for 100 ns;
    Rx_done <= '0'; wait for 500 ns;
    Rx_data <= "00000000"; Rx_done <= '1'; wait for 100 ns;
    Rx_done <= '0'; wait for 500 ns;
    Rx_data <= "00000010"; Rx_done <= '1'; wait for 100 ns;
    Rx_done <= '0'; wait for 500 ns;
    Rx_data <= "01000001"; Rx_done <= '1'; wait for 100 ns;
    Rx_done <= '0'; wait for 500 ns;
    Rx_data <= "00000101"; Rx_done <= '1'; wait for 100 ns;
    Rx_done <= '0'; wait for 500 ns;
    Rx_data <= "10000010"; Rx_done <= '1'; wait for 100 ns;
    Rx_done <= '0'; wait for 500 ns;
    Rx_data <= "00000011"; Rx_done <= '1'; wait for 100 ns;
    Rx_done <= '0'; wait for 500 ns;
    Rx_data <= "11000101"; Rx_done <= '1'; wait for 100 ns;
    Rx_done <= '0'; wait for 500 ns;
    Rx_data <= "00000100"; Rx_done <= '1'; wait for 100 ns;
    Rx_done <= '0'; wait for 500 ns;
    wait;
end process;

end Behavioral;
