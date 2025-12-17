library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Rebotes is
    Port (
        clk        : in std_logic;
        btn_in     : in std_logic;  -- Botón físico 
        btn_out    : out std_logic  -- Señal limpia 
    );
end Rebotes;


architecture Behavioral of Rebotes is

    constant ESPERA_CICLOS : integer := 1000000;
    
    signal contador : integer range 0 to ESPERA_CICLOS := 0; -- contador del reloj acorde al reloj de la placa
    signal estado_guardado : std_logic := '0'; 
    
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if (btn_in = estado_guardado) then
                contador <= 0;
            else
                if (contador < ESPERA_CICLOS) then
                    contador <= contador + 1;
                else
                    estado_guardado <= btn_in;
                    contador <= 0;
                end if;
            end if;
        end if;
    end process;

    -- la salida es siempre el estado "limpio" 
    btn_out <= estado_guardado;

end Behavioral;