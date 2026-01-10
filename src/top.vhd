library ieee;
  use ieee.std_logic_1164.all;
  use work.rgb2_common.all;

entity TOP is
  generic (
    CLKIN_FREQ : positive := 100_000_000
  );
  port (
    CLK_I         : in    std_logic;
    RSTN_I        : in    std_logic;
    BTNL_I        : in    std_logic;
    BTNC_I        : in    std_logic;
    BTNR_I        : in    std_logic;
    BTND_I        : in    std_logic;
    BTNU_I        : in    std_logic;
    LED           : out   std_logic_vector(0 to 2);
    RGB1_RED_O    : out   std_logic;
    RGB1_GREEN_O  : out   std_logic;
    RGB1_BLUE_O   : out   std_logic;
    RGB2_RED_O    : out   std_logic;
    RGB2_GREEN_O  : out   std_logic;
    RGB2_BLUE_O   : out   std_logic
  );
end entity TOP;

architecture BEHAVIORAL of TOP is

  signal sys_clk       : std_logic;

  signal rstn_sync     : std_logic;

  signal btn_asyncs    : keypad_t;
  signal btn_edges     : keypad_t;

  signal rgb_1         : rgbled_t;
  signal rgb_2         : rgbled_t;

begin

  btn_asyncs                              <= (BTNL_I, BTNC_I, BTNR_I, BTND_I, BTNU_I);
  (RGB1_RED_O, RGB1_GREEN_O, RGB1_BLUE_O) <= rgb_1;
  (RGB2_RED_O, RGB2_GREEN_O, RGB2_BLUE_O) <= rgb_2;

  PRESCALER0 : FDIVIDER
    generic map (
      CLKIN_FREQ  => CLKIN_FREQ,
      CLKOUT_FREQ => sysclk_freq

    )
    port map (
      CLK_IN  => CLK_I,
      CLK_OUT => sys_clk
    );

  SYNC_RSTN : SYNCHRONIZER
    generic map (
      QUIESCENT_VALUE => '1'
    )
    port map (
      CLK      => sys_clk,
      ASYNC_IN => RSTN_I,
      SYNC_OUT => rstn_sync
    );

  SYNC_BTNS : for i in btn_asyncs'range generate
    signal synced : std_logic;
  begin

    SYNCHRNZR_I : SYNCHRONIZER
      port map (
        CLK      => sys_clk,
        ASYNC_IN => btn_asyncs(i),
        SYNC_OUT => synced
      );

    EDGEDTCTR_I : EDGE_DETECTOR
      port map (
        CLK  => sys_clk,
        DIN  => synced,
        EDGE => btn_edges(i)
      );

  end generate SYNC_BTNS;

  INST_RGBLED : RGB_LED
    port map (
      RSTN_I     => rstn_sync,
      CLK_I      => sys_clk,
      KEYPAD_I   => btn_edges,
      RGB_PWM1_O => rgb_1,
      RGB_PWM2_O => rgb_2,
      STATELEDS  => LED
    );

end architecture BEHAVIORAL;
