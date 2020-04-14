----------------------------------------------------------------------------------------------------
--	CryptoNotepad Modul. Implementiert die komplette Funktionalität des Projektes. 
--	
-- 	Die Funktionalität ist der Doku zu entnehmen.
--			
--  Port:
--		rst_i               : asynchroner Reset, high-aktiv
--		clk_i               : Basistakt
--		ps2_clk_io          : Takt des Ps2-Slave
--		ps2_dat_io          : Daten des Ps2-Slave
--		display_data_bits   : Datenbus zum Display
--		lcd_on				: On/Off zum Display
--		lcd_blon 			: Hintergrundbeleuchtung zum Display
--		lcd_en 				: Enable flag für das Display
--		lcd_rs				: Registerselect fürs Display
--		lcd_rw 				: Read/write fürs Display
--		crypto_key          : Cryptokey der über die Schalter eingestellt wird             
--		
--
--  Autor: Jan Ottmüller & Guillaume Fournier-Mayer
--  Datum: 19.08.2018
----------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CryptoNotepad is
    port (
        rst_i               : in std_logic;
        clk_i               : in std_logic;
        ps2_clk_io          : inout std_logic;
        ps2_dat_io          : inout std_logic;
        display_data_bits   : out std_logic_vector(7 downto 0);

        lcd_on				: out std_logic;
		lcd_blon 			: out std_logic;
		lcd_en 				: out std_logic;
		lcd_rs				: out std_logic;
		lcd_rw 				: out std_logic;
        crypto_key          : in std_logic_vector(7 downto 0)        
    );
end entity CryptoNotepad;

architecture arch of CryptoNotepad is

    --=========================================================================
    --Keyboard
    signal keyboard_scancode_o          : std_logic_vector(7 downto 0);
    signal keyboard_new_scancode_o        : std_logic;
    --=========================================================================
    --RAM
    signal ram_increase_read_address    : std_logic;
    --signal ram_increase_write_address   : std_logic;
    signal ram_data_o                   : std_logic_vector(7 downto 0);
    --=========================================================================
    --Crypto
    signal crypto_decoder_o         : std_logic_vector(7 downto 0) := "00000000";   
    signal crypto_encoder_o         : std_logic_vector(7 downto 0) := "00000000";   
     --=========================================================================
begin




  
Ram :entity work.Ramaccess(arch)
    port map(
    ramAccess_rst_i                     =>  rst_i,
    ramAccess_clk_i                     =>  clk_i,
    ramaccess_increase_read_address     =>  ram_increase_read_address,         
    ramaccess_increase_write_address    =>  keyboard_new_scancode_o,
    ramaccess_data_i                    =>  crypto_encoder_o,
    ramaccess_data_o                    =>  ram_data_o
    );
  
 
Display : entity work.Display(arch) 
    port map(
        lcd_clk_i               =>  clk_i,
        lcd_rst_i               =>  rst_i,
        lcd_on                  =>  lcd_on,        
        lcd_blon                =>  lcd_blon,
        lcd_en                  =>  lcd_en,
        lcd_rs                  =>  lcd_rs,
        lcd_rw                  =>  lcd_rw,
        lcd_data_bus            =>  display_data_bits,
        lcd_ram_data_i          =>  crypto_decoder_o,
        lcd_ram_increase_read_address => ram_increase_read_address
    );
    
    
    Crypto : entity work.Crypto(arch) 
    port map(
        crypto_key_i        => crypto_key,
        crypto_encoder_i    => keyboard_scancode_o,
        crypto_encoder_o    => crypto_encoder_o,
        crypto_decoder_i    => ram_data_o,
        crypto_decoder_o    => crypto_decoder_o
    );
    
    
    Keyboard : entity work.Keyboard(arch)
    port map(
    keyboard_clk_i          => clk_i,
    keyboard_rst_i          => rst_i,
    keyboard_ps2_clk_i      => ps2_clk_io,
    keyboard_ps2_data_i     => ps2_dat_io,
    keyboard_scancode_o     => keyboard_scancode_o,
    keyboard_new_scancode_o => keyboard_new_scancode_o
    );
  
end architecture arch;













