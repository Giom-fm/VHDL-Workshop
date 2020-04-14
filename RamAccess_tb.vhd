library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RamAccess_tb is

end entity RamAccess_tb;


architecture arch of RamAccess_tb is

signal clk_i            : std_logic := '0';
signal rst_i            : std_logic := '0';
signal increase_read    : std_logic := '0';
signal increase_write   : std_logic := '0';
signal data_i           : std_logic_vector(7 downto 0) := "00000000";
signal data_o           : std_logic_vector(7 downto 0) := "00000000";

signal package_1        : std_logic_vector(7 downto 0) := "11111111";
signal package_2        : std_logic_vector(7 downto 0) := "00001111";
signal package_3        : std_logic_vector(7 downto 0) := "01010101";

begin

    sysClock : process begin
        wait for 10 ns;
        clk_i <= not clk_i;
    end process sysClock;
    
  
    
    
    process begin
    
        --Reset
        rst_i <= '1';
        wait for 10 ns;
        rst_i <= '0';
    
        --Schreibe package1 in dem Ram
        data_i <= package_1;
        increase_write <= '1';
        wait for 1 us;
        increase_write <= '0';
        wait for 1 us;
        
        --Schreibe package2 in dem Ram
        data_i <= package_2;
        increase_write <= '1';
        wait for 1 us;
        increase_write <= '0';
        wait for 1 us;
        
        --Schreibe package3 in dem Ram
        data_i <= package_3;
        increase_write <= '1';
        wait for 1 us;
        increase_write <= '0';
        wait for 1 us;
        
        --Lese package1 aus dem ram
        
        wait for 1 us;
        increase_read <= '1';
        wait for 1 us;
        increase_read <= '0';
        wait for 1 us;
        assert (data_o = package_1) report "Paket 1 Fehlerhaft" severity note;
        
        --Lese package2 aus dem ram
        increase_read <= '1';
        wait for 1 us;
        increase_read <= '0';
        wait for 1 us;
       assert (data_o = package_2) report "Paket 2 Fehlerhaft" severity note;
       
        
        --Lese package3 aus dem ram
        increase_read <= '1';
        wait for 1 us;
        increase_read <= '0';
        wait for 1 us;
        assert (data_o = package_3) report "Paket 3 Fehlerhaft" severity note;
      
        wait;
    end process;
    
    

 Ram :entity work.RamAccess(arch)
    port map(
        ramAccess_rst_i                     => rst_i,
        ramAccess_clk_i                     => clk_i,
        ramaccess_increase_read_address     => increase_read,
        ramaccess_increase_write_address    => increase_write,
        ramaccess_data_i                    => data_i,
        ramaccess_data_o                    => data_o  
    );

end architecture arch;