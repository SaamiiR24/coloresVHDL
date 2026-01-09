library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_signed.all;

library ieee;
  use ieee.std_logic_1164.all;

entity EDGE_DETECTOR is
  port (
    CLK     : in    std_logic;
    SYNC_IN : in    std_logic;
    EDGE    : out   std_logic
  );
end entity EDGE_DETECTOR;

architecture BEHAVIORAL of EDGE_DETECTOR is

  signal sreg : std_logic_vector(2 downto 0);

begin

  process (CLK) is
  begin

    if rising_edge(CLK) then
      sreg <= sreg(1 downto 0) & SYNC_IN;
    end if;

  end process;

  with sreg select EDGE <=
    '1' when "100",
    '0' when others;

end architecture BEHAVIORAL;

