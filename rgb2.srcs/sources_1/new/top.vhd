library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_signed.all;

entity TOP is
  port (
    CLK_I        : in    std_logic;
    RESET        : in    std_logic;

    BTNL_I       : in    std_logic;
    BTNC_I       : in    std_logic;
    BTNR_I       : in    std_logic;
    BTND_I       : in    std_logic;
    BTNU_I       : in    std_logic;
    LED          : out   std_logic_vector(0 to 3);
    RGB1_RED_O   : out   std_logic;
    RGB1_GREEN_O : out   std_logic;
    RGB1_BLUE_O  : out   std_logic;
    RGB2_RED_O   : out   std_logic;
    RGB2_GREEN_O : out   std_logic;
    RGB2_BLUE_O  : out   std_logic
  );
end entity TOP;

architecture BEHAVIORAL of TOP is

  signal syn_edge1 : std_logic;
  signal syn_edge2 : std_logic;
  signal syn_edge3 : std_logic;
  signal syn_edge4 : std_logic;
  signal syn_edge5 : std_logic;
  signal edg_fsm1  : std_logic;
  signal edg_fsm2  : std_logic;
  signal edg_fsm3  : std_logic;
  signal edg_fsm4  : std_logic;
  signal edg_fsm5  : std_logic;

  component RGB_LED is
    port (
      RSTN_I       : in    std_logic;
      CLK_I        : in    std_logic;
      BTNL_I       : in    std_logic;
      BTNC_I       : in    std_logic;
      BTNR_I       : in    std_logic;
      BTND_I       : in    std_logic;
      BTNU_I       : in    std_logic;

      -- LD16 PWM output signals LED RGB derecha
      PWM1_RED_O   : out   std_logic;
      PWM1_GREEN_O : out   std_logic;
      PWM1_BLUE_O  : out   std_logic;

      -- LD17 PWM output signals LED RGB izquierda
      PWM2_RED_O   : out   std_logic;
      PWM2_GREEN_O : out   std_logic;
      PWM2_BLUE_O  : out   std_logic;

      -- LED's para simbolizar estados
      STATELEDS    : out   std_logic_vector(3 downto 0)
    );
  end component RGB_LED;

  component SYNCHRONIZER is
    port (
      CLK      : in    std_logic;
      ASYNC_IN : in    std_logic;
      SYNC_OUT : out   std_logic
    );
  end component SYNCHRONIZER;

  component EDGE_DETECTOR is
    port (
      CLK     : in    std_logic;
      SYNC_IN : in    std_logic;
      EDGE    : out   std_logic
    );
  end component EDGE_DETECTOR;

begin

  INST_RGBLED : RGB_LED
    port map (
      RSTN_I       => RESET,
      CLK_I        => CLK_I,
      BTNL_I       => edg_fsm1,
      BTNC_I       => edg_fsm2,
      BTNR_I       => edg_fsm3,
      BTND_I       => edg_fsm4,
      BTNU_I       => edg_fsm5,
      PWM1_RED_O   => RGB1_RED_O,
      PWM1_GREEN_O => RGB1_GREEN_O,
      PWM1_BLUE_O  => RGB1_BLUE_O,
      PWM2_RED_O   => RGB2_RED_O,
      PWM2_GREEN_O => RGB2_GREEN_O,
      PWM2_BLUE_O  => RGB2_BLUE_O,
      STATELEDS    => LED
    );

  INST_SYNCHRNZR1 : SYNCHRONIZER
    port map (
      CLK      => CLK_I,
      ASYNC_IN => BTNL_I,
      SYNC_OUT => syn_edge1
    );

  INST_SYNCHRNZR2 : SYNCHRONIZER
    port map (
      CLK      => CLK_I,
      ASYNC_IN => BTNC_I,
      SYNC_OUT => syn_edge2
    );

  INST_SYNCHRNZR3 : SYNCHRONIZER
    port map (
      CLK      => CLK_I,
      ASYNC_IN => BTNR_I,
      SYNC_OUT => syn_edge3
    );

  INST_SYNCHRNZR4 : SYNCHRONIZER
    port map (
      CLK      => CLK_I,
      ASYNC_IN => BTND_I,
      SYNC_OUT => syn_edge4
    );

  INST_SYNCHRNZR5 : SYNCHRONIZER
    port map (
      CLK      => CLK_I,
      ASYNC_IN => BTNU_I,
      SYNC_OUT => syn_edge5
    );

  INS_EDGEDTCTR1 : EDGE_DETECTOR
    port map (
      CLK     => CLK_I,
      SYNC_IN => syn_edge1,
      EDGE    => edg_fsm1
    );

  INS_EDGEDTCTR2 : EDGE_DETECTOR
    port map (
      CLK     => CLK_I,
      SYNC_IN => syn_edge2,
      EDGE    => edg_fsm2
    );

  INS_EDGEDTCTR3 : EDGE_DETECTOR
    port map (
      CLK     => CLK_I,
      SYNC_IN => syn_edge3,
      EDGE    => edg_fsm3
    );

  INS_EDGEDTCTR4 : EDGE_DETECTOR
    port map (
      CLK     => CLK_I,
      SYNC_IN => syn_edge4,
      EDGE    => edg_fsm4
    );

  INS_EDGEDTCTR5 : EDGE_DETECTOR
    port map (
      CLK     => CLK_I,
      SYNC_IN => syn_edge5,
      EDGE    => edg_fsm5
    );

end architecture BEHAVIORAL;







