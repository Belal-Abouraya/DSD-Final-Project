library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FPGA2 is
Port ( clk: in STD_LOGIC;
       rst: in STD_LOGIC;
       RX_I : in STD_LOGIC;
       hsync: out STD_LOGIC;
       vsync: out STD_LOGIC;
       R: out STD_LOGIC_VECTOR(3 downto 0);
       G: out STD_LOGIC_VECTOR(3 downto 0);
       B: out STD_LOGIC_VECTOR(3 downto 0);
       out_byte_count: out STD_LOGIC_VECTOR(12 downto 0);
       out_all_done: out STD_LOGIC);
end FPGA2;

architecture Behavioral of FPGA2 is

component RAM is
    generic( size: integer := 1024);
    port( clk, rst, write: in std_logic;
          address: in integer;
          in_data: in std_logic_vector(7 downto 0);
          out_data: out std_logic_vector(7 downto 0)
    );
end component;

component decompression_controller is
generic( d_size: integer:= 6;
         l_size: integer:= 2;
         width: integer:= 80);
Port ( clk, rst : in STD_LOGIC;
       Rx_done: in STD_LOGIC;
       Rx_data: in STD_LOGIC_VECTOR(7 downto 0);
       read_data: in STD_LOGIC_VECTOR(7 downto 0);
       address : out integer;
       w : out STD_LOGIC;
       write_data : out STD_LOGIC_VECTOR(7 downto 0);
       all_done : out STD_LOGIC:= '0');
end component;

component UART_Rec is
   generic(
     freq : integer :=100000000;
     baud : integer :=4800
     );
    port(
     clk2 : in std_logic;
     RX_I : in std_logic;
     Data_out : out std_logic_VECTOR(7 downto 0);
     RX_done : out std_logic;
     allDone : out std_logic := '0');     
end component;

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

constant d_size: integer:= 6;
constant l_size: integer:= 2;
constant freq : integer := 100000000;
constant baud : integer := 115200;
constant width : integer := 50;
constant word_size : integer := 3 * width * width / 2;

signal Rx_done: STD_LOGIC;
signal Rx_all_done: STD_LOGIC;
signal Rx_data: STD_LOGIC_VECTOR(7 downto 0);
signal l: STD_LOGIC_VECTOR(l_size - 1 downto 0);
signal d: STD_LOGIC_VECTOR(d_size - 1 downto 0);
signal first_mis: std_logic_vector(7 downto 0);
signal read_data: STD_LOGIC_VECTOR(7 downto 0);
signal address, decomp_address, disp_address, byte_count: integer := 0;
signal w: STD_LOGIC;
signal write_data: STD_LOGIC_VECTOR(7 downto 0);
signal all_done: STD_LOGIC;

begin

receiver_unit: UART_Rec
   generic map (
     freq => freq,
     baud => baud
     )
    port map(
     clk2 => clk,
     RX_I => RX_I,
     Data_out => Rx_data,
     RX_done => Rx_done,
     allDone => Rx_all_done);     

decompression_unit: decompression_controller
generic map( d_size => d_size,
             l_size => l_size,
             width => width)
Port map ( clk => clk,
           rst => rst,
           Rx_done => Rx_done,
           Rx_data => Rx_data,
           read_data => read_data,
           address => decomp_address,
           w => w,
           write_data => write_data,
           all_done => all_done);

word: RAM
generic map(size => word_size)
port map( clk => clk,
          rst => rst,
          write => w,
          address => address,
          in_data => write_data,
          out_data => read_data);

disp_unit: display_controller
generic map(width => width)
port map( clk => clk,
          read_data => read_data,
          address => disp_address,
          hsync => hsync,
          vsync => vsync,
          R => R,
          G => G,
          B => B);

count_bytes_proc: process(Rx_done, rst)
begin
    if(rst = '1') then
        byte_count <= 0;
    elsif(rising_edge(Rx_done)) then
        byte_count <= byte_count + 1;
    end if;
end process;

with all_done select
    address <= decomp_address when '0',
    disp_address when others;
out_all_done <= all_done;
out_byte_count <= std_logic_vector(to_unsigned(byte_count, out_byte_count'length));

end Behavioral;