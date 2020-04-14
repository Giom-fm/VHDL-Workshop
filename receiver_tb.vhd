library ieee;
use ieee.std_logic_1164.all;


entity receiver_tb is
end entity receiver_tb;

architecture arch of receiver_tb is
      
    signal clk, ps2_clk_io, ps2_dat_io : std_logic := '0';
    signal rst_i,send_i,busy_send_o,err_send_o,busy_rec_o,new_data_o,err_rec_o,data_read_i : std_logic := '0';
    signal data_o, data_i : std_logic_vector(7 downto 0);
    
    signal test_package_1 : std_logic_vector(0 to 10) := "01101010011";
    signal test_package_2 : std_logic_vector(0 to 10) := "00101001011";
   
begin
    
    
    -- 50Mhz clock
    sysClock : process begin
        wait for 10 ns;
        clk <= not clk;
    end process sysClock;
    
    -- 10Khz Clock
    ps2Clock : process begin
        ps2_clk_io <= '1';
        wait for 50 us;
        ps2_clk_io <= '0';
        wait for 50 us;
    end process ps2Clock;
    
    dataIn : process begin 
        
        --Reset
        rst_i <= '1';
        wait for 20 ns;
        rst_i <= '0';
        
        report "Paket 1(Valide): Start" Severity note;
        package1 : FOR i IN 0 TO 10 LOOP
            ps2_dat_io <= test_package_1(i);
            wait for 55 us;
            if(i = 10) then
                report "Packet 1(Valide): Ende" Severity note;
                --paket ende
                assert(err_rec_o = '0') report "err_rec_o gesetzt (Bit 11)!" Severity error;
                assert(new_data_o = '1') report "new_data_o nicht gesetzt!" Severity error;
                assert(data_o = "10110101") report "Daten Falsch empfangen!" Severity error;
                data_read_i <= '1';
                wait for 20 ns;
                data_read_i <= '0';
                assert(new_data_o = '0') report "new_data_o wurde nicht zurück gesetzt!" Severity error;
            else
                --noch kein ende erreicht!
                assert(err_rec_o /= '1') report "err_rec_o gesetzt!" Severity error;
                assert(new_data_o /= '1') report "new_data_o gesetzt!" Severity error;
            end if;
           wait for 45 us;
        end loop package1;
            
        report "Paket 2(Partity): Start" Severity note;
        package3 : FOR i IN 0 TO 10 LOOP
            ps2_dat_io <= test_package_2(i);
            wait for 45 us;
            if(i = 10) then
                report "Paket 2(Partity): Ende" Severity note;
                assert(err_rec_o = '1') report "err_rec_o nicht gesetzt (Bit 11)!" Severity error;
                wait for 20 ns;
            elsif (i = 9) then
                 report "Paket 2(Parity): Parity Error" Severity note;
            end if;
            wait for 35 us;
        end loop package3;
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