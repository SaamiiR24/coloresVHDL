library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity RgbLed is
   port(
      clk_i : in std_logic; -- reloj de la placa 100MHz
      rstn_i : in std_logic; -- reset de la placa
      
      -- Botones-- l,c,r para movernos por los estados, d,u para modificar el brillo.
      btnl_i : in std_logic;
      btnc_i : in std_logic;
      btnr_i : in std_logic;
      btnd_i : in std_logic;
      btnu_i : in std_logic; 
      
      -- LD16 PWM LED RGB derecha / determinan el brillo de los leds de la derecha
      pwm1_red_o : out std_logic;
      pwm1_green_o : out std_logic;
      pwm1_blue_o : out std_logic;
      
      -- LD17 PWM LED RGB izquierda / determinan el brillo de los leds de la izquierda
      pwm2_red_o : out std_logic;
      pwm2_green_o : out std_logic;
      pwm2_blue_o : out std_logic;
      
       --LED's para simbolizar el estado en el que estemos 
      stateLEDS : out std_logic_vector(4 downto 0)
      
   );
end RgbLed;

 architecture Behavioral of RgbLed is

-- Generador PWM
component Pwm is
port(
   clk_i : in std_logic; -- reloj de la placa 100MHz
   rstn_i : in std_logic; -- reset placa
   data_i : in std_logic_vector(7 downto 0); -- vector de entrada correspondiente al duty cycle que queremos
   pwm_o : out std_logic); -- PWM salida
end component;

component Counter is
port(
  clk_i: in std_logic; -- reloj de la placa 100MHz
  rstn_i: in std_logic; -- reset de la placa
  btnup: in std_logic; -- boton para aumentar contador / brillo
  btndown: in std_logic; -- boton para disminuir contador / brillo
  colorcnt: out std_logic_vector(7 downto 0)); -- sirve para aumentar y disminuir el duty cycle
  end component;

component Prescaller is
port( 
  clk_i : in std_logic; -- reloj placa
  rstn_i : in std_logic; -- reset placa
  slowClk : out std_logic); -- salida que sirve para modificar el reloj de entrada
  end component;

-- Señales para modificar el duty cycle de cada led
signal colorcntred : std_logic_vector(7 downto 0) := "00000000"; -- un contado por color, modificamos cada contador en su propio estado
signal colorcntgreen : std_logic_vector(7 downto 0) := "00000000"; 
signal colorcntblue : std_logic_vector(7 downto 0) := "00000000";
signal colorcnttotal : std_logic_vector(7 downto 0) := "00000000";

signal slowclk_out: std_logic;

-- señales que usamos para modificar el dutycycle de cada color.
signal red, green, blue : std_logic_vector(7 downto 0);

-- señales para simbolizar la salida pwm de cada color.
signal pwm_red, pwm_green, pwm_blue : std_logic;


-- Señales que apagan los leds RGB LD16 y LD17 
signal fLed2Off, fLed1Off : std_logic;

-- Maquina de estados
type state_type is ( stInicio, -- Estado inicial aqui vamos a ver los colores, no podemos modificar nada 
                     stRed,   -- modificamos color Red solo
                     stGreen, -- modificamos color Green solo
                     stBlue,  -- modificamos color Blue solo
                     stLed12Off -- apagamos los dos LEDS y reseteamos duty cycle de todos los leds
                     ); 
-- Señales maquina de estados
signal currentState, nextState : state_type;

begin
   
    Pres: Prescaller
    port map(
     clk_i => clk_i,
     rstn_i => rstn_i,
     slowClk => slowclk_out);
   
   Cnt: Counter
   port map(
    clk_i => clk_i,
    rstn_i => rstn_i,
    btnup => btnu_i,
    btndown => btnd_i,
    colorcnt => Colorcnttotal );

