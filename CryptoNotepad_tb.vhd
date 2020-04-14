library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity CryptoNotepad_tb is
end entity CryptoNotepad_tb ;


architecture arch of CryptoNotepad_tb is
signal rst_i, clk_i, ps2_clk_io, ps2_dat_io,lcd_on , lcd_blon, lcd_en, lcd_rs, lcd_rw : std_logic := '0';
signal display_data_bits, crypto_key : std_logic_vector(7 downto 0) := "00000000";


signal test_package_1 : std_logic_vector(0 to 10) := "0H0H0HH0H0H";
signal test_package_2 : std_logic_vector(0 to 10) := "0H00HHH0H0H";
signal test_package_3 : std_logic_vector(0 to 10) := "0H0H0000H0H";
signal test_package_4 : std_logic_vector(0 to 10) := "00HH0HH0H0H";
signal test_package_break : std_logic_vector(0 to 10) := "00000HHHHHH";


begin
    ps2_clk_io <= 'H';
    ps2_dat_io <= 'H';

    sysClock : process begin
        clk_i <= not clk_i;
        wait for 10 ns;
    end process;


    ps2Clock : process begin
        ps2_clk_io <= 'Z';
        wait for 50 us;
        ps2_clk_io <= '0';
        wait for 50 us;
    end process ps2Clock;
        
   process begin
   
        rst_i <= '1';
        wait for 20 ns;
        rst_i <= '0';
        
        wait for 20 ms;
        package1 : FOR i IN 0 TO 10 LOOP
            ps2_dat_io <= test_package_1(i);
            wait for 55 us;
            wait for 45 us;
        end loop package1;
        report "package 1 sent" Severity note;
        
        package2 : FOR i IN 0 TO 10 LOOP
            ps2_dat_io <= test_package_break(i);
            wait for 55 us;
            wait for 45 us;
        end loop package2;
        report "package break sent" Severity note;
        
        package3 : FOR i IN 0 TO 10 LOOP -- package 1 nach break noch einmal senden 
            ps2_dat_io <= test_package_1(i);
            wait for 55 us;
            wait for 45 us;
        end loop package3;
        
         FOR i IN 0 TO 10 LOOP  -- das ganze noch einmal
            ps2_dat_io <= test_package_1(i);
            wait for 55 us;
            wait for 45 us;
        end loop ;
        report "package 1 sent" Severity note;
         FOR i IN 0 TO 10 LOOP
            ps2_dat_io <= test_package_break(i);
            wait for 55 us;
            wait for 45 us;
        end loop ;
        report "package break sent" Severity note;
         FOR i IN 0 TO 10 LOOP
            ps2_dat_io <= test_package_1(i);
            wait for 55 us;
            wait for 45 us;
        end loop ;

        wait for 15 ms;
        crypto_key <= "00000011"; -- verschlüsselung ändern
        
        wait;
    end process;
    
    
dut : entity work.CryptoNotepad(arch) port map(
        crypto_key => crypto_key,
        rst_i       =>rst_i,
        clk_i        => clk_i,
        ps2_clk_io   => ps2_clk_io,
        ps2_dat_io   => ps2_dat_io,
        display_data_bits      => display_data_bits,
        lcd_on =>lcd_on, 
        lcd_blon =>lcd_blon, 
        lcd_en =>lcd_en, 
        lcd_rs =>lcd_rs, 
        lcd_rw  =>lcd_rw
    );

end architecture arch;

