library IEEE;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package rgb2_common is

  constant led_freq    : positive := 120;                       -- LED PWM frequency
  constant pwm_resol   : positive := 8;                         -- PWM bits
  constant sysclk_freq : positive := led_freq * 2 ** pwm_resol; -- System clock frequency

  type key_id_t is (LEFT_KEY, CENTER_KEY, RIGHT_KEY, DOWN_KEY, UP_KEY);

  type keypad_t is array(key_id_t) of std_logic;

  type chan_id_t is (RED_CH, GREEN_CH, BLUE_CH);

  type rgbled_t is array(chan_id_t) of std_logic;

  subtype rgb_duty_t is unsigned(7 downto 0);

  type rgb_duty_vector_t is array(chan_id_t) of rgb_duty_t;

  component FDIVIDER is
    generic (
      CLKIN_FREQ  : positive;
      CLKOUT_FREQ : positive
    );
    port (
      CLK_IN  : in    std_logic;
      CLK_OUT : out   std_logic
    );
  end component FDIVIDER;

  component SYNCHRONIZER is
    generic (
      QUIESCENT_VALUE : std_logic := '0';
      SYNC_STAGES     : positive := 2
    );
    port (
      CLK      : in    std_logic;
      ASYNC_IN : in    std_logic;
      SYNC_OUT : out   std_logic
    );
  end component SYNCHRONIZER;

  component EDGE_DETECTOR is
    generic (
      QUIESCENT_VALUE : std_logic := '0'
    );
    port (
      CLK     : in    std_logic;
      DIN     : in    std_logic;
      EDGE    : out   std_logic
    );
  end component EDGE_DETECTOR;

  component PWM is
    port (
      CLK_I    : in    std_logic;
      RSTN_I   : in    std_logic;
      DATA_I   : in    std_logic_vector(7 downto 0);
      PWM_O    : out   std_logic
    );
  end component PWM;

  component RGB_LED is
    port (
      CLK_I        : in    std_logic;
      RSTN_I       : in    std_logic;
      KEYPAD_I     : in    keypad_t;
      RGB_PWM1_O   : out   rgbled_t;
      RGB_PWM2_O   : out   rgbled_t;
      STATELEDS    : out   std_logic_vector(0 to 2)
    );
  end component RGB_LED;

end package rgb2_common;

package body rgb2_common is

end package body rgb2_common;
