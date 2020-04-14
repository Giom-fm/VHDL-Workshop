----------------------------------------------------------------------------------------------------
--	Transmitter Modul. 	Implemetiert das Senden von Daten über die PS2 Schnittstelle.
--			
--  Das Senden des Datums data_i wird durch Setzten von send_i eingeleitet. Während des Sendens ist
--  busy_send_o gesetzt. Falls beim Senden ein Fehler auftritt wird err_send_o gesetzt und bleibt 
--  bis zum starten des nächsten Sendevorgang (send_i) gesetzt.
--
--  Port:
--		clk_i           : Basistakt
--      rst_i           : Asynchroner Reset
--      ps2_clk_fedge   : Signal für die fallende Flanke der PS2 Clock
--      ps2_clk_redge   : Signal für die steigende Flanke der PS2 Clock
--      ps2_dat_fedge   : Signal für die fallende Flanke der PS2 Daten
--      ps2_dat_redge   : Signal für die steigende Flanke der PS2 Daten
--      pull_clk_low    : Gibt das Signal, dass die Clock Leitung auf '0' gezogen werden soll
--      pull_dat_low    : Gibt das Signal, dass die Daten Leitung auf '0' gezogen werden soll
--      
--      data_i      	: Die zu sendenden Daten
--      send_i      	: Signal, dass jetzt gesendet werden soll
--      busy_send_o 	: Signalisiert, dass gerade gesender wird
--      err_send_o  	: Signalisiert ein Fehler beim Versenden
--		
--
--  Autor: Jan Ottmüller & Guillaume Fournier-Mayer
--  Datum: 18.09.2018
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Transmitter is 
    port(
        clk_i           : in std_logic;
        rst_i           : in std_logic;
        ps2_clk_fedge   : in std_logic;
        ps2_clk_redge   : in std_logic;
        ps2_dat_fedge   : in std_logic;
        ps2_dat_redge   : in std_logic;
        pull_clk_low    : out std_logic;
        pull_dat_low    : out std_logic;
        
        data_i      : in std_logic_vector(7 downto 0);
        send_i      : in std_logic;
        busy_send_o : out std_logic;
        err_send_o  : out std_logic
        );
end entity Transmitter;

architecture arch of Transmitter is
    
    signal counter, package_time : natural range 0 to 750000 := 0;
    signal regs : std_logic_vector(9 downto 0) := (others => '0'); -- 8 Data Bits + 1 Parity + Stopbit
    signal parity, shift_now : std_logic := '0';
    type STATE_TYPE is (SWaintToSend,SPullClkLow, SPullDatLow, SSendFirstBit, SSend, SCheckTimeout, SCleanUp );
    signal state, next_state : STATE_TYPE;
    signal sending : bit := '0';
    
begin

    
    parity <= not(data_i(7) xor data_i(6) xor data_i(5) xor data_i(4) xor data_i(3) xor data_i(2) xor data_i(1) xor data_i(0));
    
    transOut : process(clk_i, rst_i, counter, send_i, sending) begin
        if(rst_i = '1') then                        -- reset
            next_state <= SWaintToSend;
            regs <= (others => '0');
            counter <= 0;
            sending <= '0';
            pull_clk_low <= '0';
            pull_dat_low <= '0';
            package_time <= 0;
            err_send_o <= '0';
            busy_send_o <= '0';
        elsif(rising_edge(clk_i) and (send_i = '1' or sending = '1')) then
        counter <= counter + 1;
            case state is                                   -- Counter
                when SWaintToSend =>
                busy_send_o <= '1';
                sending <= '1';
                if(counter = 20000) then                    -- 400 µs Warten damit Tastatur wieder bereit ist 
                        next_state <= SPullClkLow;
                        counter <= 0;
                    end if;
                when SPullClkLow =>                                   
                    if(counter = 5000) then                 -- Die Clock-Leitung für mindestens 100 µs auf Low bringen
                        regs <= '1' & parity & data_i;      -- Create Databits + parity + Stopbit
                        next_state <= SPullDatLow;
                    else
                        pull_clk_low <= '1';
                    end if;
                when SPullDatLow =>
                    pull_dat_low <= '1';                       -- Die Datenleitung auf Low bringen - Start Bit
                    pull_clk_low <= '0';                       -- Die Clockleitung wieder High werden lassen
                    next_state <= SSendFirstBit;
                when SSendFirstBit =>
                    if(ps2_clk_fedge = '1') then 
                        if(package_time = 0)then
                            package_time <= counter;
                        end if;
                        if(counter < 750000) then           -- Warten, bis das Eingabegerät die Clockleitung auf Low bringt / Wenn Max überschritten wurde => Fehler (15ms)          
                            next_state <= SSend;
                            pull_dat_low <= not regs(0);  	        -- Sende erstes Bit bei fallener PS2 clock Flanke
                            regs <= '0' & regs(9 downto 1);     -- Shifte weiter
                        else 
                            err_send_o <= '1';
                            sending <= '0';
                            busy_send_o <= '0';
                            next_state <= SWaintToSend;
                        end if;
                    end if;
                when SSend =>
                    if(counter - package_time > 100000) then -- 2ms -package time
                            err_send_o <= '1';
                            sending <= '0';
                            busy_send_o <= '0';
                            next_state <= SWaintToSend;
                        elsif(regs = "0000000000") then             -- weiter, wenn das Register leer ist
                            next_state <= SCheckTimeout; 
                        elsif(ps2_clk_fedge = '1') then             -- bei fallender flanke signal ändern
                            pull_dat_low <= not regs(0);            -- Sende Bit bei fallener PS2 clock Flanke
                            regs <= '0' & regs(9 downto 1);         -- Shifte weiter
                    end if;
                when SCheckTimeout =>
                    if(counter > 1000000) then -- 2ms timeout
                            err_send_o <= '1';
                            sending <= '0';
                            busy_send_o <= '0';
                            next_state <= SWaintToSend;
                        else
                            next_state <= SCleanUp;
                    end if;
                when SCleanUp =>
                    if(ps2_dat_redge = '1' ) then -- Warte dass alles wieder freigeben wird
                        busy_send_o <= '0';
                        counter <= 0;
                        next_state <= SWaintToSend;
                        sending <= '0';
                    end if;
            end case;
        end if;
    end process transOut;
    
    
    
     store : process(clk_i, rst_i) begin
        if(rst_i = '1') then
            state <= SWaintToSend;
        elsif(rising_edge(clk_i)) then
            state <= next_state;
        end if;
    end process store;
   
end architecture arch;


