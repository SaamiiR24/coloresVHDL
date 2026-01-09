library ieee;
  use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity DEBOUNCER is
  generic (
    NR_OF_CLKS : integer := 4095 -- Number of System Clock periods while the incoming signal
  ); -- has to be stable until a one-shot output signal is generated
  port (
    CLK_I : in    std_logic;
    SIG_I : in    std_logic;
    PLS_O : out   std_logic
  );
end entity DEBOUNCER;

architecture BEHAVIORAL of DEBOUNCER is

  signal cnt             : integer range 0 to NR_OF_CLKS - 1;
  signal sigtmp          : std_logic;
  signal stble, stbletmp : std_logic;

begin

  DEB : process (CLK_I) is
  begin

    if rising_edge(CLK_I) then
      if (SIG_I = sigtmp) then         -- Count the number of clock periods if the signal is stable
        if (cnt = NR_OF_CLKS - 1) then
          stble <= SIG_I;
        else
          cnt <= cnt + 1;
        end if;
      else                             -- Reset counter and sample the new signal value
        cnt    <= 0;
        sigtmp <= SIG_I;
      end if;
    end if;

  end process DEB;

  PLS : process (CLK_I) is
  begin

    if rising_edge(CLK_I) then
      stbletmp <= stble;
    end if;

  end process PLS;

  -- generate the one-shot output signal
  PLS_O <= '1' when stbletmp = '0' and stble = '1' else
           '0';

end architecture BEHAVIORAL;
