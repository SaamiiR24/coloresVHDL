----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.12.2025 12:46:29
-- Design Name: 
-- Module Name: PWM_Generador - Behavioral
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

entity PWM_Generador is
    Generic (
        DATA_WIDTH : integer := 4  -- 16 niveles
        );
    Port (
        clk       : in std_logic;
        reset     : in std_logic;
        duty_cycle: in std_logic_vector(DATA_WIDTH-1 downto 0); -- valor del brillo
        pwm_out   : out std_logic
    );
end PWM_Generador;

architecture Behavioral of PWM_Generador is

begin


end Behavioral;
