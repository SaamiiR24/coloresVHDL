library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is 
PORT(
   clk_i      : in std_logic;
   rstn_i     : in std_logic;
   
   
   -- Ya no hay slowclk, solo pulsos de disparo
   pulse_up   : in std_logic;
   pulse_down : in std_logic;
   colorcnt   : out std_logic_vector(7 downto 0)
);
end Counter;

architecture behavioral of Counter is 
   signal cnt_reg: unsigned (7 downto 0):= (others => '0');
begin 
 process(clk_i)
 begin
  if rising_edge(clk_i) then
    if rstn_i = '0' then 
      cnt_reg <= (others => '0');
    else
      -- Logica directa: Si llega pulso, lo hace
      if pulse_up = '1' and cnt_reg < 250 then 
          cnt_reg <= cnt_reg + 5;
      elsif pulse_down = '1' and cnt_reg > 4 then
          cnt_reg <= cnt_reg - 5;
      end if;
    end if;
  end if;
 end process;

 colorcnt <= std_logic_vector(cnt_reg);
end behavioral;