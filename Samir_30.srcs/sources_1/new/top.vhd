library ieee;
use ieee.std_logic_1164.all;

entity top is 
 PORT( 
      clk_i: in std_logic;
      reset: in std_logic;
      
      -- Botones 
      btnl_i : in std_logic;
      btnc_i : in std_logic;
      btnr_i : in std_logic;
      btnd_i : in std_logic;
      btnu_i : in std_logic; 
      
      -- Salidas
      LED: out std_logic_vector(4 downto 0);
      rgb1_red_o   : out std_logic;
      rgb1_green_o : out std_logic;
      rgb1_blue_o  : out std_logic;
      rgb2_red_o   : out std_logic;
      rgb2_green_o : out std_logic;
      rgb2_blue_o  : out std_logic
      );
end top;

architecture behavioral of top is

    -- Señales para los botones ya limpios 
    signal syn_btnl : std_logic;
    signal syn_btnc : std_logic;
    signal syn_btnr : std_logic;
    signal syn_btnd : std_logic;
    signal syn_btnu : std_logic;

    COMPONENT RgbLed is 
    PORT (
        clk_i : in std_logic;
        rstn_i : in std_logic;
        
        -- Entradas de botones (*ya sincronizados*)
        btnl_i : in std_logic;
        btnc_i : in std_logic;
        btnr_i : in std_logic;
        btnd_i : in std_logic;
        btnu_i : in std_logic;
          
        -- Salidas PWM
        pwm1_red_o : out std_logic;
        pwm1_green_o : out std_logic;
        pwm1_blue_o : out std_logic;
        pwm2_red_o : out std_logic;
        pwm2_green_o : out std_logic;
        pwm2_blue_o : out std_logic;
        
        -- LEDs de estado
        stateLEDS : out std_logic_vector(4 downto 0)
    );
    END COMPONENT;

    COMPONENT SYNCHRNZR
    PORT ( 
        CLK : in std_logic;
        reset_i: in std_logic;
        ASYNC_IN : in std_logic;
        SYNC_OUT : out std_logic
    );
    END COMPONENT;

begin

    -- Instancia del módulo principal
    -- Nota: Le pasamos las señales limpitas
    Inst_RgbLed : RgbLed PORT MAP (
        clk_i => clk_i,
        rstn_i => reset,
        btnl_i => syn_btnl,
        btnc_i => syn_btnc,
        btnr_i => syn_btnr,
        btnd_i => syn_btnd,
        btnu_i => syn_btnu,
        pwm1_red_o => rgb1_red_o,
        pwm1_green_o => rgb1_green_o,
        pwm1_blue_o => rgb1_blue_o,
        pwm2_red_o => rgb2_red_o,
        pwm2_green_o => rgb2_green_o,
        pwm2_blue_o => rgb2_blue_o,
        stateLEDS => LED
    );

    -- Sincronizadores para cada botom
    Inst_SYNCHRNZR1 : SYNCHRNZR PORT MAP (
        CLK => clk_i,
        reset_i => reset,
        ASYNC_IN => btnl_i,
        SYNC_OUT => syn_btnl
    );

    Inst_SYNCHRNZR2 : SYNCHRNZR PORT MAP (
        CLK => clk_i,
        reset_i => reset,
        ASYNC_IN => btnc_i,
        SYNC_OUT => syn_btnc
    );

    Inst_SYNCHRNZR3 : SYNCHRNZR PORT MAP (
        CLK => clk_i,
        reset_i => reset,
        ASYNC_IN => btnr_i,
        SYNC_OUT => syn_btnr
    );

    Inst_SYNCHRNZR4 : SYNCHRNZR PORT MAP (
        CLK => clk_i,
        reset_i => reset,
        ASYNC_IN => btnd_i,
        SYNC_OUT => syn_btnd
    );

    Inst_SYNCHRNZR5 : SYNCHRNZR PORT MAP (
        CLK => clk_i,
        reset_i => reset,
        ASYNC_IN => btnu_i,
        SYNC_OUT => syn_btnu
    );

end behavioral;