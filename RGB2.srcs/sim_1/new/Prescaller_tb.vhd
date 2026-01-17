library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use STD.textio.all;
use IEEE.std_logic_textio.all;

library UNISIM;
use UNISIM.VComponents.all;

entity Prescaller_tb is 
end Prescaller_tb;

architecture behavioral of Prescaller_tb is 

component Prescaller is 
port(
   clk_i : in std_logic;
   rstn_i : in std_logic;
   slowClk : out std_logic
   );
end component;

signal clk_s : std_logic;
signal rstn_s : std_logic;
signal slowClk_s : std_logic;

constant k: time := 10ns;

begin 
uut: Prescaller
port map ( 
clk_i => clk_s,
rstn_i => rstn_s,
slowClk => slowClk_s
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
wait for 150ns;
rstn_s <= '1';
wait for 10150ns;

assert false;
  report "[PASED]: Simulation finished"
  severity failure;
 end process;
 end; 
