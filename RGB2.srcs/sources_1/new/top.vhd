library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity top is 
 PORT( 
      clk_i: in std_logic;
      reset: in std_logic;
      
      btnl_i : in std_logic;
      btnc_i : in std_logic;
      btnr_i : in std_logic;
      btnd_i : in std_logic;
      btnu_i : in std_logic; 
      LED: out std_logic_vector(4 downto 0);
      rgb1_red_o     : out std_logic;
      rgb1_green_o   : out std_logic;
      rgb1_blue_o    : out std_logic;
      rgb2_red_o     : out std_logic;
      rgb2_green_o   : out std_logic;
      rgb2_blue_o    : out std_logic
      );
      
end top;

architecture behavioral of top is

signal syn_edge1 : std_logic;
signal syn_edge2 : std_logic;
signal syn_edge3 : std_logic;
signal syn_edge4 : std_logic;
signal syn_edge5 : std_logic;
signal edg_fsm1: std_logic;
signal edg_fsm2: std_logic;
signal edg_fsm3: std_logic;
signal edg_fsm4: std_logic;
signal edg_fsm5: std_logic;

COMPONENT RgbLed is 
PORT (
rstn_i : in std_logic;
clk_i : in std_logic;
btnl_i : in std_logic;
btnc_i : in std_logic;
btnr_i : in std_logic;
btnd_i : in std_logic;
btnu_i : in std_logic;
      
      -- LD16 PWM output signals LED RGB derecha
pwm1_red_o : out std_logic;
pwm1_green_o : out std_logic;
pwm1_blue_o : out std_logic;
      
      -- LD17 PWM output signals LED RGB izquierda
pwm2_red_o : out std_logic;
pwm2_green_o : out std_logic;
pwm2_blue_o : out std_logic;
      
       -- LED's para simbolizar estados
 stateLEDS : out std_logic_vector(4 downto 0)
);
END COMPONENT;


COMPONENT SYNCHRNZR
PORT ( 
CLK : in std_logic;
ASYNC_IN : in std_logic;
SYNC_OUT : out std_logic
);
END COMPONENT;


COMPONENT EDGEDTCTR
PORT ( 
CLK : in std_logic;
SYNC_IN : in std_logic;
EDGE : OUT std_logic
);
END COMPONENT;

begin

Inst_RgbLed : RgbLed PORT MAP (
rstn_i => reset,
clk_i => clk_i,
btnl_i => edg_fsm1,
btnc_i => edg_fsm2,
btnr_i => edg_fsm3,
btnd_i => edg_fsm4,
btnu_i => edg_fsm5,
pwm1_red_o => rgb1_red_o,
pwm1_green_o => rgb1_green_o,
pwm1_blue_o => rgb1_blue_o,
pwm2_red_o => rgb2_red_o,
pwm2_green_o => rgb2_green_o,
pwm2_blue_o => rgb2_blue_o,
stateLEDS => LED
);

Inst_SYNCHRNZR1 : SYNCHRNZR PORT MAP (
CLK => clk_i,
ASYNC_IN => btnl_i,
SYNC_OUT => syn_edge1
);

Ins_EDGEDTCTR1 : EDGEDTCTR PORT MAP (
CLK => clk_i,
SYNC_IN => syn_edge1,
EDGE => edg_fsm1
);

Inst_SYNCHRNZR2 : SYNCHRNZR PORT MAP (
CLK => clk_i,
ASYNC_IN => btnc_i,
SYNC_OUT => syn_edge2
);

Ins_EDGEDTCTR2 : EDGEDTCTR PORT MAP (
CLK => clk_i,
SYNC_IN => syn_edge2,
EDGE => edg_fsm2
);

Inst_SYNCHRNZR3 : SYNCHRNZR PORT MAP (
CLK => clk_i,
ASYNC_IN => btnr_i,
SYNC_OUT => syn_edge3
);

Ins_EDGEDTCTR3 : EDGEDTCTR PORT MAP (
CLK => clk_i,
SYNC_IN => syn_edge3,
EDGE => edg_fsm3
);

Inst_SYNCHRNZR4 : SYNCHRNZR PORT MAP (
CLK => clk_i,
ASYNC_IN => btnd_i,
SYNC_OUT => syn_edge4
);

Ins_EDGEDTCTR4 : EDGEDTCTR PORT MAP (
CLK => clk_i,
SYNC_IN => syn_edge4,
EDGE => edg_fsm4
);

Inst_SYNCHRNZR5 : SYNCHRNZR PORT MAP (
CLK => clk_i,
ASYNC_IN => btnu_i,
SYNC_OUT => syn_edge5
);

Ins_EDGEDTCTR5 : EDGEDTCTR PORT MAP (
CLK => clk_i,
SYNC_IN => syn_edge5,
EDGE => edg_fsm5
);


 end behavioral;



      
      
      
      