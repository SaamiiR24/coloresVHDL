library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity RgbLed is
   port(
      clk_i : in std_logic;
      rstn_i : in std_logic;
      
      -- Command button signals
      btnl_i : in std_logic;-- si se pula este boton modificamos RGB's rojo
      btnc_i : in std_logic;-- si se pulsa este boton  modificamosel RGB's verde
      btnr_i : in std_logic;-- si se pulsa este boton modificamosel RGB's azul
      btnd_i : in std_logic;-- apagan RGB's
      btnu_i : in std_logic; --boton para aumentar pwm
      -- LD16 PWM output signals LED RGB derecha
      pwm1_red_o : out std_logic;
      pwm1_green_o : out std_logic;
      pwm1_blue_o : out std_logic;
      
      -- LD17 PWM output signals LED RGB izquierda
      pwm2_red_o : out std_logic;
      pwm2_green_o : out std_logic;
      pwm2_blue_o : out std_logic;
      
       --LED's para simbolizar estados
      stateLEDS : out std_logic_vector(3 downto 0)
      
   );
end RgbLed;

architecture Behavioral of RgbLed is

-- Generador PWM
component Pwm is
port(
   clk_i : in std_logic;
   data_i : in std_logic_vector(7 downto 0);
   pwm_o : out std_logic);
end component;

-- Clock divider, determina la frecuencia en la que el color de los componentes aumenta/disminuye
-- 100MHz/10000000 = 10Hz. Es suficiente y diferente a la frecuencia de red (50Hz);

constant CLK_DIV : integer := 10000000;
signal clkCnt : integer := 0;
signal slowClk : std_logic;

-- colorCnt will determina los valores PWM que pasamos a los RGB 
signal colorCntred : std_logic_vector(4 downto 0) := "00000"; -- un contado por color, modificamos cada contador 
signal colorCntgreen : std_logic_vector(4 downto 0) := "00000"; -- en cada estado 
signal colorCntblue : std_logic_vector(4 downto 0) := "00000";


-- Red, Green and Blue data signals
signal red, green, blue : std_logic_vector(7 downto 0);
-- PWM Red, Green and BLue señales que van a los LEDS RGB 
signal pwm_red, pwm_green, pwm_blue : std_logic;


-- Signals que apagan LD16 y LD17 
signal fLed2Off, fLed1Off : std_logic;

-- Maquina de estados
type state_type is ( stInicio, -- Estado inicial todo apagado
                     stRed,   -- modificamos color Red solo
                     stGreen, -- modificamos color Green solo
                     stBlue,  -- modificamos color Blue solo
                     stLed12Off -- apagamos los dos LEDS
                     ); 
-- Señales maquina de estados
signal currentState, nextState : state_type;--NEXTSTATE Y CURRENTSTATE DE TODA LA VIDA

begin
   
   -- Asignamos salidas
   pwm1_red_o     <= pwm_red when fLed1Off = '0' else '0';
   pwm1_green_o   <= pwm_green when fLed1Off = '0' else '0';
   pwm1_blue_o    <= pwm_blue when fLed1Off = '0' else '0';
   
   pwm2_red_o     <= pwm_red when fLed2Off = '0' else '0';
   pwm2_green_o   <= pwm_green when fLed2Off = '0' else '0';
   pwm2_blue_o    <= pwm_blue when fLed2Off = '0' else '0';