-- PWM generadores:
   PwmRed: Pwm
   port map(
      clk_i => clk_i,
      rstn_i => rstn_i,
      data_i => red,
      pwm_o => pwm_red);

   PwmGreen: Pwm
   port map(
      clk_i => clk_i,
      rstn_i => rstn_i,
      data_i => green,
      pwm_o => pwm_green);
   
   PwmBlue: Pwm
   port map(
      clk_i => clk_i,
      rstn_i => rstn_i,
      data_i => blue,
      pwm_o => pwm_blue); 
    
   SYNC_PROC: process(slowclk_out)
   begin
      if rising_edge(slowclk_out) then
         if rstn_i = '0' then
            currentState <= stInicio;
         else
            currentState <= nextState;
         end if;        
      end if;
   end process;
   
   
   NEXT_STATE_DECODE: process(currentState, btnl_i, btnc_i, btnr_i)
   begin
      nextState <= currentState;  
      case currentState is
       when stInicio => -- Estado de inicio 
            if btnr_i = '1' then
               nextState <= stRed; -- si presionamos btnr pasamos a estado "rojo"
            elsif btnl_i = '1' then
               nextState <= stBlue; --si presionamos btnl pasamos a estado "azul"
            elsif btnc_i = '1' then 
              nextState <= stLed12Off; -- apagamos leds
            end if;
            
         when stRed => --Estado donde modificamos unicamente el brillo del rojo
            if btnr_i = '1' then
               nextState <= stGreen; -- si presionamos btnr pasamos a estado "verde"
            elsif btnl_i = '1' then
               nextState <= stInicio;  -- si presionamos btnl pasamos a estado "inicio"
            elsif btnc_i = '1' then 
              nextState <= stLed12Off;
            end if;
            
         when stGreen => --Estado donde modificamos unicamente el brillo del verde
            if btnr_i = '1' then
               nextState <= stBlue; -- si presionamos btnr pasamos a estado "azul"
            elsif btnl_i = '1' then
               nextState <= stRed; -- si presionamos btnl pasamos a estado "rojo"
            elsif btnc_i = '1' then 
              nextState <= stLed12Off;
            end if;
            
         when stBlue => -- Estado donde modificamos unicamente el brillo del azul
            if btnr_i = '1' then
               nextState <= stInicio; -- si presionamos btnr pasamos a estado "inicio"
            elsif btnl_i = '1' then
               nextState <= stGreen; -- -- si presionamos btnl pasamos a estado "verde"
            elsif btnc_i = '1' then 
              nextState <= stLed12Off;
            end if;
           
         when stLed12Off => -- Apagamos los dos leds, solo podemos volver a Inicio
            if btnr_i = '1' then
               nextState <= stInicio; -- si presionamos btnr pasamos a estado "Inicio"
            elsif btnl_i ='1' then 
              nextState <= stInicio; -- si presionamos btnl pasamos a estado "Inicio"
            end if;
            
         when others => nextState <= stInicio; -- En cualquier otro caso volvemos a inicio
   
      end case;      
   end process;
   
  CONTEO_BRILLO: process(currentState)
  begin
  case currentState is 
    when stRed =>
    colorcntred <= colorcnttotal; -- modificamos el contador del rojo
    colorcntgreen <= colorcntgreen; -- el contador vede sigue tal cual
    colorcntblue <= colorcntblue; -- el contador azul sigue tal cual 
    
    when stGreen =>
    colorcntgreen <= colorcnttotal; -- modificamos el contador del verde
    colorcntred <= colorcntred;  -- el contador del rojo sigue tal cual
    colorcntblue <= colorcntblue;  -- el contador del azul sigue tal cual
    
    when stBlue =>
    colorcntblue <= colorcnttotal; -- modificamos el contador del azul
    colorcntred <= colorcntred; -- el contador del rojo sigue tal cual
    colorcntgreen <= colorcntgreen; -- el contador del verde sigue tal cual
    
    when stLed12Off =>
    colorcntred <= (OTHERS => '0'); -- reseteamos contador rojo
    colorcntgreen <= (OTHERS => '0'); --reseteamos contador verde
    colorcntblue <= (OTHERS => '0');  -- reseteamos contador azul
    
    when others =>
    colorcntred <= colorcntred;
    colorcntgreen <= colorcntgreen;
    colorcntblue <= colorcntblue;
  
  end case;
  end process;
  
 
  LEDS: process(currentState)
   begin
   case currentState is 
      when stInicio => 
         stateLEDS(0) <= '0';
         stateLEDS(1) <= '0';
         stateLEDS(2) <= '0';
         stateLEDS(3) <= '0';
         stateLEDS(4) <= '1';  
         
      when stRed =>
         red <= colorCntred;  -- asignamos a la señal red el valor del contador rojo
         stateLEDS(0) <= '0';
         stateLEDS(1) <= '0';
         stateLEDS(2) <= '0';
         stateLEDS(3) <= '1';
         stateLEDS(4) <= '0';
       
      when stGreen =>
         green <=  colorCntgreen;  -- asignamos a la señal green el valor del contador verde
         stateLEDS(0) <= '0';
         stateLEDS(1) <= '0';
         stateLEDS(2) <= '1';
         stateLEDS(3) <= '0';
         stateLEDS(4) <= '0';
      
      when stBlue =>
         blue <= colorCntblue;  --asignamos a la señal blue el valor del contador azul 
         stateLEDS(0) <= '0';
         stateLEDS(1) <= '1';
         stateLEDS(2) <= '0';
         stateLEDS(3) <= '0';
         stateLEDS(4) <= '0';
        
      when stLed12Off =>
         fLed2Off <= '1';
         fLed1Off <= '1';
         stateLEDS(0) <= '1';
         stateLEDS(1) <= '0';
         stateLEDS(2) <= '0';
         stateLEDS(3) <= '0';
         stateLEDS(4) <= '0';
         
      when others =>
        stateLEDS <= (OTHERS => '0');
        fLed2Off <= '0';
        fLed1Off <= '0';
  
       end case;
   end process;
   
   -- Asignamos salidas
   pwm1_red_o     <= pwm_red when fLed1Off = '0' else '0';
   pwm1_green_o   <= pwm_green when fLed1Off = '0' else '0';
   pwm1_blue_o    <= pwm_blue when fLed1Off = '0' else '0';
   
   pwm2_red_o     <= pwm_red when fLed2Off = '0' else '0';
   pwm2_green_o   <= pwm_green when fLed2Off = '0' else '0';
   pwm2_blue_o    <= pwm_blue when fLed2Off = '0' else '0';
   
end Behavioral;
