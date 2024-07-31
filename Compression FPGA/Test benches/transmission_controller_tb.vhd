library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity transmission_controller_tb is
--  Port ( );
end transmission_controller_tb;

architecture Behavioral of transmission_controller_tb is

component transmission_controller is
    generic( d_size: integer:= 6;
             l_size: integer:= 2;
             buff_size: integer:= 20);
    Port (clk, rst: in STD_LOGIC;
          l: in STD_LOGIC_VECTOR(l_size - 1 downto 0);
          d: in STD_LOGIC_VECTOR(d_size - 1 downto 0);
          first_mis: in STD_LOGIC_VECTOR(7 downto 0);
          comp_done: in STD_LOGIC;
          Tx_O: out STD_LOGIC);
end component;

signal clk, rst: STD_LOGIC;
signal l: STD_LOGIC_VECTOR(1 downto 0);
signal d: STD_LOGIC_VECTOR(5 downto 0);
signal first_mis: STD_LOGIC_VECTOR(7 downto 0);
signal comp_done: STD_LOGIC;
signal Tx_O: STD_LOGIC;

begin

clk_proc: process
begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
end process;

uut: transmission_controller
port map(clk, rst, l, d,first_mis, comp_done, Tx_O);

stim_proc: process
begin
    comp_done <= '0';
    rst <= '1'; wait for 10 ns;
    rst <= '0';
    
    l <= "01";
    d <= "000001";
    first_mis <= "00001010";
    comp_done <= '1'; wait for 10 ns;
    comp_done <= '0'; wait for 30 ns;
    
    l <= "11";
    d <= "000001";
    first_mis <= "00001011";
    comp_done <= '1'; wait for 10 ns;
    comp_done <= '0'; wait for 30 ns;
    
    l <= "10";
    d <= "000010";
    first_mis <= "00001111";
    comp_done <= '1'; wait for 10 ns;
    comp_done <= '0'; wait for 30 ns;
    
    l <= "01";
    d <= "001001";
    first_mis <= "01001011";
    comp_done <= '1'; wait for 10 ns;
    comp_done <= '0'; wait for 30 ns;
    
    l <= "10";
    d <= "000001";
    first_mis <= "01101011";
    comp_done <= '1'; wait for 10 ns;
    comp_done <= '0'; wait for 30 ns;

    wait;
end process;

end Behavioral;
