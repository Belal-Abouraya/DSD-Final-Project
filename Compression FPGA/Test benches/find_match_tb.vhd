library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity find_match_tb is
--  Port ( );
end find_match_tb;

architecture Behavioral of find_match_tb is

component RAM is
    generic( size: integer := 1024);
    port( clk, rst, write: in std_logic;
          address: in integer;
          in_data: in std_logic_vector(7 downto 0);
          out_data: out std_logic_vector(7 downto 0)
    );
end component;

component find_match is
    generic( la_size, db_size, d_size, l_size: integer := 2);
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
end component;

--constant la_size: integer := 4;
--constant db_size:integer := 8;
--constant d_size: integer := 3;
--constant l_size: integer := 2;
--constant l_mx: integer := 3;
constant la_size: integer := 6;
constant db_size:integer := 7;
constant d_size: integer := 3;
constant l_size: integer := 3;
constant l_mx: integer := 5;

signal clk, rst_r, w : STD_LOGIC;
signal rst :STD_LOGIC;
signal en : STD_LOGIC;
signal curr_data, in_data: std_logic_vector(7 downto 0) := (others => '1');
signal address: integer;
signal l: std_logic_vector(l_size - 1 downto 0);
signal d: std_logic_vector(d_size - 1 downto 0);           
signal first_mis: std_logic_vector(7 downto 0);
signal found : STD_LOGIC;

begin

clk_proc: process
begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
end process;


memo: RAM
generic map(la_size + db_size)
port map(clk, rst_r, w, address, in_data, curr_data);

uut: find_match
generic map(la_size, db_size, d_size, l_size)
port map(clk, rst, en, l_mx,curr_data, address, l, d, first_mis, found);

--stim_prc: process
--begin
--    rst <= '1'; en <= '0';
--    rst_r <= '1'; wait for 10 ns;
--    rst_r <= '0';
--    w <= '1'; in_data <= "00001111";wait for 10 ns;
--    w <= '1'; in_data <= "00001111";wait for 10 ns;
--    w <= '1'; in_data <= "00000001";wait for 10 ns;
--    w <= '1'; in_data <= "00000100";wait for 10 ns;
--    w <= '1'; in_data <= "00000010";wait for 10 ns;
--    w <= '1'; in_data <= "00001111";wait for 10 ns;
--    w <= '1'; in_data <= "00000010";wait for 10 ns;
--    w <= '1'; in_data <= "00000001";wait for 10 ns;
--    w <= '1'; in_data <= "00000100";wait for 10 ns;
--    w <= '1'; in_data <= "00000010";wait for 10 ns;
--    w <= '1'; in_data <= "00000001";wait for 10 ns;
--    w <= '1'; in_data <= "00001111";wait for 10 ns;
--    w <= '0';
--    rst <= '0'; en <= '1';
--    wait for 10000 ns;
--    wait;
--end process;

--stim_prc: process
--begin
--    rst <= '1'; en <= '0';
--    rst_r <= '1'; wait for 10 ns;
--    rst_r <= '0';
--    w <= '1'; in_data <= "00000001";wait for 10 ns;
--    w <= '1'; in_data <= "00001111";wait for 10 ns;
--    w <= '1'; in_data <= "00000001";wait for 10 ns;
--    w <= '1'; in_data <= "00000100";wait for 10 ns;
--    w <= '1'; in_data <= "00000010";wait for 10 ns;
--    w <= '1'; in_data <= "00000001";wait for 10 ns;
--    w <= '1'; in_data <= "00000010";wait for 10 ns;
--    w <= '1'; in_data <= "00000010";wait for 10 ns;
--    w <= '1'; in_data <= "00000001";wait for 10 ns;
--    w <= '1'; in_data <= "00000010";wait for 10 ns;
--    w <= '1'; in_data <= "00000010";wait for 10 ns;
--    w <= '1'; in_data <= "00000001";wait for 10 ns;
--    w <= '1'; in_data <= "00001111";wait for 10 ns;
--    w <= '0';
--    rst <= '0'; en <= '1';
--    wait for 10000 ns;
--    wait;
--end process;

stim_prc: process
begin
    rst <= '1'; en <= '0';
    rst_r <= '1'; wait for 10 ns;
    rst_r <= '0';
--    w <= '1'; in_data <= "00000001";wait for 10 ns;
--    w <= '1'; in_data <= "00000110";wait for 10 ns;
    w <= '1'; in_data <= "00000001";wait for 10 ns;
    w <= '1'; in_data <= "00000010";wait for 10 ns;
    w <= '1'; in_data <= "00000101";wait for 10 ns;
    w <= '1'; in_data <= "00000001";wait for 10 ns;
    w <= '1'; in_data <= "00000011";wait for 10 ns;
    w <= '1'; in_data <= "00000001";wait for 10 ns;
    w <= '1'; in_data <= "00000100";wait for 10 ns;
    w <= '1'; in_data <= "00000001";wait for 10 ns;
    w <= '1'; in_data <= "00000010";wait for 10 ns;
    w <= '1'; in_data <= "00000101";wait for 10 ns;
    w <= '1'; in_data <= "00000001";wait for 10 ns;
    w <= '1'; in_data <= "00000101";wait for 10 ns;
    w <= '1'; in_data <= "00000101";wait for 10 ns;
    w <= '0';
    rst <= '0'; en <= '1';
    wait for 10000 ns;
    wait;
end process;

end Behavioral;
