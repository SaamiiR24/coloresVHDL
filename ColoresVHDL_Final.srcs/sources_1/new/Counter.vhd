library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is 
PORT(
   clk_i : in std_logic;
   rstn_i : in std_logic;
   slowclk_i : in std_logic; -- Nueva entrada para el enable
   btnup: in std_logic;
   btndown : in std_logic;
   colorcnt: out std_logic_vector(7 downto 0)
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
    elsif slowclk_i = '1' then -- Solo evaluamos botones 10 veces por segundo
      if btnup = '1' and cnt_reg < 250 then 
          cnt_reg <= cnt_reg + 5;
      elsif btndown = '1' and cnt_reg > 4 then
          cnt_reg <= cnt_reg - 5;
      end if;
    end if;
  end if;
 end process;

 colorcnt <= std_logic_vector(cnt_reg);
end behavioral;