----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.12.2025 14:02:30
-- Design Name: 
-- Module Name: Top_Level - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top_Level is
Port (
        CLK100MHZ : in std_logic;                       -- Reloj 
        CPU_RESETN: in std_logic;                       -- Reset 
        BTNU      : in std_logic;                       -- Botón Subir
        BTND      : in std_logic;                       -- Botón Bajar
        SW        : in std_logic_vector(1 downto 0);    -- Switches 
        
        -- salidas a los LED
        LED16_R   : out std_logic;
        LED16_G   : out std_logic;
        LED16_B   : out std_logic
    );
end Top_Level;

architecture Structural of Top_Level is

--  SEÑALES INTERNAS 
    signal rst_sys     : std_logic;    -- Reset 
    signal btn_up_clean: std_logic;    -- Botón subir 
    signal btn_dn_clean: std_logic;    -- Botón bajar 
    
    -- SEÑALES PARA LLEVAR AL PWM
    signal red_pwm_val  : std_logic_vector(3 downto 0);
    signal green_pwm_val: std_logic_vector(3 downto 0);
    signal blue_pwm_val : std_logic_vector(3 downto 0);
    
begin
    --REBOTES
    U_Rebotes_UP: entity work.Rebotes
    port map (
        clk     => CLK100MHZ,
        btn_in  => BTNU,
        btn_out => btn_up_clean
    );

    U_Rebots_DOWN: entity work.Rebotes
    port map (
        clk     => CLK100MHZ,
        btn_in  => BTND,
        btn_out => btn_dn_clean
    );
    
    
    -- UNIDAD DE CONTROL 
    U_Control: entity work.Unidad_Control
    port map (
        clk         => CLK100MHZ,
        reset       => rst_sys,
        btn_up      => btn_up_clean,
        btn_down    => btn_dn_clean,
        channel_sel => SW,
        -- SALIDAS
        red_val     => red_pwm_val,
        green_val   => green_pwm_val,
        blue_val    => blue_pwm_val
    );
    
    
    --CANALROJO
    U_PWM_Red: entity work.PWM_Generador
    Generic map ( DATA_WIDTH => 4 )
    port map (
        clk        => CLK100MHZ,
        reset      => rst_sys,
        duty_cycle => red_pwm_val, 
        pwm_out    => LED16_R      
    );

    --CANALVERDE
    U_PWM_Green: entity work.PWM_Generador
    Generic map ( DATA_WIDTH => 4 )
    port map (
        clk        => CLK100MHZ,
        reset      => rst_sys,
        duty_cycle => green_pwm_val,
        pwm_out    => LED16_G
    );

    --CANALAZUL
    U_PWM_Blue: entity work.PWM_Generador
    Generic map ( DATA_WIDTH => 4 )
    port map (
        clk        => CLK100MHZ,
        reset      => rst_sys,
        duty_cycle => blue_pwm_val,
        pwm_out    => LED16_B
    );


end Structural;
