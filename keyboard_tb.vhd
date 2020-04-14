library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Keyboard_tb is 
end entity; 


architecture arch of keyboard_tb is


signal rst_i, clk_i, ps2_clk_io, ps2_dat_io: std_logic := '0';
signal display_data_bits, crypto_key : std_logic_vector(7 downto 0) := "00000000";

signal test_package_numlock : std_logic_vector(0 to 10) := "0HHH0HHH0HH"; --numlock
signal test_package_ack : std_logic_vector(0 to 10)     := "00H0HHHHHHH"; --ack


begin   
    ps2_clk_io <= 'H';
    ps2_dat_io <= 'H';

    --Genereire Systemclock 50Mhz
    sysClock : process begin
        wait for 10 ns;
        clk_i <= not clk_i;
    end process sysClock;
    
    process begin
    --Reset
    rst_i <= '1';
    wait for 20 ns;
    rst_i <= '0';
    
        --Simuliere Numlock Tastendruck
        report "Sende NUMLOCK" Severity note;
        package1 : FOR i IN 0 TO 10 LOOP
            ps2_clk_io <= 'Z';
            wait for 20 ns;
            ps2_dat_io <= test_package_numlock(i);
            wait for 50 us;
            ps2_clk_io <= '0';
            wait for 50 us;
        end loop package1;
        
      
        --Ziehe Clock dauerhaft auf High
        ps2_clk_io <= 'Z';
        wait for 2 ms;
        
        --Simuliere genrierten Takt von der Tastatur für ED Paket
        report "Sende ED Paket" Severity note;
        FOR i IN 0 TO 8 loop
            ps2_clk_io <= '0';
            wait for 50 us;
            ps2_clk_io <= 'Z';
            wait for 50 us;
        end loop;
        --Sonderbehandlung ACK Bit von Tastatur nach erfolgreich übertragengen Packet
        ps2_clk_io <= '0';
        wait for 50 us;
        ps2_clk_io <= 'Z';
        wait for 25 us;
        ps2_dat_io <= '0';
        wait for 25 us;
        ps2_clk_io <= '0';
        wait for 50 us;
        ps2_clk_io <= 'Z';
        wait for 25 us;
        ps2_dat_io <= 'Z';
        wait for 1 ms;
        
        --Simuliere ACK Packet von Tastatur
        report "Sende ACK" Severity note;
        FOR i IN 0 TO 10 LOOP
            ps2_clk_io <= 'Z';
            wait for 20 ns;
            ps2_dat_io <= test_package_ack(i);
            wait for 50 us;
            ps2_clk_io <= '0';
            wait for 50 us;
        end loop;
        wait for 2 ms;
        
        
        --Simuliere genrierten Takt von der Tastatur für LED Packet
        report "Sende LED Paket" Severity note;
        FOR i IN 0 TO 8 loop
            ps2_clk_io <= '0';
            wait for 50 us;
            ps2_clk_io <= 'Z';
            wait for 50 us;
        end loop;
        
        --Sonderbehandlung ACK Bit von Tastatur nach erfolgreich übertragengen Packet
        ps2_clk_io <= '0';
        wait for 50 us;
        ps2_clk_io <= 'Z';
        wait for 25 us;
        ps2_dat_io <= '0';
        wait for 25 us;
        ps2_clk_io <= '0';
        wait for 50 us;
        ps2_clk_io <= 'Z';
        wait for 25 us;
        ps2_dat_io <= 'Z';
        wait;
    end process;
    
    
    
    dut : entity work.Keyboard(arch) port map(
        keyboard_clk_i              => clk_i,
        keyboard_rst_i              => rst_i,
        keyboard_ps2_clk_i          => ps2_clk_io,
        keyboard_ps2_data_i         => ps2_dat_io,
        keyboard_scancode_o         => open,
        keyboard_new_scancode_o     => open
    );
    
    
   
    
end architecture arch;