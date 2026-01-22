
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity pwm is
   generic ( 
   max_val: integer := 255 -- rango PWM -- MODIFICAMOS
   );
   port(
      clk_i : in std_logic; -- reloj de la placa 100MHz
      rstn_i : in std_logic; -- reset de la placa
      data_i : in std_logic_vector(7 downto 0); -- Simboliza el ciclo de trabajo
      pwm_o : out std_logic -- 1 o 0 
   );
end pwm;

architecture Behavioral of pwm is

component Prescaller is
port( 
  clk_i : in std_logic;
  rstn_i : in std_logic;
  slowClk : out std_logic);
  end component;
  
signal slowclk_out: std_logic;
signal output : std_logic;
signal cnt : unsigned(7 downto 0):= "00000000"; 
begin

Pres: Prescaller
   port map(
     clk_i => clk_i,
     rstn_i => rstn_i,
     slowClk => slowclk_out);

   COUNT: process(slowclk_out, rstn_i)
   begin
      if rising_edge(slowclk_out) then
        if rstn_i = '0' then
          cnt <= (OTHERS => '0');
        elsif cnt < 254 then 
          cnt <= cnt + 1;
        else 
        cnt <= (OTHERS =>'0');
        end if;
      end if;
   end process COUNT;
   
   COMPARE: process(data_i, cnt)
   begin
  
   if cnt < unsigned(data_i) then
         output <= '1';
   else
         output <= '0';
   end if;
   end process COMPARE;
   
   pwm_o <= output;
end Behavioral;

-- Dividimos el componente PWM en dos prcesos. El primero sirve de un contador,
-- el cual, va contando de uno en uno de 0 hasta 255. El segundo proceso sirve 
-- para comparar el el ciclo de trabajo que queremos con el ciclo total del pwm.
-- La salida del componente corresponde al brillo del led. Contra mayor "data_i" 
-- mayor será el ciclo de trabajo y por lo tanto mayor será el brillo de los leds.
-- La salida "output" se mantiene a uno si el contador (señal "cnt")es menor que
-- el ciclo de trabajo "data_i".






