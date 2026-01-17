library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use STD.textio.all;
use IEEE.std_logic_textio.all;

library UNISIM;
use UNISIM.VComponents.all;

entity Counter_tb is 
end Counter_tb;

architecture behavioral of Counter_tb is 

component Counter is 
port(
  clk_i : in std_logic;
  rstn_i : in std_logic;
  btnup: in std_logic;
  btndown : in std_logic;
  colorcnt: out std_logic_vector(7 downto 0)
   );
end component;

signal clk_s : std_logic;
signal rstn_s : std_logic;
signal btnup_s: std_logic;
signal btndown_s: std_logic;
signal colorcnt_s: std_logic_vector(7 downto 0);

constant k: time := 10ns;

begin 
uut: Counter
port map ( 
clk_i => clk_s,
rstn_i => rstn_s,
btnup => btnup_s,
btndown => btndown_s,
colorcnt => colorcnt_s
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
wait for 30ns;
rstn_s <= '1';
wait for 60ns;
btnup_s <= '1';
wait for 30ns;
btnup_s <= '0';
wait for 60ns;
btnup_s <= '1';
wait for 30ns;
btnup_s <= '0';
wait for 60ns;
btndown_s <= '1';
wait for 30 ns;
btndown_s <= '0';
wait for 60ns;
btndown_s <= '1';
wait for 30ns;
btndown_s <= '0';
wait for 60ns;
btndown_s <= '1';
wait for 30ns;
btndown_s <= '0';
wait for 60ns;



assert false;
  report "[PASED]: Simulation finished"
  severity failure;
 end process;
 end; 

