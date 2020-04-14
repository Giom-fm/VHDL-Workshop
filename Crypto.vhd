----------------------------------------------------------------------------------------------------
--  Crypto Modul. Implementiert übersetzung des Scancodes in ASCII und die Ver- und Entschlüsselung 
--
--
--  Port:
--		crypto_key_i        : Der verschlüsselungs code
--		crypto_encoder_i    : Die zu verschlüsselnden Daten
--		crypto_encoder_o    : Die verschlüsselten Daten
--		crypto_decoder_i    : Die zu entschlüsselden Daten
--		crypto_decoder_o    : Die entschlüsselten Daten
--		
--
--  Autor: Jan Ottmüller & Guillaume Fournier-Mayer
--  Datum: 19.08.2018
----------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;




entity Crypto is 
    port (
        crypto_key_i        : in std_logic_vector(7 downto 0);
        crypto_encoder_i    : in std_logic_vector(7 downto 0);
        crypto_encoder_o    : out std_logic_vector(7 downto 0);
        crypto_decoder_i    : in std_logic_vector(7 downto 0);
        crypto_decoder_o    : out std_logic_vector(7 downto 0)
    );
end entity Crypto;


architecture arch of Crypto is 

begin

encode : process(crypto_encoder_i, crypto_key_i)
    variable ascii : std_logic_vector(7 downto 0);
 begin
    case crypto_encoder_i is  
        when x"45" => ascii := x"30"; --0
        when x"16" => ascii := x"31"; --1
        when x"1E" => ascii := x"32"; --2
        when x"26" => ascii := x"33"; --3
        when x"25" => ascii := x"34"; --4
        when x"2E" => ascii := x"35"; --5
        when x"36" => ascii := x"36"; --6
        when x"3D" => ascii := x"37"; --7
        when x"3E" => ascii := x"38"; --8
        when x"46" => ascii := x"39"; --9
        when x"29" => ascii := x"20"; -- SPACEBAR
        when x"1C" => ascii := x"61"; --a
        when x"32" => ascii := x"62"; --b
        when x"21" => ascii := x"63"; --c
        when x"23" => ascii := x"64"; --d
        when x"24" => ascii := x"65"; --e
        when x"2B" => ascii := x"66"; --f
        when x"34" => ascii := x"67"; --g
        when x"33" => ascii := x"68"; --h
        when x"43" => ascii := x"69"; --i
        when x"3B" => ascii := x"6A"; --j
        when x"42" => ascii := x"6B"; --k
        when x"4B" => ascii := x"6C"; --l
        when x"3A" => ascii := x"6D"; --m
        when x"31" => ascii := x"6E"; --n
        when x"44" => ascii := x"6F"; --o
        when x"4D" => ascii := x"70"; --p
        when x"15" => ascii := x"71"; --q
        when x"2D" => ascii := x"72"; --r
        when x"1B" => ascii := x"73"; --s
        when x"2C" => ascii := x"74"; --t
        when x"3C" => ascii := x"75"; --u
        when x"2A" => ascii := x"76"; --v
        when x"1D" => ascii := x"77"; --w
        when x"22" => ascii := x"78"; --x
        when x"35" => ascii := x"79"; --y
        when x"1A" => ascii := x"7A"; --z
        when others => ascii := x"3f"; --?
    end case; 
    crypto_encoder_o <= ascii xor crypto_key_i;
end process encode;


decode : process(crypto_decoder_i, crypto_key_i) begin
    crypto_decoder_o <= crypto_decoder_i xor crypto_key_i;
end process decode;


end architecture arch;