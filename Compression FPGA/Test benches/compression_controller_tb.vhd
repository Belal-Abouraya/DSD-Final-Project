library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity compression_controller_tb is
--  Port ( );
end compression_controller_tb;

architecture Behavioral of compression_controller_tb is

component compression_controller is
    generic( la_size: integer:= 4;
             db_size: integer:= 64;
             d_size: integer:= 6;
             l_size: integer:= 2;
             rec_size: integer := 10);
    Port (clk, rst : in STD_LOGIC;
          Rx_done: in STD_LOGIC;
          Rx_all_done: in STD_LOGIC;
          Rx_data: in STD_LOGIC_VECTOR(7 downto 0);
          l: out STD_LOGIC_VECTOR(l_size - 1 downto 0);
          d: out STD_LOGIC_VECTOR(d_size - 1 downto 0);
          first_mis: out std_logic_vector(7 downto 0);
          comp_done: out STD_LOGIC);
end component;

constant la_size : integer := 6;
constant db_size : integer := 7;
constant d_size : integer := 3;
constant l_size : integer := 3;

--signal clk: std_logic;
signal clk, rst : STD_LOGIC;
signal Rx_done: STD_LOGIC;
signal Rx_all_done: STD_LOGIC;
signal Rx_data: STD_LOGIC_VECTOR(7 downto 0);
signal l: STD_LOGIC_VECTOR(l_size - 1 downto 0);
signal d: STD_LOGIC_VECTOR(d_size - 1 downto 0);
signal first_mis: std_logic_vector(7 downto 0);
signal comp_done: STD_LOGIC;

begin

clk_proc: process
begin
    clk <= '1'; wait for 5 ns;
    clk <= '0'; wait for 5 ns;
end process;

uut: compression_controller
generic map(la_size, db_size, d_size, l_size, 10)
port map(clk, rst, Rx_done, Rx_all_done, Rx_data, l, d, first_mis, comp_done);

--stim_proc: process
--begin
--    rst <= '1'; wait for 20 ns;
--    --1 6 1 2 5 1 3 1 4 1 2 5 1 5 5 1 5 5 1 6
--    Rx_all_done <= '0'; rst <= '0';
--    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000110"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000010"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000101"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000011"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000100"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000010"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000101"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000101"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000101"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000101"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000101"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 4900 ns;
--    Rx_data <= "00000110"; Rx_done <= '1';wait for 100 ns;
--    Rx_done <= '0'; wait for 15000 ns;
--    Rx_all_done <= '1'; wait;
--end process;

stim_proc: process
begin
    rst <= '1'; wait for 20 ns;
    Rx_all_done <= '0'; rst <= '0';
    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
    Rx_done <= '0'; wait for 4900 ns;
    Rx_data <= "00000110"; Rx_done <= '1';wait for 100 ns;
    Rx_done <= '0'; wait for 4900 ns;
    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
    Rx_done <= '0'; wait for 4900 ns;
    Rx_data <= "00000010"; Rx_done <= '1';wait for 100 ns;
    Rx_done <= '0'; wait for 4900 ns;
    Rx_data <= "00000101"; Rx_done <= '1';wait for 100 ns;
    Rx_done <= '0'; wait for 4900 ns;
    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
    Rx_done <= '0'; wait for 4900 ns;
    Rx_data <= "00000011"; Rx_done <= '1';wait for 100 ns;
    Rx_done <= '0'; wait for 4900 ns;
    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
    Rx_done <= '0'; wait for 4900 ns;
    Rx_data <= "00000100"; Rx_done <= '1';wait for 100 ns;
    Rx_done <= '0'; wait for 4900 ns;
    Rx_data <= "00000001"; Rx_done <= '1';wait for 100 ns;
    Rx_done <= '0'; wait for 400 ns;
    Rx_data <= "00000010"; Rx_done <= '1';wait for 100 ns;
    Rx_done <= '0'; wait for 400 ns;
    Rx_all_done <= '1'; wait;
end process;

end Behavioral;
