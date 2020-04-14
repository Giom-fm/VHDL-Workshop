----------------------------------------------------------------------------------------------------
--	Keyboard Modul. 	Bindet den Transceiver ein und Implementiert PS" Keyboard Funktionen.
--			
--	Die Empfangenen Daten des Transceivers werden verarbeitet und ausgewertet.
--	Wird ein Zeichen geschrieben, so wird dieser Scancode weitergegeben. 
--	Wenn NUMLOCK oder CAPSLOCK oder SCROLLLOCK gedrückt wird, wird die entsprechende
--	Befehlsfolge ausgeführt um die LEDs der Tastatur einzuschalten.
--
--  Port:
--  keyboard_clk_i              : Basistakt
--  keyboard_rst_i              : Asynchroner Reset
--  keyboard_ps2_clk_i          : PS2 Clockleitung
--  keyboard_ps2_data_i         : PS2 Datenleitung
--  keyboard_scancode_o         : Signalisiert, dass ein neues Zeichen gelesen wurde
--  keyboard_new_scancode_o     : out std_logic
--		
--
--  Autor: Jan Ottmüller & Guillaume Fournier-Mayer
--  Datum: 18.09.2018
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity Keyboard is port (
    keyboard_clk_i              : in std_logic;
    keyboard_rst_i              : in std_logic;
    keyboard_ps2_clk_i          : inout std_logic;
    keyboard_ps2_data_i         : inout std_logic;
    keyboard_scancode_o         : out std_logic_vector( 7 downto 0);
    keyboard_new_scancode_o     : out std_logic
);
 end entity Keyboard;
    
 
 architecture arch of Keyboard is 
    --=========================================================================
    --Transmitter
    signal transmitter_data_i                   : std_logic_vector(7 downto 0);
    signal transmitter_send_i                   : std_logic := '0';
    --=========================================================================
    --Receiver
    signal receiver_data_o                      : std_logic_vector(7 downto 0);
    signal receiver_new_data_o                  : std_logic := '0';
    signal receiver_data_read_i                 : std_logic := '0';
    --=========================================================================
    type stateType is (reset, break, code, hold);
    signal state, nextState : stateType := reset;
    signal ledStatus : std_logic_vector(2 downto 0) := "000";
    --=========================================================================    
begin

store : process(keyboard_clk_i, keyboard_rst_i) begin
    if(keyboard_rst_i = '1')then
        state <= reset;
    elsif(rising_edge(keyboard_clk_i)) then
        state <= nextState;
    end if;
end process store;

transout : process(keyboard_clk_i, keyboard_rst_i) begin
    if(keyboard_rst_i = '1')then
        receiver_data_read_i <= '0';
        ledStatus <= "000";
        keyboard_new_scancode_o <= '0';
        keyboard_scancode_o <= "00000000";
        transmitter_send_i <= '0'; 
        transmitter_data_i <= "00000000";
    elsif(rising_edge(keyboard_clk_i)) then
       transmitter_send_i <= '0';
        case (state) is
            when reset =>
                receiver_data_read_i <= '0';
                nextState <= code;
                ledStatus <= "000";
            when break =>
                receiver_data_read_i <= '0';
                if(receiver_new_data_o = '1' ) then
                    receiver_data_read_i <= '1';
                    nextState <= code;
                end if;
            when code =>
                receiver_data_read_i <= '0';
                if(receiver_new_data_o = '1' and nextState /= hold) then
                    if(receiver_data_o = "10101010" ) then
                        nextState <= reset;   
                    elsif(receiver_data_o = "11110000") then
                        nextState <= break;
                    elsif(receiver_data_o = "01110111" or receiver_data_o = "0HHH0HHH") then --NUMLOCK H for testing 
                        transmitter_data_i <= "11101101"; --ED  Setzen der Status-LEDs       
                        transmitter_send_i <= '1';
                        ledStatus <= ledStatus(2) & not ledStatus(1) & ledStatus(0);
                        nextState <= hold;
                    elsif(receiver_data_o = "01011000") then --CAPSLOCK
                        transmitter_data_i <= "11101101"; --ED  Setzen der Status-LEDs       
                        transmitter_send_i <= '1';
                        ledStatus <= not ledStatus(2) & ledStatus(1) & ledStatus(0);
                        nextState <= hold;
                    elsif(receiver_data_o = "01111110") then --SCROLLLOCK   
                        transmitter_data_i <= "11101101"; --ED  Setzen der Status-LEDs       
                        transmitter_send_i <= '1';
                        ledStatus <= ledStatus(2) & ledStatus(1) & not ledStatus(0);
                        nextState <= hold;
                    elsif(receiver_data_o = "11111010" or receiver_data_o = "HHHHH0H0") then --ACK
                        transmitter_data_i <= "00000" & ledStatus;
                        transmitter_send_i <= '1';
                        nextState <= break;
                    else
                        keyboard_new_scancode_o <= '1'; 
                        keyboard_scancode_o <= receiver_data_o;
                        nextState <= hold;
                    end if;
                    receiver_data_read_i <= '1';
                end if;
            when hold => 
                keyboard_new_scancode_o <= '0';
                receiver_data_read_i <= '0';
                nextState <= code;
        end case;
      
    end if;
    
end process transout;


 Transceiver :entity work.Transceiver(arch)
    port map(
        transceiver_rst_i       => keyboard_rst_i,      
        transceiver_clk_i       => keyboard_clk_i,      
        
        transceiver_data_i      => transmitter_data_i,  
        transceiver_send_i      => transmitter_send_i,
        transceiver_busy_send_o => open,
        transceiver_err_send_o  => open,

        transceiver_busy_rec_o  => open,
        transceiver_data_o      => receiver_data_o,
        transceiver_new_data_o  => receiver_new_data_o,
        transceiver_err_rec_o   => open,
        transceiver_data_read_i => receiver_data_read_i,
        
        transceiver_ps2_clk_io  => keyboard_ps2_clk_i,
        transceiver_ps2_dat_io  => keyboard_ps2_data_i
    );
 
 
 end architecture arch;