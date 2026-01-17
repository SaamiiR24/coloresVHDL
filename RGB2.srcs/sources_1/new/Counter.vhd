library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity Counter is 
PORT(
clk_i : in std_logic;
rstn_i : in std_logic;
btnup: in std_logic;
btndown : in std_logic;
colorcnt: out std_logic_vector(7 downto 0)
);
end Counter;

architecture behavioral of Counter is 

component Prescaller is
port( 
  clk_i : in std_logic;
  rstn_i : in std_logic;
  slowClk : out std_logic);
  end component;
  

signal cnt: unsigned (7 downto 0):= "00000000";
signal slowClk_out: std_logic;

begin 

 Pres: Prescaller
   port map(
     clk_i => clk_i,
     rstn_i => rstn_i,
     slowClk => slowclk_out);
 
 process(slowclk_out)
 begin
  if rising_edge(slowclk_out) then
  
    if rstn_i = '0' then 
      cnt <= (OTHERS =>'0'); 
      
    elsif btnup = '1' then 
      if cnt < 251 then --llega hasta el 255 
          cnt <= cnt + 5;
      else 
          cnt <= cnt;
      end if;
    elsif btndown = '1' then 
      if cnt > 4 then -- llega hasta el cero
          cnt <= cnt - 5;
      else 
          cnt <= cnt;
      end if;
    end if;
  end if;
end process;

colorcnt <= std_logic_vector(cnt);
end behavioral; 

      


