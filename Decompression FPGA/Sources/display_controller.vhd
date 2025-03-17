library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_controller is
generic(width: integer:= 80);
Port ( clk : in STD_LOGIC;
       read_data: in STD_LOGIC_VECTOR(7 downto 0);
       address : out integer;
       hsync: out STD_LOGIC;
       vsync: out STD_LOGIC;
       R: out STD_LOGIC_VECTOR(3 downto 0);
       G: out STD_LOGIC_VECTOR(3 downto 0);
       B: out STD_LOGIC_VECTOR(3 downto 0));
end display_controller;

architecture Behavioral of display_controller is

component VGAController IS
  GENERIC(
    h_pulse  : INTEGER := 96;    --horiztonal sync pulse width in pixels
    h_bp     : INTEGER := 48;    --horiztonal back porch width in pixels
    h_pixels : INTEGER := 640;   --horiztonal display width in pixels
    h_fp     : INTEGER := 16;    --horiztonal front porch width in pixels
    h_pol    : STD_LOGIC := '0';  --horizontal sync pulse polarity (1 = positive, 0 = negative)
    v_pulse  : INTEGER := 2;      --vertical sync pulse width in rows
    v_bp     : INTEGER := 33;     --vertical back porch width in rows
    v_pixels : INTEGER := 480;   --vertical display width in rows
    v_fp     : INTEGER := 10;      --vertical front porch width in rows
    v_pol    : STD_LOGIC := '0'); --vertical sync pulse polarity (1 = positive, 0 = negative)
  PORT(
    pixel_clk : IN   STD_LOGIC;  --pixel clock at frequency of VGA mode being used
    reset_n   : IN   STD_LOGIC;  --active low asycnchronous reset
    h_sync    : OUT  STD_LOGIC;  --horiztonal sync pulse
    v_sync    : OUT  STD_LOGIC;  --vertical sync pulse
    disp_ena  : OUT  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    column    : OUT  INTEGER;    --horizontal pixel coordinate
    row       : OUT  INTEGER);    --vertical pixel coordinate
END component;

signal pixel_clk: std_logic := '0';
signal pixel_counter: integer := 0;
signal disp_ena  :  std_logic;
signal curr_row, curr_col: integer;
signal curr_R, curr_G, curr_B: std_logic_vector(3 downto 0);
signal even_R, even_G, even_B: std_logic_vector(3 downto 0);
signal odd_R, odd_G, odd_B: std_logic_vector(3 downto 0);
signal zeros: std_logic_vector(3 downto 0) := (others => '0');

signal curr_address: integer := 0;
signal byte0, byte1, byte2: std_logic_vector(7 downto 0) := (others => '0');
signal nxt_byte0, nxt_byte1, nxt_byte2: std_logic_vector(7 downto 0) := (others => '0');
signal got0, got1, got2: std_logic := '0';
signal in_photo, row_range: std_logic;
signal curr_col_vec: std_logic_vector(31 downto 0);

begin

address <= curr_address;
curr_col_vec <= std_logic_vector(to_unsigned(curr_col, curr_col_vec'length));

row_range <= '1' when curr_row < width else '0';
in_photo <= '1' when curr_col < width and row_range = '1' else '0';

even_R <= byte0(7 downto 4);
even_G <= byte0(3 downto 0);
even_B <= byte1(7 downto 4);

odd_R <= byte1(3 downto 0);
odd_G <= byte2(7 downto 4);
odd_B <= byte2(3 downto 0);

curr_R <= zeros when in_photo = '0' else even_R when curr_col_vec(0) = '0' else odd_R;
curr_G <= zeros when in_photo = '0' else even_G when curr_col_vec(0) = '0' else odd_G;
curr_B <= zeros when in_photo = '0' else even_B when curr_col_vec(0) = '0' else odd_B;

vga: VGAController
  port map(pixel_clk => pixel_clk,
           reset_n => '1',
           h_sync => hsync,
           v_sync => vsync,
           disp_ena => disp_ena,
           column => curr_col,
           row => curr_row);

read_ram_proc: process(clk)
begin
    if(rising_edge(clk)) then
        if(in_photo = '1') then
            if(curr_col_vec(0) = '0') then -- load two pixels at a time
                if(got0 = '0') then
                    byte0 <= nxt_byte0;
                    byte1 <= nxt_byte1;
                    byte2 <= nxt_byte2;
                    
                    got0 <= '1';
                    nxt_byte0 <= read_data;
                    curr_address <= curr_address + 1;
                elsif(got1 = '0') then
                    got1 <= '1';
                    nxt_byte1 <= read_data;
                    curr_address <= curr_address + 1;
                elsif(got2 = '0') then
                    got2 <= '1';
                    nxt_byte2 <= read_data;
                    curr_address <= curr_address + 1;
                end if;
            else -- reset to load at the even index
                got0 <= '0';
                got1 <= '0';
                got2 <= '0';
            end if;
        elsif(row_range = '0') then
            if(got0 = '0') then
                curr_address <= 0;
            else
                if(got0 = '0') then
                    got0 <= '1';
                    nxt_byte0 <= read_data;
                    curr_address <= curr_address + 1;
                elsif(got1 = '0') then
                    got1 <= '1';
                    nxt_byte1 <= read_data;
                    curr_address <= curr_address + 1;
                elsif(got2 = '0') then
                    got2 <= '1';
                    nxt_byte2 <= read_data;
                    curr_address <= curr_address + 1;
                end if;
            end if;
        end if;
    end if;
end process;

divider: process(clk)
begin
    if(rising_edge(clk)) then
        if(pixel_counter < 2) then
            pixel_clk <= '0';
        else
            pixel_clk <= '1';
        end if;
        
        if(pixel_counter = 3) then
            pixel_counter <= 0;
        else
            pixel_counter <= pixel_counter + 1;
        end if;
    end if;
end process;

render_proc: PROCESS(disp_ena, clk)
BEGIN
    IF(disp_ena = '1') THEN        --display time
        R <= curr_R;
        G <= curr_G;
        B <= curr_B;
    ELSE                           --blanking time
        R <= (OTHERS => '0');
        G <= (OTHERS => '0');
        B <= (OTHERS => '0');
    END IF;  
END PROCESS;

end Behavioral;
