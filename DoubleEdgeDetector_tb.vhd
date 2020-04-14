

library ieee;
use ieee.std_logic_1164.all;


entity DoubleEdgeDetector_tb is
end entity DoubleEdgeDetector_tb;

architecture behav of DoubleEdgeDetector_tb is
    signal rst      : std_logic := '0'; 
    signal din      : std_logic := '0'; 
    signal clk      : std_logic := '0';
    signal synced_o : std_logic := '0';
    
begin

    -- 50Mhz Clock
    clock : process begin
        wait for 10 ns;
        clk <= not clk;
    end process clock;
    
    --Test Input
    din <= '1' after 25 ns, '0' after 45 ns;
    
    test : process begin
        --Reset
        rst <= '1';
        wait for 20 ns; -- 20 ns
        rst <= '0';
        wait for 35 ns; -- 55 ns
        assert (synced_o = '1') report "Synced_o wrong";
        wait for 25 ns; -- 75 ns
        assert (synced_o = '0') report "Synced_o wrong";
        wait;
    end process test;
    
    dut : entity work.DoubleEdgeDetector(arch)
    port map(
        rst_i => rst,
        clk_i => clk,
        din_i => din,
        synced_o => synced_o
    );
     
end architecture behav;
