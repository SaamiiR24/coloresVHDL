library ieee;
use ieee.std_logic_1164.all;

entity EDGEDTCTR is
 port (
    clk_i     : in std_logic; -- Reloj rapido (100MHz)
    rstn_i    : in std_logic;
    slowclk_i : in std_logic; -- 10Hz
    sig_i     : in std_logic; -- Señal limpia del botón (del Synchronizer)
    edge_o    : out std_logic -- Pulso de salida
 );
end EDGEDTCTR;

architecture BEHAVIORAL of EDGEDTCTR is
    signal sig_prev : std_logic := '0';
begin
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if rstn_i = '0' then
                sig_prev <= '0';
                edge_o <= '0';
            else
                edge_o <= '0'; -- Por defecto no hay pulso
                
                -- Solo miramos si el Prescaller nos da(10Hz)
                if slowclk_i = '1' then
                    -- Si esta pulsado AHORA y NO lo estaba ANTES 
                    if sig_i = '1' and sig_prev = '0' then
                        edge_o <= '1';
                    end if;
                    
                    -- Actualizamos la memoria
                    sig_prev <= sig_i;
                end if;
            end if;
        end if;
    end process;
end BEHAVIORAL;