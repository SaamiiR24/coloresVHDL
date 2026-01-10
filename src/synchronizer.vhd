library ieee;
  use ieee.std_logic_1164.all;

entity SYNCHRONIZER is
  generic (
    QUIESCENT_VALUE : std_logic;
    SYNC_STAGES     : positive
  );
  port (
    CLK      : in    std_logic;
    ASYNC_IN : in    std_logic;
    SYNC_OUT : out   std_logic
  );
end entity SYNCHRONIZER;

architecture BEHAVIORAL of SYNCHRONIZER is

  attribute async_reg : string;

  signal sreg : std_logic_vector(SYNC_STAGES - 1 downto 0) := (others => QUIESCENT_VALUE);
  attribute async_reg of sreg : signal is "true";

begin

  SYNC_OUT <= sreg(sreg'left);

  SR_P : process (CLK) is
  begin

    if rising_edge(CLK) then
      sreg <= sreg(SYNC_STAGES - 2 downto 0) & ASYNC_IN;
    end if;

  end process SR_P;

end architecture BEHAVIORAL;