-- PWM generadores:
   PwmRed: Pwm
   port map(
      clk_i    => clk_i,
      data_i   => red,
      pwm_o    => pwm_red);

   PwmGreen: Pwm
   port map(
      clk_i    => clk_i,
      data_i   => green,
      pwm_o    => pwm_green);
   
   PwmBlue: Pwm
   port map(
      clk_i    => clk_i,
      data_i   => blue,
      pwm_o    => pwm_blue);


  
   SYNC_PROC: process(clk_i)
   begin
      if rising_edge(clk_i) then
         if rstn_i = '0' then
            currentState <= stInicio;
         else
            currentState <= nextState;
         end if;        
      end if;
   end process;
   
   
   NEXT_STATE_DECODE: process(currentState, btnl_i, btnc_i, btnr_i, btnd_i)
   begin
      nextState <= currentState;  
      case currentState is
       when stInicio => -- Estado de inicio donde no pasa nada 
            if btnl_i = '1' then
               nextState <= stRed; -- si presionamos btnl pasamos a estado donde modificamos la intensidad del rojo
            elsif btnc_i = '1' then
               nextState <= stGreen; --si presionamos btnc pasamos a estado donde modificamos la intensidad del verde
            elsif btnr_i = '1' then
               nextState <= stBlue; --si presionamos btnr pasamos a estado donde modificamos la intensidad del azul
            elsif btnd_i = '1' then 
               nextState <= stLed12Off; --apagamos los leds
            end if;
            
         when stRed => --Estado donde modificamos brillo del rojo
            if btnc_i = '1' then
               nextState <= stGreen; --Pasamos a estado donde modificamos el verde
            elsif btnr_i = '1' then
               nextState <= stBlue;  --Pasamos a estado donde modifcamos el azul
            elsif btnd_i = '1' then
               nextState <= stInicio; -- Pasamos a inicio
            end if;
            
         when stGreen => --Estado donde modificamos el brillo del verde
            if btnl_i = '1' then
               nextState <= stRed; --Pasamos a estado donde modificamos el rojo
            elsif btnr_i = '1' then
               nextState <= stBlue; --Pasamos a estado donde modificamos el azul
            elsif btnd_i = '1' then
               nextState <= stInicio; --Pasamos a inicio
            end if;
            
         when stBlue => -- Estado donde modificamos el brillo del azul
            if btnl_i = '1' then
               nextState <= stRed; --Pasamos a estado donde modificamos el rojo
            elsif btnc_i = '1' then
               nextState <= stGreen; --Pasamos a estado donde modificamos el verde 
            elsif btnd_i = '1' then
               nextState <= stInicio; --Pasamos a inicio
            end if;
           
         when stLed12Off => -- Apagamos los dos leds
            if btnd_i = '1' then
               nextState <= stInicio;
            end if;
            
         when others => nextState <= stInicio;
   
      end case;      
   end process;
   
   -- clock prescaler
   Prescaller: process(clk_i)
   begin
      if rising_edge(clk_i) then
         if rstn_i = '0' then
            clkCnt <= 0;
         elsif clkCnt = CLK_DIV-1 then
            clkCnt <= 0;
         else
            clkCnt <= clkCnt + 1;
         end if;
      end if;
   end process Prescaller;
   
   slowClk <= '1' when clkCnt = CLK_DIV-1 else '0'; -- 10 Hz que buscamos 
   
   process(clk_i, btnu_i, colorCntgreen, colorCntblue, colorCntred)
   begin
      if rising_edge(clk_i) then
         if rstn_i = '0' then
            colorCntred <= b"00000"; --Contador rojo apagado
            colorCntgreen <= b"00000"; --Contador verde apagado
            colorCntblue <= b"00000"; --Contador azul apagado
         elsif slowClk = '1' then
           if btnu_i = '1' then --Si presionamos el boton btnu aumentamos el brillo
             if colorCntred = b"11111" OR colorCntgreen = b"11111" OR colorCntblue = b"11111" then 
             colorCntred <= b"11111"; -- En el caso que los contadores estén en  máximo se quedan tal cual
             colorCntblue <= b"11111"; -- Cuando funcione esto meto otro botón y toras condiciones para bajar el brillo
             colorCntgreen <= b"11111";  -- Los contadores empiezan a 0 por lo que no deberia haber problema
             else
               if currentState = stRed then  -- cada estado modifica su contador
               colorCntred <= colorCntred + b"00001"; -- se suma 1 (nivel de brillo) al contador cada vez que se pulse el boton
               elsif currentState = stGreen then 
                colorCntgreen <= colorCntgreen + b"00001";
               elsif currentState = stBlue then 
                colorCntblue <= colorCntblue + b"00001";
               end if;
              end if;
            end if;
          end if;
        end if;
       
   end process;
  
   process(currentState, colorCntred, colorCntgreen, colorCntblue)
   begin
  
   
   case currentState is 
      when stInicio => 
         stateLEDS(0) <= '1';
         stateLEDS(1) <= '0';
         stateLEDS(2) <= '0';
         stateLEDS(3) <= '0';
              
      when stRed =>
         red <= b"000" & colorCntred(4 downto 0);
        
         stateLEDS(0) <= '0';
         stateLEDS(1) <= '1';
         stateLEDS(2) <= '0';
         stateLEDS(3) <= '0';
       
         
      when stGreen =>
         green <=  b"000" & colorCntgreen(4 downto 0);
        
         stateLEDS(2) <= '1';
         stateLEDS(0) <= '0';
         stateLEDS(1) <= '0';
         stateLEDS(3) <= '0';
      
      when stBlue =>
         blue <= b"000" & colorCntblue(4 downto 0);
         
         stateLEDS(3) <= '1';
         stateLEDS(0) <= '0';
         stateLEDS(1) <= '0';
         stateLEDS(2) <= '0';
        
    
      when stLed12Off =>
         fLed2Off <= '1';
         fLed1Off <= '1';
         
      when others =>
        stateLEDS <= (OTHERS => '0');
        fLed2Off <= '0';
        fLed1Off <= '0';
  
       end case;
   end process;
  
end Behavioral;
