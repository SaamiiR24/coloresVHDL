library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.rgb2_common.all;

-- Initial state: mode 1, leds off
-- MODE 1: channel duties locked, UP: on, DOWN: off, CENTER: mode 2
-- MODE 2: leds on, LEFT/RIGHT: ->R<->G<->B<-, UP/DOWN: channel duty +/-, CENTER: mode 1
--                              |___________|

entity RGB_LED is
  port (
    CLK_I      : in    std_logic;                     -- Rising edge system clock
    RSTN_I     : in    std_logic;                     -- Synchronous low level active reset
    KEYPAD_I   : in    keypad_t;                      -- Command button signals
    RGB_PWM1_O : out   rgbled_t;                      -- LD16 PWM output signals LED RGB derecha
    RGB_PWM2_O : out   rgbled_t;                      -- LD17 PWM output signals LED RGB izquierda
    STATELEDS  : out   std_logic_vector(0 to 2)       -- LED's para simbolizar estados
  );
end entity RGB_LED;

architecture BEHAVIORAL of RGB_LED is

  -- PWM generator signals
  signal rgb_duties               : rgb_duty_vector_t;
  signal common_counter           : rgb_duty_t;
  signal rgb_pwm                  : rgbled_t;

  -- Maquina de estados
  -- State types

  type state_type is (
    ST_OFF,                                      -- Initial state, LEDs switched-off and duties locked
    ST_ON,                                       -- RGB LEDs switched-on and duties locked
    ST_ADJUST                                    -- RGB LEDs switched-on and duties unocked
  );

  -- State variables
  signal cur_state,   nxt_state   : state_type;  -- on/off & locked/unlocked state
  signal cur_channel, nxt_channel : chan_id_t;   -- Channel selected for modification

begin

  RGB_PWM1_O <= rgb_pwm;
  RGB_PWM2_O <= rgb_pwm;

  PWMS : for i in rgb_pwm'range generate
    rgb_pwm(i) <= '1' when (cur_state /= ST_OFF) and (common_counter < rgb_duties(i)) else
                  '0';

    DUTY_REGS_P : process (CLK_I) is
    begin

      if rising_edge(CLK_I) then
        if (RSTN_I = '0') then
          rgb_duties(i) <= (others => '0');
        elsif ((cur_state = ST_ADJUST) and (i = cur_channel)) then
          if (KEYPAD_I(UP_KEY) = '1') then
            rgb_duties(i) <= rgb_duties(i) + 1;
          elsif (KEYPAD_I(DOWN_KEY) = '1') then
            rgb_duties(i) <= rgb_duties(i) - 1;
          end if;
        end if;
      end if;

    end process DUTY_REGS_P;

  end generate PWMS;

  CMN_CNTR_P : process (CLK_I) is
  begin

    if rising_edge(CLK_I) then
      if (RSTN_I = '0') then
        common_counter <= (others => '0');
      else
        common_counter <= common_counter + 1;
      end if;
    end if;

  end process CMN_CNTR_P;

  STATE_REG_P : process (CLK_I) is
  begin

    if rising_edge(CLK_I) then
      if (RSTN_I = '0') then
        cur_state   <= ST_OFF;
        cur_channel <= chan_id_t'left;
      else
        cur_state   <= nxt_state;
        cur_channel <= nxt_channel;
      end if;
    end if;

  end process STATE_REG_P;

  with cur_state select STATELEDS <=
    "001" when ST_OFF,
    "010" when ST_ON,
    "100" when ST_ADJUST,
    "000" when others;

  NXT_STATE_DCDR_P : process (cur_state, cur_channel, KEYPAD_I) is
  begin

    nxt_state   <= cur_state;
    nxt_channel <= cur_channel;

    case cur_state is

      when ST_OFF =>

        if (KEYPAD_I(CENTER_KEY) = '1') then
          nxt_state <= ST_ADJUST;
        elsif (KEYPAD_I(UP_KEY) = '1') then
          nxt_state <= ST_ON;
        end if;

      when ST_ON =>

        if (KEYPAD_I(CENTER_KEY) = '1') then
          nxt_state <= ST_ADJUST;
        elsif (KEYPAD_I(DOWN_KEY) = '1') then
          nxt_state <= ST_OFF;
        end if;

      when ST_ADJUST =>

        if (KEYPAD_I(CENTER_KEY) = '1') then
          nxt_state <= ST_ON;
        elsif (KEYPAD_I(LEFT_KEY) = '1') then
          if (cur_channel /= chan_id_t'left) then
            nxt_channel <= chan_id_t'leftof(cur_channel);
          else
            nxt_channel <= chan_id_t'right;
          end if;
        elsif (KEYPAD_I(RIGHT_KEY) = '1') then
          if (cur_channel /= chan_id_t'right) then
            nxt_channel <= chan_id_t'rightof(cur_channel);
          else
            nxt_channel <= chan_id_t'left;
          end if;
        end if;

      when others =>

        nxt_state   <= ST_OFF;
        nxt_channel <= chan_id_t'left;

    end case;

  end process NXT_STATE_DCDR_P;

end architecture BEHAVIORAL;
