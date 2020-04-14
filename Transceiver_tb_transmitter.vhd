library ieee;
use ieee.std_logic_1164.all;


entity Transceiver_tb_transmitter is
end entity Transceiver_tb_transmitter;

architecture arch of Transceiver_tb_transmitter is
      
    signal clk, ps2_clk_io, ps2_dat_io : std_logic := '0';
    signal rst_i,send_i,busy_send_o,err_send_o,busy_rec_o,new_data_o,err_rec_o,data_read_i : std_logic := '0';
    signal data_o, data_i : std_logic_vector(7 downto 0);
    signal test_package_1 : std_logic_vector(7 downto 0) := "H0H0HH0H";
    signal test_package_result : std_logic_vector(9 downto 0) := "0000000000";

   
begin

    ps2_clk_io <= 'H';
    ps2_dat_io <= 'H';

    sysClock : process begin
        wait for 10 ns;
        clk <= not clk;
    end process sysClock;
    
    dataIn : process begin 
    
        --reset
        rst_i <= '1';
        wait for 20 ns;
        rst_i <= '0';
        ps2_clk_io <= 'Z';
        ps2_dat_io <= 'Z';
        
        -- valid Package
       report "Paket 1(valide): Start" Severity note;
       wait for 50 us;
       data_i <= test_package_1;
       send_i <= '1';
       wait for 100 ns;
       send_i <= '0';
       wait for 450 us;
       
       assert(busy_send_o ='1') report "busy_send_o nicht gesetzt!" Severity error;
       assert(ps2_clk_io = '0') report "der Transmitter hat die clk Leitung nicht auf low gezogen" Severity error;
       wait for 60 us;
       
        --Simuliere Clock von der Tastatur
        loop_send : FOR i IN 0 TO 9 LOOP
            ps2_clk_io <= '0';
            wait for 40 us;
            ps2_clk_io <= 'Z';
            test_package_result <=  ps2_dat_io & test_package_result(9 downto 1) ; -- save result
            wait for 40 us;
        end loop loop_send;
        
        assert(test_package_result(7 downto 0) = test_package_1)  report "Pakete ungleich" Severity error; -- compare result
        ps2_clk_io <= '0';
        ps2_dat_io <= '0';
        wait for 10 us;
        ps2_clk_io <= 'Z';
        ps2_dat_io <= 'Z';
        
        
       -- provoke error (package transmission takes longer than 2ms) and reset
       report "Paket 2(timeout 2ms): Start" Severity note;
       wait for 50 us;
       data_i <= test_package_1;
       send_i <= '1';
       wait for 100 ns;
       send_i <= '0';
       wait for 110 us;
       
        --Simuliere Clock von der Tastatur (zu langsam)
        loop_send1 : FOR i IN 0 TO 9 LOOP
            ps2_clk_io <= '0';
            wait for 150 us;
            ps2_clk_io <= 'Z';
            test_package_result <=  ps2_dat_io & test_package_result(9 downto 1) ;
            wait for 150 us;
        end loop loop_send1;
        
        assert(err_send_o = '1')  report "fehler nicht gesetzt (mehr als 2 ms)" Severity error;
        wait for 1 us;
        rst_i <= '1';
        wait for 1 us;
        ps2_clk_io <= 'Z';
        ps2_dat_io <= 'Z';
        report "ende tests PS2 transmitter" Severity note;
        wait;
        
    end process dataIn;
    
   
    dut : entity work.Transceiver(arch) port map(
       rst_i,
        clk,
       data_i,
        send_i,
       busy_send_o,
       err_send_o,
        busy_rec_o,
      data_o,
       new_data_o,
       err_rec_o,
       data_read_i,
        ps2_clk_io,
       ps2_dat_io
    );

      
end architecture arch;