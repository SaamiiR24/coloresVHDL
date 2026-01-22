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
          cnt <= cnt + 5; -- MODIFICAMOS
      else 
          cnt <= cnt;
      end if;
    elsif btndown = '1' then 
      if cnt > 4 then -- llega hasta el cero
          cnt <= cnt - 5; -- MODIFICAMOS
      else 
          cnt <= cnt;
      end if;
    end if;
  end if;
end process;

colorcnt <= std_logic_vector(cnt);
end behavioral; 

-- Counter es el componente encargado de modificar el ciclo de trabajo. A través
-- de los botones "btnup" y "btndown" somos capaces de modificar la salide "colorcnt".
-- Esta salida es posteriormente "data_i" (ciclo de trabajo). Es decir gracias a este
-- componente somos capaces de modificar el ciclo de trabajo de los leds con los botones
-- y relacionarlo con el componente pwm para generar el brillo deseado en los leds.
-- El rango del pwm abarcar desde el 0 hasta el 255. cada vez que se pulsan los botnones
-- sumamos o restamos 5, por lo que podemos generar 51 niveles de brillos diferentes. 
-- desde 0 (apagado) hasta 255 (máximo ciclo de trabajo / máximo brillo)

