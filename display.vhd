----------------------------------------------------------------------------------------------------
--  Display Modul. 	Implementiert ein 2x16 Display welches seine Daten direkt aus dem Ram bekomment.
--					Sobald ein Byte geschrieben worden ist, wird dem Ram über lcd_ram_increase_read_address Signalisiert,
--					dass das Display neue Daten empfangen kann.
--					
--
--
--  Port:
--		lcd_clk_i               		: Basistakt
--		lcd_rst_i               		: asynchroner Reset, high-aktiv
--		lcd_on                  		: LCD Power ON/OFF 
--		lcd_blon                		: LCD Back Light ON/OFF
--		lcd_en                  		: LCD Enable
--		lcd_rs                  		: LCD Register Command/Data Select, 0 = Command, 1 = Data
--		lcd_rw                  		: LCD Read/Write Select, 0 = Write, 1 = Read
--		lcd_data_bus            		: LCD Daten Bus
--		lcd_ram_increase_read_address  	: Signalisiert, dass das Display neue Daten bekommen möchte
--		lcd_ram_data_i          		: Daten die aus dem Ram kommen und ans Display geschrieben werden sollen
--		
--		
--
--  Autor: Jan Ottmüller & Guillaume Fournier-Mayer
--  Datum: 19.06.2018
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Display is 
    port(
    lcd_clk_i               : in  std_logic;
    lcd_rst_i               : in  std_logic;
    lcd_on                  : out std_logic; --LCD Power ON/OFF 
    lcd_blon                : out std_logic; --LCD Back Light ON/OFF
    lcd_en                  : out std_logic; --LCD Enable
    lcd_rs                  : out std_logic; --LCD Register Command/Data Select, 0 = Command, 1 = Data
    lcd_rw                  : out std_logic; --LCD Read/Write Select, 0 = Write, 1 = Read
    lcd_data_bus            : out std_logic_vector(7 downto 0);
    lcd_ram_increase_read_address  : out std_logic;
    lcd_ram_data_i          : in std_logic_vector(7 downto 0)
    );
end entity Display;



architecture arch of Display is
    type state_type is (reset,  d1, reset2_5, d2, reset5, d3, functionSet, d4, displayOff, d5,
                            clearDisplay, d6, setMode, d7, displayOn, d8 ,printChars, waitState, switchColumn1, switchColumn2);--states for state maschine      
                            
    signal state, nextstate : state_type;
    signal PS2RamByte : std_logic_vector(7 downto 0);
    signal clk_display  : natural Range 0 to 65534; -- big enough to fot x"F424" with overflow margin
    signal clk_displayEnable : std_logic;
    signal row : bit := '0';
    signal column : natural range 0 to 16 := 0;
    
begin
    lcd_on <= '1';
    lcd_blon <= '1'; --display has no backlight but set anyway
    lcd_rw <= '0'; -- we only want to write to the display
-- display clock (400hz) period: 2.5ms  
displayClock : process(lcd_clk_i, clk_displayEnable, lcd_rst_i)
begin
        if (lcd_rst_i = '1') then
            clk_display <= 0;
            clk_displayEnable <= '0';
        elsif (rising_edge(lcd_clk_i)) then
            if (clk_display <= 62500) then             
                   clk_display <= clk_display + 1; 
                   clk_displayEnable <= '0';                
            else -- reset cycle counter and set clk_displayEnable on for one cycle
                   clk_display <= 0;
                   clk_displayEnable <= '1';
            end if;
         end if;
end process; 
--=======================================   
-- display state maschine
--=======================================
store : process(lcd_clk_i, lcd_rst_i, nextstate, clk_displayEnable) begin
    if (lcd_rst_i = '1') then
        state <= reset;
        row <= '0';
        column <= 0;
        lcd_ram_increase_read_address <= '0';
    elsif (rising_edge(lcd_clk_i) and clk_displayEnable ='1')then
        case state is           
            when waitState => 
                if(column /= 16) then
                lcd_ram_increase_read_address <= '1';
                end if;
            when printChars => 
                column <= column + 1;
                lcd_ram_increase_read_address <= '0';
            when switchColumn1 =>                     
                column <= 0;
                row <= '0';
            when switchColumn2 =>             
                column <= 0;
                row <= '1';
            when others => NULL;
        end case;
        
        state <= nextstate;
     end if;
end process store;

transition : process(lcd_clk_i, state, clk_displayEnable, column, row) begin
    case state is
        when reset => nextstate <= d1;
        when d1 => nextstate <= reset2_5;
        when reset2_5 => nextstate <= d2;
        when d2 => nextstate <= reset5;
        when reset5 => nextstate <= d3;
        when d3 => nextstate <= functionSet;
        when functionSet => nextstate <= d4;
        when d4 => nextstate <= displayOff;
        when displayOff => nextstate <= d5;
        when d5 => nextstate <= clearDisplay;
        when clearDisplay => nextstate <= d6;
        when d6 => nextstate <= setMode;
        when setMode => nextstate <= d7;
        when d7 => nextstate <= displayOn;
        when displayOn => nextstate <= d8;
        when d8 => nextstate <= switchColumn2;
        when printChars => nextstate <= waitState;       
        when waitState =>  if(column = 16) then
                        if row = '0' then 
                            nextstate <= switchColumn2;
                        else
                            nextstate <= switchColumn1;
                        end if;
                    else
                        nextstate <= printChars;
                    end if;
        when switchColumn1 => nextstate <= waitState;
        when switchColumn2 => nextstate <= waitState;         
        end case;
   
end process transition;

output : process(lcd_clk_i, state, clk_displayEnable, lcd_ram_data_i) begin
    --if(rising_edge(lcd_clk_i) and clk_displayEnable = '1') then 
        lcd_data_bus <= "00000000";
        case state is
            when reset => 
                lcd_en <= '1';  
                lcd_rs <= '0';
                lcd_data_bus <= "00110000"; --Function set
            when reset2_5 => 
                lcd_en <= '1';  
                lcd_rs <= '0';
                lcd_data_bus <= "00110000"; --Function set
            when reset5 => 
                lcd_en <= '1';  
                lcd_rs <= '0';
                lcd_data_bus <= "00110000"; --Function set
            when functionSet => 
                lcd_en <= '1';  
                lcd_rs <= '0';
                lcd_data_bus <= "00111000"; --Function set
            when displayOff =>
                lcd_en <= '1';  
                lcd_rs <= '0';
                lcd_data_bus <= "00001000"; --Display off
            when clearDisplay => 
                lcd_en <= '1';  
                lcd_rs <= '0';
                lcd_data_bus <= "00000001"; --Clear Display
            when setMode => 
                lcd_en <= '1';  
                lcd_rs <= '0';
                lcd_data_bus <= "00000110"; --Entry mode set move cursor to the right
            when displayOn =>
                lcd_en <= '1';  
                lcd_rs <= '0';
                lcd_data_bus <= "00001111"; --Set Display on Cursor on, Blinking off
            when printChars =>
                lcd_en <= '1'; 
                lcd_rs <= '1';
                lcd_data_bus <= lcd_ram_data_i;
            when waitState =>
                lcd_en <= '0';
                lcd_rs <= '0';
            when switchColumn1 => 
                lcd_en <= '1';  
                lcd_rs <= '0';                
                lcd_data_bus <= "11000000"; --set row 2    
            when switchColumn2 => 
                lcd_en <= '1';  
                lcd_rs <= '0';
                lcd_data_bus <= "10000000"; --set row 1
            when others => lcd_en <= '0'; lcd_rs <= '0'; 
        end case;
    --end if;
end process output;
--end display state maschine

end architecture arch;