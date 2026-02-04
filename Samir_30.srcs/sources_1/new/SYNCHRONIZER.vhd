library ieee;
use ieee.std_logic_1164.all;

entity SYNCHRNZR is
 port (
    CLK : in std_logic;
    reset_i: in std_logic;
    ASYNC_IN : in std_logic;
    SYNC_OUT : out std_logic
 );
end SYNCHRNZR;

architecture BEHAVIORAL of SYNCHRNZR is
    signal sreg : std_logic_vector(1 downto 0) := "00";
begin
    process (CLK) -- Ahora usa el reloj de 100MHz directamente
    begin
        if rising_edge(CLK) then
            if reset_i = '0' then
                sreg <= "00";
                SYNC_OUT <= '0';
            else
                sreg <= sreg(0) & ASYNC_IN;
                SYNC_OUT <= sreg(1);
            end if;
        end if;
    end process;
end BEHAVIORAL;