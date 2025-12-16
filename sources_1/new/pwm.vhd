
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity Pwm is
   port(
      clk_i : in std_logic; -- 100MHz
      data_i : in std_logic_vector(7 downto 0); -- the number to be modulated
      pwm_o : out std_logic
   );
end Pwm;

architecture Behavioral of Pwm is

signal cnt : std_logic_vector(7 downto 0);

begin

   COUNT: process(clk_i)
   begin
      if rising_edge(clk_i) then
         cnt <= cnt + '1';
      end if;
   end process COUNT;
   
   COMPARE: process(data_i, cnt)
   begin
      if unsigned(cnt) < unsigned(data_i) then
         pwm_o <= '1';
      else
         pwm_o <= '0';
      end if;
   end process COMPARE;

end Behavioral;


