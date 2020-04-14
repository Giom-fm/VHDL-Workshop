----------------------------------------------------------------------------------------------------
--	RamAccess Modul. 	Implementiert ein Rammodul welches über die Flags ramaccess_increase_read_address und
--						ramaccess_increase_read_address eine Speicheradresse weiter gesetzt wird.
--			
--					
--
--
--  Port:
--		ramAccess_rst_i                     : asynchroner Reset, high-aktiv
--		ramAccess_clk_i                     : Basistakt
--		ramaccess_increase_read_address     : Signalisiert, dass die Leseadresse des Rams erhöhrt werden soll
--		ramaccess_increase_write_address    : Signalisiert, dass die Schreibeadresse des Rams erhöht werden soll
--		ramaccess_data_i                    : Daten die an die Schreibeadresse geschrieben werden sollen
--		ramaccess_data_o  					: Daten die an der Leseadresse stehen
--		
--
--  Autor: Jan Ottmüller & Guillaume Fournier-Mayer
--  Datum: 19.06.2018
----------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RamAccess is 
    port(
    ramAccess_rst_i                     : in std_logic;
    ramAccess_clk_i                     : in std_logic;
    ramaccess_increase_read_address     : in std_logic;
    ramaccess_increase_write_address    : in std_logic;
    ramaccess_data_i                    : in std_logic_vector(7 downto 0);
    ramaccess_data_o                    : out std_logic_vector(7 downto 0)
    );
end entity RamAccess;


architecture arch of RamAccess is 
    --=========================================================================
    --RAM
    signal ram_read_address_i       : STD_LOGIC_VECTOR (4 DOWNTO 0) := "00000";
    signal ram_write_address_i      : STD_LOGIC_VECTOR (4 DOWNTO 0) := "00000";
    signal ram_write_enable_i		: STD_LOGIC  := '0';
    --=========================================================================
    --Edge Detectors
    signal redge_read_address : std_logic;
    signal redge_write_address : std_logic;
    --=========================================================================
begin

process(ramAccess_clk_i, ramAccess_rst_i,ram_write_address_i,ram_read_address_i) begin

    if(ramaccess_rst_i = '1') then
        ram_write_address_i <= "00000";
        ram_read_address_i <= "00000";
        ram_write_enable_i <= '0';
    elsif (rising_edge(ramAccess_clk_i)) then
        if(redge_read_address = '1') then -- read Adresse soll inkrementiert werden
            ram_read_address_i <= std_logic_vector( unsigned(ram_read_address_i) + 1 );
        end if;
        if(redge_write_address = '1') then -- write Adresse soll inkrementiert werden
            ram_write_enable_i <= '1';
            ram_write_address_i <= std_logic_vector( unsigned(ram_write_address_i) + 1 );
        else 
            ram_write_enable_i <= '0';
        end if;
    end if;
end process;


  edgeread: entity work.DoubleEdgeDetector(arch)
    port map(
        clk_i         => ramAccess_clk_i,
        rst_i         => ramAccess_rst_i,
        din_i         => ramaccess_increase_read_address,
        fedge_o       => open,
        redge_o       => redge_read_address
    ); 
    
    
  edgewrite : entity work.DoubleEdgeDetector(arch)
    port map(
        clk_i         => ramAccess_clk_i,
        rst_i         => ramAccess_rst_i,
        din_i         => ramaccess_increase_write_address,
        fedge_o       => open,
        redge_o       => redge_write_address
    );   
    
Ram :entity work.Ram(SYN) port map(	
        clock		    => ramAccess_clk_i,
		data		    => ramaccess_data_i,
		rdaddress		=> ram_read_address_i,
		wraddress		=> ram_write_address_i,
		wren		    => ram_write_enable_i,
		q               => ramaccess_data_o
    );
end architecture arch;