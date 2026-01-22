library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity Prescaller is
port(
 clk_i : in std_logic;
 rstn_i : in std_logic;
 slowClk : out std_logic
 );
 end Prescaller;
 
 architecture behavioral of Prescaller is
 
 constant CLK_DIV : integer := 3; -- constante por la que dividimos la frecuencia del reloj
 signal clkCnt : integer := 0; -- contador 
 
 begin 
 process(clk_i)
 begin
  if rising_edge(clk_i) then
         if rstn_i = '0' then
            clkCnt <= 0 ;
         elsif clkCnt = CLK_DIV-1 then
            clkCnt <= 0 ;
         else
            clkCnt <= clkCnt + 1;
         end if;
      end if;
  end process;
  slowClk <= '1' when clkCnt = CLK_DIV-1 else '0'; -- 10 Hz que buscamos 
 end behavioral;
 
 -- La funcción principal del Prescaller es reducir el reloj de la placa. Para ello, 
 -- creamos una señal "clkCnt" que cuente los flancos positivos del reloj de entrada.
 -- La salida "slowCLK" será 1 cuando el contador alcance la constante establecida.
 -- Con esto conseguimos obtener una nueva frecuencia, con la cual trabajamos en otros
 -- componentes del proyecto. En este  caso buscamos una salida de 10 Hz por lo que debemos de
 -- declarar un CLK_DIV de 10000000; de esta forma: 100Mhz/10000000 = 10HZ.
 
   
 
 
 

  
