library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use STD.textio.all;
use IEEE.std_logic_textio.all;

library UNISIM;
use UNISIM.VComponents.all;

entity RgbLed_tb is 
end RgbLed_tb;

architecture behavioral of RgbLed_tb is 

component rgbLed is 
port(
      clk_i : in std_logic; -- reloj de la placa 100MHz
      rstn_i : in std_logic; -- reset de la placa
      
      -- Botones-- l,c,r para movernos por los estados, d,u para modificar el brillo.
      btnl_i : in std_logic;
      btnc_i : in std_logic;
      btnr_i : in std_logic;
      btnd_i : in std_logic;
      btnu_i : in std_logic; 
      
      -- LD16 PWM output signals LED RGB derecha
      pwm1_red_o : out std_logic;
      pwm1_green_o : out std_logic;
      pwm1_blue_o : out std_logic;
      
      -- LD17 PWM output signals LED RGB izquierda
      pwm2_red_o : out std_logic;
      pwm2_green_o : out std_logic;
      pwm2_blue_o : out std_logic;
      
       --LED's para simbolizar el estado en el que estemos 
      stateLEDS : out std_logic_vector(4 downto 0)
   );
end component;

signal clk_s : std_logic;
signal rstn_s : std_logic;
signal btnu_s: std_logic;
signal btnd_s: std_logic;
signal btnl_s: std_logic;
signal btnr_s: std_logic;
signal btnc_s: std_logic;
signal pwm1_red_s : std_logic;
signal pwm1_green_s : std_logic;
signal pwm1_blue_s : std_logic;
signal pwm2_red_s : std_logic;
signal pwm2_green_s : std_logic;
signal pwm2_blue_s :  std_logic;
signal stateLEDS_s : std_logic_vector (4 downto 0);

constant k: time := 5ns;

begin 
uut: RgbLed
port map ( 
clk_i => clk_s,
rstn_i => rstn_s,
btnl_i => btnu_s,
btnc_i => btnd_s,
btnr_i => btnr_s,
btnd_i => btnd_s,
btnu_i => btnu_s,
pwm1_red_o => pwm1_red_s,
pwm1_green_o => pwm1_green_s,
pwm1_blue_o => pwm1_blue_s,    
pwm2_red_o => pwm2_red_s,
pwm2_green_o => pwm2_green_s,
pwm2_blue_o => pwm2_blue_s,
stateLEDS => stateLEDS_s
);


p1 : process
begin
clk_s <= '0';
wait for k/2;
clk_s <= '1';
wait for k/2;
end process;

p2: process
begin
rstn_s <='0';
wait for 20 ns;
rstn_s <= '1'; --stInicio

btnr_s <= '1';  --stRed
wait for 10 ns;
btnr_s <= '0';
wait for 30 ns;

btnr_s <= '1'; --stGreen
wait for 10 ns; 
btnr_s <= '0';
wait for 30 ns;

btnr_s <= '1'; --stBlue
wait for 10 ns;
btnr_s <= '0';
wait for 30 ns;

btnr_s <= '1'; --stInicio
wait for 10 ns;
btnr_s <= '0';
wait for 30 ns;

btnl_s <= '1'; --stBlue
wait for 10 ns;
btnl_s <= '0';
wait for 30 ns;

btnl_s <= '1'; --stGreen
wait for 10 ns;
btnl_s <= '0';
wait for 30 ns;

btnl_s <= '1'; --stRed
wait for 10 ns;
btnl_s <= '0';
wait for 30 ns;

btnl_s <= '1'; --stInicio
wait for 10 ns;
btnl_s <= '0';
wait for 30 ns;

btnc_s <= '1'; --st12off
wait for 10 ns;
btnc_s <= '0';
wait for 3 ns;






assert false;
  report "[PASED]: Simulation finished"
  severity failure;
 end process;
 end; 



