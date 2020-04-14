----------------------------------------------------------------------------------------------------
--  Edge Detector Modul. Synchronisiert Signale ein und verhindert Metastabilität
--
--
--  Port:
--		clk_i       : Basistakt
--		rst_i       : asynchroner Reset, high-aktiv
--		din_i       : Dateneingang
--		fedge_o     : Signalisiert, dass eine fallende Flanke des Dateneingangs
--		redge_o     : Signalisiert, dass eine steigende Flanke des Dateneingangs
--		synced_o    : Das einsychronisierte Signal
--   
--		
--  Autor: Jan Ottmüller & Guillaume Fournier-Mayer
--  Datum: 19.06.2018
----------------------------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;

entity DoubleEdgeDetector is
    port ( 
        clk_i       : in std_logic;
        rst_i       : in std_logic;
        din_i       : in std_logic;
        fedge_o     : out std_logic;
        redge_o     : out std_logic;
		synced_o    : out std_logic
    );
end DoubleEdgeDetector;

architecture arch of DoubleEdgeDetector is

signal ff :std_logic_vector(2 downto 0);
begin

    process(clk_i, rst_i, ff) begin
        if(rst_i = '1')then
            ff <= (others => '0');
        elsif rising_edge(clk_i) then
            ff <= ff(1 downto 0) & din_i;
        end if;
    end process;

    fedge_o <= (ff(1) and not ff(0)); --falling or falling edge (1 -> 0)
    redge_o <= (not ff(1) and ff(0)); --rising or falling edge (0 -> 1)
    synced_o <= ff(1);    
end arch;