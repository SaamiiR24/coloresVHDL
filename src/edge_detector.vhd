library ieee;
  use ieee.std_logic_1164.all;

entity EDGE_DETECTOR is
  generic (
    QUIESCENT_VALUE : std_logic
  );
  port (
    CLK     : in    std_logic;
    DIN     : in    std_logic;
    EDGE    : out   std_logic
  );
end entity EDGE_DETECTOR;

architecture BEHAVIORAL of EDGE_DETECTOR is

  constant edge_pattern : std_logic_vector(2 downto 0) := (2 => not QUIESCENT_VALUE, others => QUIESCENT_VALUE);
  signal   sreg         : std_logic_vector(2 downto 0) := (others => QUIESCENT_VALUE);

begin

  SR_P : process (CLK) is
  begin

    if rising_edge(CLK) then
      sreg <= sreg(1 downto 0) & DIN;
    end if;

  end process SR_P;

  EDGE <= '1' when sreg = edge_pattern else
          '0';

end architecture BEHAVIORAL;

