library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_controller_tb is
--  Port ( );
end display_controller_tb;

architecture Behavioral of display_controller_tb is

component display_controller is
generic(width: integer:= 80);
Port ( clk : in STD_LOGIC;
       read_data: in STD_LOGIC_VECTOR(7 downto 0);
       address : out integer;
       hsync: out STD_LOGIC;
       vsync: out STD_LOGIC;
       R: out STD_LOGIC_VECTOR(3 downto 0);
       G: out STD_LOGIC_VECTOR(3 downto 0);
       B: out STD_LOGIC_VECTOR(3 downto 0));
end component;

component RAM is
    generic( size: integer := 1024);
    port( clk, rst, write: in std_logic;
          address: in integer;
          in_data: in std_logic_vector(7 downto 0);
          out_data: out std_logic_vector(7 downto 0)
    );
end component;

signal clk, rst, w : STD_LOGIC;
signal read_data, in_data: STD_LOGIC_VECTOR(7 downto 0);
signal address : integer;
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

uut : display_controller 
generic map(4)
port map(clk => clk,
          read_data => read_data,
          address =>address,
          hsync=>hsync,
          vsync=> vsync,
          R=>R,
          G=>G,
          B=>B);
mem: RAM
generic map(24)
port map(clk, rst, w, address, in_data, read_data);

stim_proc: process
begin
    rst <= '1'; wait for 10 ns;
    rst <= '0';
    w <= '1'; in_data <= "00001111"; wait for 10 ns;
    w <= '1'; in_data <= "10001111"; wait for 10 ns;
    w <= '1'; in_data <= "01001111"; wait for 10 ns;
    w <= '1'; in_data <= "00101111"; wait for 10 ns;
    w <= '1'; in_data <= "00011111"; wait for 10 ns;
    w <= '1'; in_data <= "00000111"; wait for 10 ns;
    w <= '1'; in_data <= "00001011"; wait for 10 ns;
    w <= '1'; in_data <= "00001101"; wait for 10 ns;
    w <= '1'; in_data <= "00001110"; wait for 10 ns;
    w <= '1'; in_data <= "01101111"; wait for 10 ns;
    w <= '1'; in_data <= "10101111"; wait for 10 ns;
    w <= '1'; in_data <= "10001011"; wait for 10 ns;
    w <= '1'; in_data <= "01011111"; wait for 10 ns;
    w <= '1'; in_data <= "11101111"; wait for 10 ns;
    w <= '1'; in_data <= "11111111"; wait for 10 ns;
    w <= '1'; in_data <= "00000000"; wait for 10 ns;
    w <= '1'; in_data <= "00101011"; wait for 10 ns;
    w <= '1'; in_data <= "11011111"; wait for 10 ns;
    w <= '1'; in_data <= "00001111"; wait for 10 ns;
    w <= '1'; in_data <= "10101011"; wait for 10 ns;
    w <= '1'; in_data <= "01001111"; wait for 10 ns;
    w <= '1'; in_data <= "00001111"; wait for 10 ns;
    w <= '1'; in_data <= "00001111"; wait for 10 ns;
    w <= '1'; in_data <= "00000010"; wait for 10 ns;
    w <= '0';
    wait;
end process;

end Behavioral;
