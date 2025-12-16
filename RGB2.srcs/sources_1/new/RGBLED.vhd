library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity RgbLed is
   port(
      clk_i : in std_logic;
      rstn_i : in std_logic;
      
      -- Command button signals
      btnl_i : in std_logic;-- si se pula este boton el led se pone rojo
      btnc_i : in std_logic;-- si se pulsa este boton el led se pone verde
      btnr_i : in std_logic;-- si se pulsa este botnon el led se pone azul
      btnd_i : in std_logic;-- si se pulsa este boton los led se quedan en degradado de colores y si se deja pulsado se apagan
      btnu_i : in std_logic; --boton para aumentar pwm
      -- LD16 PWM output signals LED RGB derecha
      pwm1_red_o : out std_logic;
      pwm1_green_o : out std_logic;
      pwm1_blue_o : out std_logic;
      
      -- LD17 PWM output signals LED RGB izquierda
      pwm2_red_o : out std_logic;
      pwm2_green_o : out std_logic;
      pwm2_blue_o : out std_logic;
      
       -- LED's para simbolizar estados
      stateLEDS : out std_logic_vector(3 downto 0)
      
   );
end RgbLed;

architecture Behavioral of RgbLed is

----------------------------------------------------------------------------------
-- Component Declarations
----------------------------------------------------------------------------------
-- Pwm generator
component Pwm is
port(
   clk_i : in std_logic;
   data_i : in std_logic_vector(7 downto 0);
   pwm_o : out std_logic);
end component;


-- Red, Green and Blue data signals
signal red, green, blue : std_logic_vector(7 downto 0);
-- PWM Red, Green and BLue signals going to the RGB Leds
signal pwm_red, pwm_green, pwm_blue : std_logic;


-- Signals that turn off LD16 and/or LD17 PARA APAGAR LOS LEDS
signal fLed2Off, fLed1Off : std_logic;

-- State machine states definition
type state_type is ( stInicio, -- Estado inicial todo apagado
                     stRed,   -- Show Red color only
                     stGreen, -- Show Green color only
                     stBlue,  -- Show Blue color only
                     stLed12Off -- Turn off both Leds
                     ); 
-- State machine signal definitions
signal currentState, nextState : state_type;--NEXTSTATE Y CURRENTSTATE DE TODA LA VIDA

-- Señales para aumentar el pwm de los RGB
signal posred: signed(7 downto 0) := "00000000";
signal posblue: signed(7 downto 0) := "00000000";
signal posgreen: signed(7 downto 0) := "00000000";
-- Al ser el pwm de 8 bits (max = 255 / min = 0) separaremos 19 posibilidades desde el 0 hasta el 247

begin
   
   -- Assign outputs
   pwm1_red_o     <= pwm_red when fLed1Off = '0' else '0';
   pwm1_green_o   <= pwm_green when fLed1Off = '0' else '0';
   pwm1_blue_o    <= pwm_blue when fLed1Off = '0' else '0';
   
   pwm2_red_o     <= pwm_red when fLed2Off = '0' else '0';
   pwm2_green_o   <= pwm_green when fLed2Off = '0' else '0';
   pwm2_blue_o    <= pwm_blue when fLed2Off = '0' else '0';

-- PWM generators:
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


   -- State machine registerred process
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
   
   -- Next State decode process
   NEXT_STATE_DECODE: process(currentState, btnl_i, btnc_i, btnr_i, btnd_i)
   begin
      nextState <= currentState;  -- SON EL NEXTSTATE Y CURRENTSTATE
      case currentState is
       when stInicio => -- primer estado en el que no pasa nada
            if btnl_i = '1' then
               nextState <= stRed;
            elsif btnc_i = '1' then
               nextState <= stGreen;
            elsif btnr_i = '1' then
               nextState <= stBlue;
            elsif btnd_i = '1' then 
               nextState <= stLed12Off;
            end if;
            
         when stRed => -- show red only
            if btnc_i = '1' then
               nextState <= stGreen;
            elsif btnr_i = '1' then
               nextState <= stBlue;
            elsif btnd_i = '1' then
               nextState <= stInicio;
            end if;
            
         when stGreen => -- show green only
            if btnl_i = '1' then
               nextState <= stRed;
            elsif btnr_i = '1' then
               nextState <= stBlue;
            elsif btnd_i = '1' then
               nextState <= stInicio;
            end if;
            
         when stBlue => -- show blue only
            if btnl_i = '1' then
               nextState <= stRed;
            elsif btnc_i = '1' then
               nextState <= stGreen;
            elsif btnd_i = '1' then
               nextState <= stInicio;
            end if;
           
         when stLed12Off => -- turn off both Ld16 and Ld17
            if btnd_i = '1' then
               nextState <= stInicio;
            end if;
            
         when others => nextState <= stInicio;
   
      end case;      
   end process;
   
      
   process(currentState, btnu_i)
   begin
  
   
   case currentState is 
      when stInicio => 
         stateLEDS(0) <= '1';
         stateLEDS(1) <= '0';
         stateLEDS(2) <= '0';
         stateLEDS(3) <= '0';
              
      when stRed =>
         if btnu_i = '1' and posred < 247 then-- cada vez que pulsamos el botón, el brillo aumenta 13
           posred <= posred + 13;
        end if;
         stateLEDS(0) <= '0';
         stateLEDS(1) <= '1';
         stateLEDS(2) <= '0';
         stateLEDS(3) <= '0';
       
         
      when stGreen =>
         if btnu_i = '1' and posgreen < 247 then 
           posgreen <= posgreen + 13;
         end if;
         stateLEDS(2) <= '1';
         stateLEDS(0) <= '0';
         stateLEDS(1) <= '0';
         stateLEDS(3) <= '0';
      
      when stBlue =>
         if btnu_i <= '1' and posblue < 247 then 
           posblue <= posblue + 13;
         end if;
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
   green <= std_logic_vector(posgreen);
   red <= std_logic_vector(posred);
   blue <= std_logic_vector(posblue);
   
end Behavioral;
