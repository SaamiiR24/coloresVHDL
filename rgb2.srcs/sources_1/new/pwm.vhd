
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_signed.all;

entity PWM is
  port (
    CLK_I  : in    std_logic;                    -- 100MHz
    DATA_I : in    std_logic_vector(7 downto 0); -- the number to be modulated
    PWM_O  : out   std_logic
  );
end entity PWM;

architecture BEHAVIORAL of PWM is

  signal cnt : std_logic_vector(7 downto 0);

begin

  COUNT : process (CLK_I) is
  begin

    if rising_edge(CLK_I) then
      cnt <= cnt + '1';
    end if;

  end process COUNT;

  COMPARE : process (DATA_I, cnt) is
  begin

    if (unsigned(cnt) < unsigned(DATA_I)) then
      PWM_O <= '1';
    else
      PWM_O <= '0';
    end if;

  end process COMPARE;

end architecture BEHAVIORAL;


