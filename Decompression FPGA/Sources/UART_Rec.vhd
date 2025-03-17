library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
--entity UART_Rec is
--  generic (
--    g_CLKS_PER_BIT : integer := 100000000/4800     -- Needs to be set correctly
--    );
--  port (
--    i_Clk       : in  std_logic;
--    i_RX_Serial : in  std_logic;
--    RX_done     : out std_logic;
--    allDone : out std_logic;
--    Data_out   : out std_logic_vector(7 downto 0)
--    );
--end UART_Rec;
 
entity UART_Rec is
generic(
    freq : integer :=100000000;
    baud : integer :=4800
);
port(
    clk2 : in std_logic;
    RX_I : in std_logic;
    Data_out : out std_logic_VECTOR(7 downto 0);
    RX_done : out std_logic;
    allDone : out std_logic:='0');     
end UART_Rec;
 
architecture rtl of UART_Rec is
 
  type t_SM_Main is (s_Idle, s_RX_Start_Bit, s_RX_Data_Bits,
                     s_RX_Stop_Bit, s_Cleanup);
  signal r_SM_Main : t_SM_Main := s_Idle;
 
  signal r_RX_Data_R : std_logic := '0';
  signal r_RX_Data   : std_logic := '0';
   signal g_CLKS_PER_BIT : integer := freq/baud;
  signal r_Clk_Count : integer range 0 to (freq/baud) := 0;
  signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
  signal r_RX_DV     : std_logic := '0';
  signal flag_time   : integer:=0;
begin
 

  p_SAMPLE : process (clk2)
  begin
    if rising_edge(clk2) then
      r_RX_Data_R <= RX_I;
      r_RX_Data   <= r_RX_Data_R; 
    end if; 
  end process p_SAMPLE;
 
  -- Purpose: Control RX state machine
  p_UART_RX : process (clk2)
  begin
    if rising_edge(clk2) then
      case r_SM_Main is
        when s_Idle =>
          r_RX_DV     <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;
          flag_time<=flag_time+1;   
          if(flag_time=150000*g_CLKS_PER_BIT)then
              allDone<='1';
          end if;
          
          if (r_RX_Data = '0') then       -- Start bit detected
            r_SM_Main <= s_RX_Start_Bit;
          else
            r_SM_Main <= s_Idle;
          end if;
 
          -- Check middle of start bit to make sure it's still low
          when s_RX_Start_Bit =>
          allDone <= '0';
          if r_Clk_Count = (g_CLKS_PER_BIT-1)/2 then
            if r_RX_Data = '0' then
              r_Clk_Count <= 0;  -- reset counter since we found the middle
              r_SM_Main   <= s_RX_Data_Bits;
            else
              r_SM_Main   <= s_Idle;
            end if;
          else
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Start_Bit;
          end if;
         
        -- Wait g_CLKS_PER_BIT-1 clock cycles to sample serial data
        when s_RX_Data_Bits =>
          allDone <= '0';
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Data_Bits;
          else
            r_Clk_Count            <= 0;
            r_RX_Byte(r_Bit_Index) <= r_RX_Data;
             
            -- Check if we have sent out all bits
            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
              r_SM_Main   <= s_RX_Data_Bits;
            else
              r_Bit_Index <= 0;
              r_SM_Main   <= s_RX_Stop_Bit;
            end if;
          end if;
           
        -- Receive Stop bit. Stop bit = 1
        when s_RX_Stop_Bit =>
          allDone <= '0';
          -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Stop_Bit;
          else
            r_RX_DV     <= '1';
            r_Clk_Count <= 0;
            r_SM_Main   <= s_Cleanup;
          end if;
            
        -- Stay here 1 clock
        when s_Cleanup =>
          allDone <= '0';
          r_SM_Main <= s_Idle;
          r_RX_DV   <= '0'; when others =>
          r_SM_Main <= s_Idle;
      end case;
    end if;
  end process p_UART_RX;
 
 RX_done   <= r_RX_DV;
 Data_out <= r_RX_Byte;
   
end rtl;