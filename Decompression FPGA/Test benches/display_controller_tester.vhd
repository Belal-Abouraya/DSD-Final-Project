library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_controller_tester is
Port ( clk, rst : in STD_LOGIC;
       hsync: out STD_LOGIC;
       vsync: out STD_LOGIC;
       R: out STD_LOGIC_VECTOR(3 downto 0);
       G: out STD_LOGIC_VECTOR(3 downto 0);
       B: out STD_LOGIC_VECTOR(3 downto 0));
end display_controller_tester;

architecture Behavioral of display_controller_tester is

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

signal w : STD_LOGIC;
signal read_data, in_data: STD_LOGIC_VECTOR(7 downto 0);
signal address : integer;
type string is array (0 to 23) of std_logic_vector(7 downto 0);
signal word: string;
signal tmp: integer := 0;

begin

word(0) <= "00000000";
word(1) <= "00001111";
word(2) <= "11110000";
word(3) <= "00000000";
word(4) <= "00001111";
word(5) <= "11110000";
word(6) <= "00000000";
word(7) <= "00001111";
word(8) <= "11110000";
word(9) <= "00000000";
word(10) <= "00001111";
word(11) <= "11110000";
word(12) <= "00000000";
word(13) <= "00001111";
word(14) <= "11110000";
word(15) <= "00000000";
word(16) <= "00001111";
word(17) <= "11110000";
word(18) <= "00000000";
word(19) <= "00001111";
word(20) <= "11110000";
word(21) <= "00000000";
word(22) <= "00001111";
word(23) <= "11110000";

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
port map(clk, '0', w, address, in_data, read_data);

process(rst, clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            w <= '0';
            if(tmp < 24) then
                tmp <= tmp + 1;
                w <= '1';
                in_data <= word(tmp);
            end if;
        end if;
    end if;
end process;

end Behavioral;
