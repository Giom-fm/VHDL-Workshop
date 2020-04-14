----------------------------------------------------------------------------------------------------
--  PS2 Host modul. Implemetiert das Senden und Empfangen von Daten über die PS2 Schnittstelle.
--
--  Senden:
--  Das Senden des Datums data_i wird durch Setzten von send_i eingeleitet. Während des Sendens ist
--  busy_send_o gesetzt. Falls beim Senden ein Fehler auftritt wird err_send_o gesetzt und bleibt 
--  bis zum starten des nächsten Sendevorgang (send_i) gesetzt.
--
--  Empfangen:
--  Sobald Daten vom Eingabegerät empfangen werden, wird busy_rec_o gesetzt.
--  Nach vollständiger Übertragung werden die empfangenen Daten auf data_o ausgegeben und 
--  new_data_o gesetzt. Falls beim Empfangen der Daten ein fehler aufgetreten ist wird zusätzlich
--  err_rec_o gesetzt. Das lesen der Daten wird mit data_read_i bestätigt. Anschließend werden
--  busy_rec_o, new_data_o und ggf. err_rec_o gelöscht.
--
--  Generics:
--      G_CLK_PERIODE:
--          Periodendauer des Taktes clk_i.
--
--  Port:
--      rst_i       : asynchroner Reset, high-aktiv
--      clk_i       : Basistakt
--      
--      data_i      : die zu sendenden Daten
--      send_i      : startet den Sendevorgang
--      busy_send_o : signalisiert, dass gerade Daten gesendet werden
--      err_send_o  : signalisiert, dass ein Fehler beim Senden aufgetreten ist
--      
--      busy_rec_o  : signalisiert, dass gerade Daten empfangen werden
--      data_o      : die empfangenen Daten
--      new_data_o  : signalisiert, dass neue Daten vorliegen
--      err_rec_o   : signalisiert, dass ein Fehler beim Empfangen von Daten aufgetreten ist
--      data_read_i : bestätigt, dass die Daten gelesen worden sind
--      
--      ps2_clk_io  : Taktleitung zum PS2 Slave
--      ps2_dat_io  : Datenleitung zum PS2 Slave
--
--  Autor: Jan Ottmüller & Guillaume Fournier-Mayer
--  Datum: 19.06.2018
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Transceiver is
    port (
        transceiver_rst_i       : in std_logic;
        transceiver_clk_i       : in std_logic;
        
        --Transmitter
        transceiver_data_i      : in std_logic_vector(7 downto 0);
        transceiver_send_i      : in std_logic;
        transceiver_busy_send_o : out std_logic;
        transceiver_err_send_o  : out std_logic;
        
        --Receiver
        transceiver_busy_rec_o  : out std_logic;
        transceiver_data_o      : out std_logic_vector(7 downto 0);
        transceiver_new_data_o  : out std_logic;
        transceiver_err_rec_o   : out std_logic;
        transceiver_data_read_i : in std_logic;
        
        transceiver_ps2_clk_io  : inout std_logic;
        transceiver_ps2_dat_io  : inout std_logic
    );
end entity Transceiver;


architecture arch of Transceiver is   

    --=========================================================================
    --Transmitter
    	signal synced_PS2data       : std_logic := '0';
        signal transmitter_dat_o                : std_logic := '0';
        signal transmitter_clk_o                : std_logic := '0';
        signal transmitter_busy_send            : std_logic := '0';
    --=========================================================================
    --Edges
    signal  ps2_clk_fedge                : std_logic := '0';
    signal  ps2_clk_redge              : std_logic := '0';
    signal  ps2_dat_fedge               : std_logic := '0';
    signal  ps2_dat_redge                : std_logic := '0';
    signal  busySend        : std_logic := '0';
    signal pull_dat_low   : std_logic := '0';
    signal pull_clk_low   : std_logic := '0';
    
begin
     transceiver_ps2_dat_io <= 'Z'; 
     transceiver_ps2_clk_io <= 'Z';
     transceiver_busy_send_o <= busySend;
     
     transceiver_ps2_dat_io <= '0' when pull_dat_low = '1' else 'Z'; -- handle pull low request from transmitter
     transceiver_ps2_clk_io <= '0' when pull_clk_low = '1' else 'Z';
   
    
    ps2Clk :entity work.DoubleEdgeDetector(arch)
    port map(
        clk_i         => transceiver_clk_i,
        rst_i         => transceiver_rst_i,
        din_i         => transceiver_ps2_clk_io,
        fedge_o       => ps2_clk_fedge,
        redge_o       => ps2_clk_redge
    ); 
	
	ps2Data :entity work.DoubleEdgeDetector(arch)
    port map(
        clk_i         => transceiver_clk_i,
        rst_i         => transceiver_rst_i,
        din_i         => transceiver_ps2_dat_io,
		synced_o	  => synced_PS2data,
        fedge_o       => ps2_dat_fedge,
        redge_o       => ps2_dat_redge
        ); 


    Receiver :entity work.Receiver(arch)
    port map(
        rst_i           => transceiver_rst_i,
        clk_i           => transceiver_clk_i, 
        ps2_clk_fedge   => ps2_clk_fedge,
        ps2_dat_synced  => synced_PS2data,
        busy_rec_o      => transceiver_busy_rec_o, 
        data_o          => transceiver_data_o,
        new_data_o      => transceiver_new_data_o, 
        err_rec_o       => transceiver_err_rec_o,
        data_read_i     => transceiver_data_read_i,
        do_not_receive  => busySend
    );
    
    Transmitter :entity work.Transmitter(arch)
    port map(
        rst_i           => transceiver_rst_i, 
        clk_i           => transceiver_clk_i,
      
        ps2_clk_fedge   => ps2_clk_fedge,
        ps2_clk_redge   => ps2_clk_redge,
        ps2_dat_fedge   => ps2_dat_fedge,
        ps2_dat_redge   => ps2_dat_redge,
        
        data_i          => transceiver_data_i,      
        send_i          => transceiver_send_i,
        busy_send_o     => busySend,
        err_send_o      => transceiver_err_send_o,
        pull_dat_low    => pull_dat_low,
        pull_clk_low    => pull_clk_low
        );
    
    
end architecture arch;

