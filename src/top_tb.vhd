library IEEE;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.rgb2_common.all;
  use work.test_utils.all;

entity TOP_TB is
end entity TOP_TB;

architecture TESTBENCH of TOP_TB is

  constant simclk_freq   : positive := 5 * sysclk_freq;
  constant simclk_period : time     := 1 sec / simclk_freq;

  component TOP is
    generic (
      CLKIN_FREQ : positive
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
  end component TOP;

  signal clk_i         : std_logic;
  signal rstn_i        : std_logic;
  signal btnl_i        : std_logic;
  signal btnc_i        : std_logic;
  signal btnr_i        : std_logic;
  signal btnd_i        : std_logic;
  signal btnu_i        : std_logic;
  signal led           : std_logic_vector(0 to 2);
  signal rgb1_red_o    : std_logic;
  signal rgb1_green_o  : std_logic;
  signal rgb1_blue_o   : std_logic;
  signal rgb2_red_o    : std_logic;
  signal rgb2_green_o  : std_logic;
  signal rgb2_blue_o   : std_logic;

begin

  UUT : TOP
    generic map (
      CLKIN_FREQ => SIMCLK_FREQ
    )
    port map (
      CLK_I        => clk_i,
      RSTN_I       => rstn_i,
      BTNL_I       => btnl_i,
      BTNC_I       => btnc_i,
      BTNR_I       => btnr_i,
      BTND_I       => btnd_i,
      BTNU_I       => btnu_i,
      LED          => led,
      RGB1_RED_O   => rgb1_red_o,
      RGB1_GREEN_O => rgb1_green_o,
      RGB1_BLUE_O  => rgb1_blue_o,
      RGB2_RED_O   => rgb2_red_o,
      RGB2_GREEN_O => rgb2_green_o,
      RGB2_BLUE_O  => rgb2_blue_o
    );

  generate_clock(clk_i, simclk_period);  -- Board clock generator

  TEST_P : process is
  begin

    -- Give initial value to inputs
    wait_n_edges(clk_i);
    rstn_i <= '1';
    btnl_i <= '0';
    btnc_i <= '0';
    btnr_i <= '0';
    btnd_i <= '0';
    btnu_i <= '0';
    wait_n_edges(clk_i, 25);

    -- Reset puse
    generate_pulse(rstn_i, 103 ms, 57 ms, '0');

    -- Enter programming mode
    generate_pulse(btnc_i, 109 ms, 53 ms);

    -- Increment red component
    for i in 1 to 10 loop

      generate_pulse(btnu_i, 109 ms, 53 ms);

    end loop;

    -- Increment blue component
    generate_pulse(btnr_i, 109 ms, 53 ms);
    generate_pulse(btnr_i, 99 ms, 49 ms);

    for i in 1 to 15 loop

      generate_pulse(btnu_i, 109 ms, 53 ms);

    end loop;

    -- Increment green component
    generate_pulse(btnr_i, 109 ms, 53 ms);
    generate_pulse(btnr_i, 99 ms, 49 ms);

    for i in 1 to 5 loop

      generate_pulse(btnu_i, 109 ms, 53 ms);

    end loop;

    -- Lock settings
    generate_pulse(btnc_i, 99 ms, 49 ms);

    -- Switch off
    generate_pulse(btnd_i, 109 ms, 53 ms);

    -- Switch on
    generate_pulse(btnu_i, 109 ms, 53 ms);

    wait_n_edges(clk_i, 15_000);

    assert false
      report "[PASSED]: end of simulation."
      severity failure;

  end process TEST_P;

end architecture TESTBENCH;
