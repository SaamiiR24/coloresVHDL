
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use STD.textio.all;
use IEEE.std_logic_textio.all;

library UNISIM;
use UNISIM.VComponents.all;

entity pwm_tb is 
end pwm_tb;

architecture behavioral of pwm_tb is 

component pwm is 
port(
      clk_i : in std_logic; -- 100MHz
      rstn_i: in std_logic;
      data_i : in std_logic_vector(7 downto 0); -- the number to be modulated
      pwm_o : out std_logic
   );
end component;

signal clk_s : std_logic;
signal rstn_s : std_logic;
signal data_s : std_logic_vector(7 downto 0);
signal pwm_s : std_logic;

constant k: time := 0.1ns;

begin 
uut: pwm
port map ( 
clk_i => clk_s,
rstn_i => rstn_s,
data_i => data_s,
pwm_o => pwm_s
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

rstn_s <= '0';
wait for 150 ns;
rstn_s <= '1';


--data_s <= "00000011"; -- 3 con CLK_DIV = 3 son 9 ciclos de reloj
--wait for 500 ns;

data_s <= "01111111"; -- 127 con CLK_DIV =3 son 381 ciclos de reloj
wait for 1000ns;




assert false;
  report "[PASED]: Simulation finished"
  severity failure;
 end process;
 end; 
