library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FPGA1 is
    port( clk: in STD_LOGIC;
          rst: in STD_LOGIC;
          RX_I : in STD_LOGIC;
          Tx_O: out STD_LOGIC;
          out_Rx_all_done: out STD_LOGIC
    );
end FPGA1;

architecture Behavioral of FPGA1 is

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

constant la_size: integer:= 4;
constant db_size: integer:= 63;
constant d_size: integer:= 6;
constant l_size: integer:= 2;
constant rec_size: integer := 10;
constant buff_size: integer:= 100;
constant freq : integer := 100000000;
constant baud : integer := 4800;

signal Rx_done: STD_LOGIC;
signal Rx_all_done: STD_LOGIC;
signal Rx_data: STD_LOGIC_VECTOR(7 downto 0);
signal l: STD_LOGIC_VECTOR(l_size - 1 downto 0);
signal d: STD_LOGIC_VECTOR(d_size - 1 downto 0);
signal first_mis: std_logic_vector(7 downto 0);
signal comp_done: STD_LOGIC;

begin

compression_unti: compression_controller
    generic map( la_size => la_size,
                 db_size => db_size,
                 d_size => d_size,
                 l_size => l_size,
                 rec_size => rec_size)
    Port map (clk => clk,
              rst => rst,
              Rx_done => Rx_done,
              Rx_all_done => Rx_all_done,
              Rx_data => Rx_data,
              l => l,
              d => d,
              first_mis => first_mis,
              comp_done => comp_done);

transmission_unit: transmission_controller
    generic map( d_size => d_size,
                 l_size => l_size,
                 buff_size => buff_size)
    Port map (clk => clk,
              rst => rst,
              l => l,
              d => d,
              first_mis => first_mis,
              comp_done => comp_done,
              Tx_O => Tx_O);

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

out_Rx_all_done <= Rx_all_done;

end Behavioral;
