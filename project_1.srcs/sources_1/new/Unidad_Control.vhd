----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.12.2025 12:46:29
-- Design Name: 
-- Module Name: Unidad_Control - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Unidad_Control is
Port (
        clk         : in std_logic;
        reset       : in std_logic;
        btn_up      : in std_logic; 
        btn_down    : in std_logic; 
        channel_sel : in std_logic_vector(1 downto 0); -- Switches para elegir R, G o B
        
        -- salidas: valores de brillo para cada PWM
        red_val     : out std_logic_vector(3 downto 0);
        green_val   : out std_logic_vector(3 downto 0);
        blue_val    : out std_logic_vector(3 downto 0)
    );
    end Unidad_Control;

architecture Behavioral of Unidad_Control is
        --las señales de color
    signal r_count : unsigned(3 downto 0) := (others => '0');
    signal g_count : unsigned(3 downto 0) := (others => '0');
    signal b_count : unsigned(3 downto 0) := (others => '0');
        --detector de flancos
    signal btn_up_prev   : std_logic := '0';
    signal btn_down_prev : std_logic := '0';
    
    signal pulso_subir : std_logic;
    signal pulso_bajar : std_logic;
    
    

begin

-- DETECTOR DE FLANCOS POSITIVO, QUE BRILLE UNA VEZ POR PULSACION : 
    pulso_subir <= '1' when (btn_up = '1' and btn_up_prev = '0') else '0';
    pulso_bajar <= '1' when (btn_down = '1' and btn_down_prev = '0') else '0';
    
--logica:

process (clk)
begin
    if rising_edge (clk) then
        if reset='1' then
            r_count<=(others=>'0');
            g_count <= (others => '0');
            b_count <= (others => '0');
            btn_up_prev   <= '0';
            btn_down_prev <= '0';
        else
            btn_up_prev   <= btn_up;
            btn_down_prev <= btn_down;
    
        --seleccion
        case channel_sel is
                    when "01" => --rojo
                        if pulso_subir = '1' then
                            if r_count < 15 then  --saturacion maxima del colo r
                                r_count <= r_count + 1;
                            end if;
                        elsif pulso_bajar = '1' then
                            if r_count > 0 then  
                                r_count <= r_count - 1;
                            end if;
                        end if;

                    when "10" => --veerde
                        if pulso_subir = '1' then
                            if g_count < 15 then
                                g_count <= g_count + 1;
                            end if;
                        elsif pulso_bajar = '1' then
                            if g_count > 0 then
                                g_count <= g_count - 1;
                            end if;
                        end if;

                    when "11" => --azul
                        if pulso_subir = '1' then
                            if b_count < 15 then
                                b_count <= b_count + 1;
                            end if;
                        elsif pulso_bajar = '1' then
                            if b_count > 0 then
                                b_count <= b_count - 1;
                            end if;
                        end if;

                    when others => 
                        null; 
                end case;
            end if;
        end if;
end process;

end Behavioral;
