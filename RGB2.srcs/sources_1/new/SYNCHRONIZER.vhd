library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity SYNCHRNZR is
 port (
 CLK : in std_logic;
 RESET: in std_logic; 
 ASYNC_IN : in std_logic;
 SYNC_OUT : out std_logic
 );
end SYNCHRNZR;

architecture BEHAVIORAL of SYNCHRNZR is

component Prescaller is
port( 
  clk_i : in std_logic; -- reloj placa
  rstn_i : in std_logic; -- reset placa
  slowClk : out std_logic); -- salida que sirve para modificar el reloj de entrada
  end component;

signal sreg : std_logic_vector(1 downto 0);
signal slowclk_out: std_logic;

begin

Pres: Prescaller
    port map(
     clk_i => CLK,
     rstn_i => RESET,
     slowClk => slowclk_out);

 process (slowclk_out)
 begin
   if rising_edge(slowclk_out) then
     sync_out <= sreg(1);
     sreg <= sreg(0) & async_in;
   end if;
 end process;
end BEHAVIORAL;