library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RgbLed is
   port(
      clk_i : in std_logic;
      rstn_i : in std_logic;
      btnl_i, btnc_i, btnr_i, btnd_i, btnu_i : in std_logic; -- Vienen limpios del TOP
      pwm1_red_o, pwm1_green_o, pwm1_blue_o : out std_logic;
      pwm2_red_o, pwm2_green_o, pwm2_blue_o : out std_logic;
      stateLEDS : out std_logic_vector(4 downto 0)
   );
end RgbLed;

 architecture Behavioral of RgbLed is
   
   component Pwm is
    port(
      clk_i, rstn_i : in std_logic;
      data_i : in std_logic_vector(7 downto 0);
      pwm_o : out std_logic);
   end component;

   -- Counter actualizado a pulsos
   component Counter is
    port(
      clk_i, rstn_i : in std_logic;
      pulse_up, pulse_down : in std_logic;
      colorcnt : out std_logic_vector(7 downto 0));
   end component;

   component Prescaller is
    port(
      clk_i, rstn_i : in std_logic;
      slowClk : out std_logic);
   end component;

   -- Nuevo componente Detector de Flancos muy importante
   component EDGEDTCTR is
    port (
      clk_i, rstn_i, slowclk_i, sig_i : in std_logic;
      edge_o : out std_logic);
   end component;

   type state_type is (stInicio, stRed, stGreen, stBlue, stLed12Off);
   signal currentState, nextState : state_type;
   signal cnttotal : std_logic_vector(7 downto 0);
   signal redstay, greenstay, bluestay : std_logic_vector(7 downto 0);
   signal red_reg, green_reg, blue_reg : std_logic_vector(7 downto 0) := (others => '0');
   signal slowclk_out, pwm_r, pwm_g, pwm_b : std_logic;

   -- Señales internas para los pulsos 
   signal p_btnl, p_btnc, p_btnr, p_btnd, p_btnu : std_logic;

begin
   
   -- Generador de 10 Hz
   Pres: Prescaller port map(clk_i => clk_i, rstn_i => rstn_i, slowClk => slowclk_out);

   -- Detectores de Flanco
   -- Convierten la señal continua del boton en un solo pulso sincronizado con 10Hz
   Edge_L: EDGEDTCTR port map(clk_i, rstn_i, slowclk_out, btnl_i, p_btnl);
   Edge_C: EDGEDTCTR port map(clk_i, rstn_i, slowclk_out, btnc_i, p_btnc);
   Edge_R: EDGEDTCTR port map(clk_i, rstn_i, slowclk_out, btnr_i, p_btnr);
   Edge_D: EDGEDTCTR port map(clk_i, rstn_i, slowclk_out, btnd_i, p_btnd);
   Edge_U: EDGEDTCTR port map(clk_i, rstn_i, slowclk_out, btnu_i, p_btnu);

   -- Contador 
   Cnt: Counter port map(
       clk_i => clk_i, 
       rstn_i => rstn_i, 
       pulse_up => p_btnu, 
       pulse_down => p_btnd, 
       colorcnt => cnttotal
   );

   --  PWMs 
   PwmRed:   Pwm port map(clk_i, rstn_i, red_reg, pwm_r);
   PwmGreen: Pwm port map(clk_i, rstn_i, green_reg, pwm_g);
   PwmBlue:  Pwm port map(clk_i, rstn_i, blue_reg, pwm_b);

   -- Proceso Sincrono de Estado
   process(clk_i)
   begin
      if rising_edge(clk_i) then
         if rstn_i = '0' then
            currentState <= stLed12Off;
         else
            -- Ya no hace falta "if slowclk..." aquí, porque los pulsos
            -- ya vienen filtrados por el EDGEDTCTR que usa de por si el slowclk
            currentState <= nextState;
         end if;        
      end if;
   end process;
   
   -- Logica de proximo estado (Ahora usa los PULSOS sin necesidad de checkear relojes)
   process(currentState, p_btnr, p_btnl, p_btnc)
   begin
      nextState <= currentState;
      case currentState is
         when stInicio =>
            if p_btnr = '1' then nextState <= stRed;
            elsif p_btnl = '1' then nextState <= stBlue;
            elsif p_btnc = '1' then nextState <= stLed12Off;
            end if;
         when stRed =>
            if p_btnr = '1' then nextState <= stGreen;
            elsif p_btnl = '1' then nextState <= stInicio;
            elsif p_btnc = '1' then nextState <= stLed12Off;
            end if;
         when stGreen =>
            if p_btnr = '1' then nextState <= stBlue;
            elsif p_btnl = '1' then nextState <= stRed;
            elsif p_btnc = '1' then nextState <= stLed12Off;
            end if;
         when stBlue =>
            if p_btnr = '1' then nextState <= stInicio;
            elsif p_btnl = '1' then nextState <= stGreen;
            elsif p_btnc = '1' then nextState <= stLed12Off;
            end if;
         when stLed12Off =>
            if p_btnr = '1' or p_btnl = '1' then nextState <= stInicio;
            end if;
         when others => nextState <= stLed12Off;
      end case;
   end process;

   -- Asignacion de brillos 
   process(clk_i)
   begin
      if rising_edge(clk_i) then
         case currentState is 
            when stRed =>
               red_reg <= cnttotal;
               redstay <= red_reg;
               stateLEDS <= "01000";
               green_reg <= (others => '0');
               blue_reg <= (others => '0');
            when stGreen =>
               green_reg <= cnttotal;
               greenstay <= green_reg;
               stateLEDS <= "00100";
               red_reg <= (others => '0');
               blue_reg <= (others => '0');
            when stBlue =>
               blue_reg <= cnttotal;
               bluestay <= blue_reg;
               stateLEDS <= "00010";
               red_reg <= (others => '0');
               green_reg <= (others => '0');
            when stLed12Off =>
               red_reg <= (others => '0'); green_reg <= (others => '0'); blue_reg <= (others => '0');
               greenstay <= (others => '0'); redstay <= (others => '0'); bluestay <= (others => '0');
               stateLEDS <= "00001";
            when stInicio =>
               blue_reg <= bluestay;
               red_reg <= redstay;
               green_reg <= greenstay;
               stateLEDS <= "10000";
            when others =>
               red_reg <= (others => '0'); green_reg <= (others => '0'); blue_reg <= (others => '0');
               stateLEDS <= "00000"; 
         end case;
      end if;
   end process;

   pwm1_red_o <= pwm_r; pwm1_green_o <= pwm_g; pwm1_blue_o <= pwm_b;
   pwm2_red_o <= pwm_r; pwm2_green_o <= pwm_g; pwm2_blue_o <= pwm_b;
   
end Behavioral;