library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity compression_controller is
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
end compression_controller;

architecture Behavioral of compression_controller is

component RAM is
    generic( size: integer := 1024);
    port( clk, rst, write: in std_logic;
          address: in integer;
          in_data: in std_logic_vector(7 downto 0);
          out_data: out std_logic_vector(7 downto 0)
    );
end component;

component shift_window is
    generic(l_size: integer:= 2);
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           l : in STD_LOGIC_VECTOR(l_size - 1 downto 0);
           start_address : in integer;
           in_data: in STD_LOGIC_VECTOR(7 downto 0);
           curr_address : out integer;
           w : out STD_LOGIC;
           out_data: out STD_LOGIC_VECTOR(7 downto 0);
           done : out STD_LOGIC);
end component;

component find_match is
    generic( la_size: integer:= 4;
             db_size: integer:= 64;
             d_size: integer:= 6;
             l_size: integer:= 2);
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

type state_type is (shift, match, done);
signal state: state_type := shift; --load the la first

--RX signals
signal Rx_buffer_write: STD_LOGIC := '0';
signal tmp_Rx_data: std_logic_vector(7 downto 0);
signal got_data: STD_LOGIC := '0'; -- initially no data

-- find match signals
signal match_en: STD_LOGIC := '0';
signal match_rst: STD_LOGIC := '1';
signal match_done: STD_LOGIC;
signal match_read_address, curr_l_int: integer;
signal curr_match_data: std_logic_vector(7 downto 0);
signal curr_l: STD_LOGIC_VECTOR(l_size - 1 downto 0);
signal curr_d: STD_LOGIC_VECTOR(d_size - 1 downto 0);
          
-- shift window signals
signal shift_en: STD_LOGIC := '0';
signal shift_rst: STD_LOGIC := '1';
signal shift_start_address: integer := -1; --start with empty receiver buffer
signal shift_read_address: integer;
signal comp_buffer_write: STD_LOGIC := '0';
signal shift_done: STD_LOGIC;
signal first_done: STD_LOGIC := '0';
signal comp_in_data: std_logic_vector(7 downto 0);
signal Rx_buffer_data: std_logic_vector(7 downto 0);
signal l_mx: integer := la_size - 1; --try to match all the of la first
signal cl: integer := la_size - 1; --fill the la at the start
signal shift_curr_l: STD_LOGIC_VECTOR(l_size - 1 downto 0) := std_logic_vector(to_unsigned(la_size - 1, l_size));

begin

--receiver buffer
rec_mem: RAM
generic map(rec_size)
port map(clk => clk,
         rst => rst,
         write => Rx_buffer_write,
         address => shift_read_address,
         in_data => tmp_Rx_data,
         out_data => Rx_buffer_data);

--compression buffer
comp_mem: RAM
generic map(la_size + db_size)
port map(clk => clk,
         rst => rst,
         write => comp_buffer_write,
         address => match_read_address,
         in_data => comp_in_data,
         out_data => curr_match_data);


-- find match comp
match_unit: find_match
generic map( la_size => la_size,
             db_size => db_size,
             d_size => d_size,
             l_size => l_size)
    Port map( clk => clk,
              rst => match_rst,
              en => match_en,
              l_mx => l_mx,
              curr_data => curr_match_data,
              address => match_read_address,
              l => curr_l,
              d => curr_d,           
              first_mis => first_mis,
              found => match_done);

-- shift window comp
shift_unit: shift_window generic map(l_size => l_size)
    Port map( clk => clk,
              en => shift_en,
              rst => shift_rst,
              l => shift_curr_l,
              start_address => shift_start_address,
              in_data => Rx_buffer_data,
              curr_address => shift_read_address,
              w => comp_buffer_write,
              out_data => comp_in_data,
              done => shift_done);

curr_l_int <= to_integer(unsigned(curr_l));
l <= curr_l;
d <= curr_d;
comp_done <= match_done;

