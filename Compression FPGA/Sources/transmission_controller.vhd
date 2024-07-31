library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity transmission_controller is
    generic( d_size: integer:= 6;
             l_size: integer:= 2;
             buff_size: integer:= 20);
    Port (clk, rst: in STD_LOGIC;
          l: in STD_LOGIC_VECTOR(l_size - 1 downto 0);
          d: in STD_LOGIC_VECTOR(d_size - 1 downto 0);
          first_mis: in STD_LOGIC_VECTOR(7 downto 0);
          comp_done: in STD_LOGIC;
          Tx_O: out STD_LOGIC);
end transmission_controller;

architecture Behavioral of transmission_controller is

component RAM is
    generic( size: integer := 1024);
    port( clk, rst, write: in std_logic;
          address: in integer;
          in_data: in std_logic_vector(7 downto 0);
          out_data: out std_logic_vector(7 downto 0)
    );
end component;

component UART_Trans is
    generic(
        freq : integer :=100000000;
        baud : integer :=4800
        );
    port(
        clk1 : in std_logic;
        start : in std_logic := '0';
        Data_in : in std_logic_VECTOR(7 downto 0);
        
        TX_done : out std_logic := '0';
        TX_O: out std_logic := '1');        
end component;

constant freq : integer := 100000000;
constant baud : integer := 115200;

signal byte1, byte2, Tx_data: std_logic_vector(7 downto 0);
signal done1, done2: std_logic := '1';
signal Tx_done: std_logic := '0';
signal Tx_start: std_logic := '0';

signal curr_address: integer := -1;
signal buff_read_data, buff_write_data: std_logic_vector(7 downto 0);
signal w: std_logic := '0';
signal done_flag: std_logic := '0';

begin

transmitter: UART_Trans
generic map(freq => freq, baud => baud)
port map(clk1 => clk,
         start => Tx_start,
         Data_in => Tx_data,
         Tx_done => Tx_done,
         TX_O => Tx_O);

buff: RAM
generic map(buff_size)
port map(clk => clk,
         rst => rst,
         write => w,
         address => curr_address,
         in_data => buff_write_data,
         out_data => buff_read_data);       

Tx_data <= buff_read_data;

process(clk)
    variable nxt_address: integer := curr_address;
begin
    if(rst = '1') then
        done1 <= '1';
        done2 <= '1';
        Tx_start <= '0';
        curr_address <= -1;
        w <= '0';
    elsif(rising_edge(clk)) then
        nxt_address := curr_address;
        
        if(comp_done = '1') then
            byte1 <= l & d;
            byte2 <= first_mis;
            done1 <= '0';
            done2 <= '0';
        elsif(done1 = '0') then
            --write b1 to ram
            done1 <= '1';
            w <= '1';
            buff_write_data <= byte1;
        elsif(done2 = '0') then
            --write b2 to ram
            done2 <= '1';
            buff_write_data <= byte2;
            nxt_address := nxt_address + 1;
        elsif(done2 = '1') then
            if(w = '1') then
                w <= '0';
                nxt_address := nxt_address + 1;
            end if;
        end if;
        
        -- handle transmitter
        if(Tx_start = '0') then -- start transmitting
            if(curr_address >= 0) then
                Tx_start <= '1';
--                Tx_data <= buff_read_data;
--                nxt_address := nxt_address - 1;
            end if;
        elsif(Tx_done = '1') then
            done_flag <= '1';
        elsif(done_flag = '1' and Tx_done = '0') then
            done_flag <= '0';
            if(curr_address < 0) then
            -- stop transmitter
                Tx_start <= '0';
            else
                nxt_address := nxt_address - 1;
            end if;
        elsif(curr_address < 0) then
            Tx_start <= '0';
        end if;
        curr_address <= nxt_address;
    end if;
end process;

end Behavioral;
