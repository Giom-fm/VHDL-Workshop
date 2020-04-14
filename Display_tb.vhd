library ieee;
use ieee.std_logic_1164.all;

entity Display_tb is
end entity Display_tb;

architecture arch of Display_tb is
    signal stateFlag, clk_i, rst_i, lcd_on, lcd_blon, lcd_en, lcd_rs, lcd_rw : std_logic := '0';
    signal   lcd_ram_increase_read_address: std_logic;
    signal lcd_ram_data, lcd_data_bus: std_logic_vector(7 downto 0);
begin


sysClock : process begin
    wait for 10 ns;
    clk_i <= not clk_i;
end process sysClock;

Display : entity work.Display(arch)
    port map(
    clk_i,               
    rst_i,             
    lcd_on,             
    lcd_blon,           
    lcd_en,            
    lcd_rs,            
    lcd_rw,            
    lcd_data_bus,
    lcd_ram_increase_read_address,
    lcd_ram_data
  
    );
end architecture arch;