process(clk)
begin
    if(rst = '1') then
        state <= shift; --load the la first
        --RX signals
        Rx_buffer_write <= '0';
        tmp_Rx_data <= (others => '0');
        got_data <= '0'; -- initially no data
        
        -- find match signals
        match_en <= '0';
        match_rst <= '1';
                          
        -- shift window signals
        shift_en <= '0';
        shift_rst <= '1';
        shift_start_address <= -1; --start with empty receiver buffer
        first_done <= '0';
        l_mx <= la_size - 1; --try to match all the of la first
        cl <= la_size - 1; --fill the la at the start
        shift_curr_l <= std_logic_vector(to_unsigned(la_size - 1, l_size));

    elsif(rising_edge(clk)) then
        case state is
            when shift =>
                if(l_mx < 0) then
                    state <= done;
                elsif(shift_start_address < cl) then
                    -- waiting for bytes to arrive
                    if(Rx_all_done = '1') then -- no more incoming bytes
                        --if first time only
                        if(first_done = '0') then
                            l_mx <= la_size - 1 -  cl + shift_start_address;--adjust max match length
                            first_done <= '1';
                        end if;
                        --fill the rest of rec with zeros so we can shift with the required length
                        if(got_data = '0') then
                            tmp_Rx_data <= (others => '0');
                            got_data <= '1';
                        end if;
                    elsif(Rx_done = '1' and got_data = '0') then -- got a new byte
                        tmp_Rx_data <= Rx_data;
                        got_data <= '1';
                    end if;
                    if(got_data = '1' and Rx_buffer_write = '0' and (Rx_done = '0' or Rx_all_done = '1')) then --write the data to the receiver buffer
                        Rx_buffer_write <= '1';
                    elsif(Rx_buffer_write = '1') then -- done the writing
                        got_data <= '0';
                        Rx_buffer_write <= '0';
                        shift_start_address <= shift_start_address + 1;
                    end if;
                else
                    shift_en <= '1';
                    shift_rst <= '0';
                    if(Rx_done = '1' and got_data = '0') then -- got a new byte while shifting
                        -- buffer it because compression is much faster
                        tmp_Rx_data <= Rx_data;
                        got_data <= '1';
                    end if;
                    if(shift_done = '1') then
                        state <= match;
                        shift_en <= '0';
                        shift_rst <= '1';
                        match_en <= '1';
                        match_rst <= '0';
                        shift_start_address <= shift_start_address - cl - 1;
                    end if;
                end if;
            when match =>
                if(match_done = '1') then
                    match_en <= '0';
                    match_rst <= '1';
                    cl <= curr_l_int;
                    shift_curr_l <= curr_l;
                    state <= shift;
                    if(first_done = '1') then
                        l_mx <= l_mx - curr_l_int - 1;
                    end if;
                end if;
                -- handling incoming bytes
                if(Rx_done = '1' and got_data = '0') then -- got a new byte while matching
                    tmp_Rx_data <= Rx_data;
                    got_data <= '1';
                end if;
                if(got_data = '1' and Rx_buffer_write = '0' and Rx_done = '0') then --write the data to the receiver buffer
                    Rx_buffer_write <= '1';
                elsif(Rx_buffer_write = '1') then -- done the writing
                    got_data <= '0';
                    Rx_buffer_write <= '0';
                    shift_start_address <= shift_start_address + 1;
                end if;
            when done =>
                if(Rx_all_done = '0') then
                    state <= shift; --load the la first
                    --RX signals
                    Rx_buffer_write <= '0';
                    tmp_Rx_data <= (others => '0');
                    got_data <= '0'; -- initially no data
                    
                    -- find match signals
                    match_en <= '0';
                    match_rst <= '1';
                                      
                    -- shift window signals
                    shift_en <= '0';
                    shift_rst <= '1';
                    shift_start_address <= -1; --start with empty receiver buffer
                    first_done <= '0';
                    l_mx <= la_size - 1; --try to match all the of la first
                    cl <= la_size - 1; --fill the la at the start
                end if;
            end case;
    end if;
end process;

end Behavioral;
