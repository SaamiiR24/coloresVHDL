library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity EDGEDTCTR is
 port (
 CLK : in std_logic;
 RESET: in std_logic; 
 SYNC_IN : in std_logic;
 EDGE : out std_logic
 );
end EDGEDTCTR;

architecture BEHAVIORAL of EDGEDTCTR is

component Prescaller is
port( 
  clk_i : in std_logic; -- reloj placa
  rstn_i : in std_logic; -- reset placa
  slowClk : out std_logic); -- salida que sirve para modificar el reloj de entrada
  end component;

signal slowclk_out : std_logic; 
signal sreg : std_logic_vector(2 downto 0);

begin

Pres: Prescaller
    port map(
     clk_i => CLK,
     rstn_i => RESET,
     slowClk => slowclk_out);
     
 process (slowclk_out)
 begin
   if rising_edge(slowclk_out) then
     sreg <= sreg(1 downto 0) & SYNC_IN;
   end if;
 end process;
 
 with sreg select
 EDGE <= '1' when "100",
         '0' when others;
 end BEHAVIORAL;
 