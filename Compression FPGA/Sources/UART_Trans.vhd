
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_Trans is
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
end UART_Trans;

architecture Behavioral of UART_Trans is

type state_type is (T_idle,T_start,T_data,T_stop);
signal state : state_type := T_idle;

constant periodic_time : integer := freq/baud;
signal bit_time , bit_index : integer := 0;
signal data_buffer :std_logic_vector(7 downto 0);


begin
data_buffer<=Data_in;
process(clk1) 
begin 
if(clk1='1' and clk1'event) then
    if(start = '0') then
        state<=T_idle;
    else
        bit_time <= bit_time +1;
        case state is
            When T_idle =>             
                TX_O <='1';
                TX_done <= '0';
                if(start = '1') then 
                    TX_O <='0';
                    state <= T_start;
                 end if;
                 
            When T_start =>
                if(bit_time = periodic_time - 1 ) then
                    bit_time <= 0;
                    state <= T_data;
                 end if;
                 
            When T_data =>
                TX_O <= data_buffer(bit_index);
                if(bit_time = periodic_time - 1) then
                    bit_time <=0;
                    bit_index <= bit_index+1;                        
                    if(bit_index = 7) then 
                        bit_time <=0;
                        bit_index<=0;
                        TX_O<='1';
                        state<=T_stop;
                     end if;
                 end if;   

            When T_stop =>
                if(bit_time = periodic_time - 1 ) then
                    bit_time<=0;
                    state<=T_idle;
                elsif(bit_time = periodic_time - 3) then
                    TX_done<='0';
                elsif(bit_time = periodic_time - 4) then
                    TX_done<='1';
                end if;                        
                                    
end case; end if; end if;
end process;

end Behavioral;
