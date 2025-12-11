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

begin


end Behavioral;
