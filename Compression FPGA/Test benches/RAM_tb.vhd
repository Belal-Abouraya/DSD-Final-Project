library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RAM_tb is
--  Port ( );
end RAM_tb;

architecture Behavioral of RAM_tb is

component RAM is
    generic( size: integer := 1024);
    port( clk, rst, write: in std_logic;
          address: in integer;
          in_data: in std_logic_vector(7 downto 0);
          out_data: out std_logic_vector(7 downto 0)
    );
end component;

signal clk, rst, write: std_logic := '0';
signal address: integer := -1;
signal in_data: std_logic_vector(7 downto 0);
signal out_data: std_logic_vector(7 downto 0);

begin

uut: RAM generic map(4)
port map(clk, rst, write, address, in_data, out_data);

clk_proc: process
begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
end process;

stim_prc: process
begin
    rst <= '1'; wait for 20 ns;
    rst <= '0';
    in_data <= (others => '1');
    write <= '1'; wait for 20 ns;
    wait;
end process;

end Behavioral;
