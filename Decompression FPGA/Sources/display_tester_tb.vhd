library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_tester_tb is
--  Port ( );
end display_tester_tb;

architecture Behavioral of display_tester_tb is

component display_controller_tester is
Port ( clk, rst : in STD_LOGIC;
       hsync: out STD_LOGIC;
       vsync: out STD_LOGIC;
       R: out STD_LOGIC_VECTOR(3 downto 0);
       G: out STD_LOGIC_VECTOR(3 downto 0);
       B: out STD_LOGIC_VECTOR(3 downto 0));
end component;

signal clk, rst : STD_LOGIC;
signal hsync: STD_LOGIC;
signal vsync: STD_LOGIC;
signal R: STD_LOGIC_VECTOR(3 downto 0);
signal G: STD_LOGIC_VECTOR(3 downto 0);
signal B: STD_LOGIC_VECTOR(3 downto 0);

begin

clk_proc: process
begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
end process;

uut: display_controller_tester port map(clk, rst, hsync, vsync, R, G, B);

stim_proc: process
begin
    rst <= '1';
    wait;
end process;

end Behavioral;
