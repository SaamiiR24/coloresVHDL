library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_signed.all;

entity RGB_LED is
  port (
    CLK_I        : in    std_logic;
    RSTN_I       : in    std_logic;

    -- Command button signals
    BTNL_I       : in    std_logic; -- si se pula este boton modificamos RGB's rojo
    BTNC_I       : in    std_logic; -- si se pulsa este boton  modificamosel RGB's verde
    BTNR_I       : in    std_logic; -- si se pulsa este boton modificamosel RGB's azul
    BTND_I       : in    std_logic; -- apagan RGB's
    BTNU_I       : in    std_logic; -- boton para aumentar pwm
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
end entity RGB_LED;

architecture BEHAVIORAL of RGB_LED is

  -- Generador PWM
  component PWM is
    port (
      CLK_I  : in    std_logic;
      DATA_I : in    std_logic_vector(7 downto 0);
      PWM_O  : out   std_logic
    );
  end component PWM;

  -- Clock divider, determina la frecuencia en la que el color de los componentes aumenta/disminuye
  -- 100MHz/10000000 = 10Hz. Es suficiente y diferente a la frecuencia de red (50Hz);

  constant clk_div               : integer := 10000000;
  signal   clkcnt                : integer := 0;
  signal   slowclk               : std_logic;

  -- colorCnt will determina los valores PWM que pasamos a los RGB
  signal colorcntred             : std_logic_vector(4 downto 0) := "00000"; -- un contado por color, modificamos cada contador
  signal colorcntgreen           : std_logic_vector(4 downto 0) := "00000"; -- en cada estado
  signal colorcntblue            : std_logic_vector(4 downto 0) := "00000";

  -- Red, Green and Blue data signals
  signal red                     : std_logic_vector(7 downto 0);
  signal green                   : std_logic_vector(7 downto 0);
  signal blue                    : std_logic_vector(7 downto 0);
  -- PWM Red, Green and BLue señales que van a los LEDS RGB
  signal pwm_red                 : std_logic;
  signal pwm_green               : std_logic;
  signal pwm_blue                : std_logic;

  -- Signals que apagan LD16 y LD17
  signal fled2off,     fled1off  : std_logic;

  -- Maquina de estados

  type state_type is (
    STINICIO,                                                               -- Estado inicial todo apagado
    STRED,                                                                  -- modificamos color Red solo
    STGREEN,                                                                -- modificamos color Green solo
    STBLUE,                                                                 -- modificamos color Blue solo
    STLED12OFF                                                              -- apagamos los dos LEDS
  );

  -- Señales maquina de estados
  signal currentstate, nextstate : state_type;                              -- NEXTSTATE Y CURRENTSTATE DE TODA LA VIDA

begin

  -- Asignamos salidas
  PWM1_RED_O   <= pwm_red when fled1off = '0' else
                  '0';
  PWM1_GREEN_O <= pwm_green when fled1off = '0' else
                  '0';
  PWM1_BLUE_O  <= pwm_blue when fled1off = '0' else
                  '0';

  PWM2_RED_O   <= pwm_red when fled2off = '0' else
                  '0';
  PWM2_GREEN_O <= pwm_green when fled2off = '0' else
                  '0';
  PWM2_BLUE_O  <= pwm_blue when fled2off = '0' else
                  '0';

  -- PWM generadores:
  PWMRED : PWM
    port map (
      CLK_I  => CLK_I,
      DATA_I => red,
      PWM_O  => pwm_red
    );

  PWMGREEN : PWM
    port map (
      CLK_I  => CLK_I,
      DATA_I => green,
      PWM_O  => pwm_green
    );

  PWMBLUE : PWM
    port map (
      CLK_I  => CLK_I,
      DATA_I => blue,
      PWM_O  => pwm_blue
    );

  SYNC_PROC : process (CLK_I) is
  begin

    if rising_edge(CLK_I) then
      if (RSTN_I = '0') then
        currentstate <= STINICIO;
      else
        currentstate <= nextstate;
      end if;
    end if;

  end process SYNC_PROC;

  NEXT_STATE_DECODE : process (currentstate, BTNL_I, BTNC_I, BTNR_I, BTND_I) is
  begin

    nextstate <= currentstate;

    case currentstate is

      when STINICIO =>             -- Estado de inicio donde no pasa nada

        if (BTNL_I = '1') then
          nextstate <= STRED;      -- si presionamos btnl pasamos a estado donde modificamos la intensidad del rojo
        elsif (BTNC_I = '1') then
          nextstate <= STGREEN;    -- si presionamos btnc pasamos a estado donde modificamos la intensidad del verde
        elsif (BTNR_I = '1') then
          nextstate <= STBLUE;     -- si presionamos btnr pasamos a estado donde modificamos la intensidad del azul
        elsif (BTND_I = '1') then
          nextstate <= STLED12OFF; -- apagamos los leds
        end if;

      when STRED =>                -- Estado donde modificamos brillo del rojo

        if (BTNC_I = '1') then
          nextstate <= STGREEN;    -- Pasamos a estado donde modificamos el verde
        elsif (BTNR_I = '1') then
          nextstate <= STBLUE;     -- Pasamos a estado donde modifcamos el azul
        elsif (BTND_I = '1') then
          nextstate <= STINICIO;   -- Pasamos a inicio
        end if;

      when STGREEN =>              -- Estado donde modificamos el brillo del verde

        if (BTNL_I = '1') then
          nextstate <= STRED;      -- Pasamos a estado donde modificamos el rojo
        elsif (BTNR_I = '1') then
          nextstate <= STBLUE;     -- Pasamos a estado donde modificamos el azul
        elsif (BTND_I = '1') then
          nextstate <= STINICIO;   -- Pasamos a inicio
        end if;

      when STBLUE =>               -- Estado donde modificamos el brillo del azul

        if (BTNL_I = '1') then
          nextstate <= STRED;      -- Pasamos a estado donde modificamos el rojo
        elsif (BTNC_I = '1') then
          nextstate <= STGREEN;    -- Pasamos a estado donde modificamos el verde
        elsif (BTND_I = '1') then
          nextstate <= STINICIO;   -- Pasamos a inicio
        end if;

      when STLED12OFF =>           -- Apagamos los dos leds

        if (BTND_I = '1') then
          nextstate <= STINICIO;
        end if;

      when others =>

        nextstate <= STINICIO;

    end case;

  end process NEXT_STATE_DECODE;

  -- clock prescaler
  PRESCALLER : process (CLK_I) is
  begin

    if rising_edge(CLK_I) then
      if (RSTN_I = '0') then
        clkcnt <= 0;
      elsif (clkcnt = clk_div - 1) then
        clkcnt <= 0;
      else
        clkcnt <= clkcnt + 1;
      end if;
    end if;

  end process PRESCALLER;

  slowclk <= '1' when clkcnt = clk_div - 1 else
             '0'; -- 10 Hz que buscamos

  process (CLK_I, BTNU_I, colorcntgreen, colorcntblue, colorcntred) is
  begin

    if rising_edge(CLK_I) then
      if (RSTN_I = '0') then
        colorcntred   <= b"00000";                                                                -- Contador rojo apagado
        colorcntgreen <= b"00000";                                                                -- Contador verde apagado
        colorcntblue  <= b"00000";                                                                -- Contador azul apagado
      elsif (slowclk = '1') then
        if (BTNU_I = '1') then                                                                    -- Si presionamos el boton btnu aumentamos el brillo
          if (colorcntred = b"11111" or colorcntgreen = b"11111" or colorcntblue = b"11111") then
            colorcntred   <= b"11111";                                                            -- En el caso que los contadores estén en  máximo se quedan tal cual
            colorcntblue  <= b"11111";                                                            -- Cuando funcione esto meto otro botón y toras condiciones para bajar el brillo
            colorcntgreen <= b"11111";                                                            -- Los contadores empiezan a 0 por lo que no deberia haber problema
          else
            if (currentstate = STRED) then                                                        -- cada estado modifica su contador
              colorcntred <= colorcntred + b"00001";                                              -- se suma 1 (nivel de brillo) al contador cada vez que se pulse el boton
            elsif (currentstate = STGREEN) then
              colorcntgreen <= colorcntgreen + b"00001";
            elsif (currentstate = STBLUE) then
              colorcntblue <= colorcntblue + b"00001";
            end if;
          end if;
        end if;
      end if;
    end if;

  end process;

  process (currentstate, colorcntred, colorcntgreen, colorcntblue) is
  begin

    case currentstate is

      when STINICIO =>

        STATELEDS(0) <= '1';
        STATELEDS(1) <= '0';
        STATELEDS(2) <= '0';
        STATELEDS(3) <= '0';

      when STRED =>

        red <= b"000" & colorcntred(4 downto 0);

        STATELEDS(0) <= '0';
        STATELEDS(1) <= '1';
        STATELEDS(2) <= '0';
        STATELEDS(3) <= '0';

      when STGREEN =>

        green <= b"000" & colorcntgreen(4 downto 0);

        STATELEDS(2) <= '1';
        STATELEDS(0) <= '0';
        STATELEDS(1) <= '0';
        STATELEDS(3) <= '0';

      when STBLUE =>

        blue <= b"000" & colorcntblue(4 downto 0);

        STATELEDS(3) <= '1';
        STATELEDS(0) <= '0';
        STATELEDS(1) <= '0';
        STATELEDS(2) <= '0';

      when STLED12OFF =>

        fled2off <= '1';
        fled1off <= '1';

      when others =>

        STATELEDS <= (others => '0');
        fled2off  <= '0';
        fled1off  <= '0';

    end case;

  end process;

end architecture BEHAVIORAL;
