library IEEE;
  use ieee.std_logic_1164.all;

entity FDIVIDER is
  generic (
    CLKIN_FREQ  : positive;
    CLKOUT_FREQ : positive
  );
  port (
    CLK_IN  : in    std_logic;
    CLK_OUT : out   std_logic
  );
end entity FDIVIDER;

architecture BEHAVIORAL of FDIVIDER is

  signal clk_state : std_logic := '0';

begin

  DIV_P : process (CLK_IN) is

    subtype count_t is integer range 0 to CLKIN_FREQ / (2 * CLKOUT_FREQ) - 1;

    variable count : count_t := count_t'high;

  begin

    if rising_edge(CLK_IN) then
      if (count /= 0) then
        count := count - 1;
      else
        count     := count_t'high;
        clk_state <= not clk_state;
      end if;
    end if;

  end process DIV_P;

  CLK_OUT <= clk_state;

end architecture BEHAVIORAL;
