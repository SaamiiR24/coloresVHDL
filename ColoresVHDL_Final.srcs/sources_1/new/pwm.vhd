library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Mejor usar esta que std_logic_arith

entity pwm is
   port(
      clk_i : in std_logic;
      rstn_i : in std_logic;
      data_i : in std_logic_vector(7 downto 0);
      pwm_o : out std_logic
   );
end pwm;

architecture Behavioral of pwm is
   signal cnt : unsigned(7 downto 0) := (others => '0');
begin
   -- El PWM debe ser mas rapido, usamos el clk normal
   COUNT: process(clk_i)
   begin
      if rising_edge(clk_i) then
         if rstn_i = '0' then
            cnt <= (others => '0');
         else
            cnt <= cnt + 1;
         end if;
      end if;
   end process COUNT;

   pwm_o <= '1' when cnt < unsigned(data_i) else '0';
end Behavioral;