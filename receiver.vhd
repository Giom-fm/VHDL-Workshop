----------------------------------------------------------------------------------------------------
--  Receiver Modul. Implementiert, dass Empfangen von Daten über die PS2-Schnittstelle.
--
--  Sobald Daten vom Eingabegerät empfangen werden, wird busy_rec_o gesetzt.
-- 	Nach vollständiger Übertragung werden die empfangenen Daten auf data_o ausgegeben und 
--  new_data_o gesetzt. Falls beim Empfangen der Daten ein fehler aufgetreten ist wird zusätzlich
-- 	err_rec_o gesetzt. Das lesen der Daten wird mit data_read_i bestätigt. Anschließend werden
-- 	busy_rec_o, new_data_o und ggf. err_rec_o gelöscht.
--
--
--  Port:
--		clk_i           : Basistakt
--		rst_i           : asynchroner Reset, high-aktiv
--		ps2_clk_fedge   : Fallende Flanke des Ps2-Taktes
--		ps2_dat_synced  : Einsychronisierte PS2-Datenleitung
--		busy_rec_o      : Signalisiert, dass der Receiver beschäftigt ist zu empfangen
--		data_o          : Die Daten die Empfangen worden sind
--		new_data_o      : Signalisiert, dass neue Daten vollständig empfangen worden sind
--		err_rec_o       : Signalisiert, dass ein Fehler beim empfangen aufgetreten ist
--		data_read_i     : Signalisiert, dass die Daten ausgelesen worden sind
--		do_not_receive  : Signalisiert, dass die empfangen Daten ignoriert werden können, da sie vom transmitter kommen
--		
--
--  Autor: Jan Ottmüller & Guillaume Fournier-Mayer
--  Datum: 19.06.2018


library ieee;
use ieee.std_logic_1164.all;

entity Receiver is 
    port(
        clk_i           : in std_logic;
        rst_i           : in std_logic;
        ps2_clk_fedge   : in std_logic;
        ps2_dat_synced  : in std_logic;
        
        busy_rec_o      : out std_logic;
        data_o          : out std_logic_vector(7 downto 0);
        new_data_o      : out std_logic;
        err_rec_o       : out std_logic;
        data_read_i     : in std_logic;
        do_not_receive  : in std_logic
        );
end entity Receiver;

architecture arch of Receiver is
    signal regs : std_logic_vector(10 downto 0):= (others => '0');
    signal error : std_logic := '0';
    signal counter : natural  range 0 to 11 := 0;
begin
    
    error <= not (not regs(0) and 
            (regs(1) xor regs(2) xor regs(3) xor regs(4) xor regs(5) xor regs(6) xor regs(7) xor regs(8) xor regs(9)) 
            and regs(10));
    
    
    receive : process(clk_i, ps2_clk_fedge, rst_i, do_not_receive, counter, data_read_i, error) begin
        if(rst_i = '1') then
             regs <= (others => '0');
             counter <= 0;
             new_data_o <= '0';
             err_rec_o <= '0';
             data_o <= (others => '0');
             busy_rec_o <= '0';
        elsif(rising_edge(clk_i) and do_not_receive = '0')then    
            if(ps2_clk_fedge  = '1') then
                regs <=  ps2_dat_synced & regs(10 downto 1);
                counter <= counter + 1;
                busy_rec_o <= '1';
            elsif(counter = 11)then
                if(error = '0') then
                    data_o <= regs(8 downto 1);
                    new_data_o <= '1';
                end if;
                err_rec_o <= error;
                busy_rec_o <= '0';
                counter <= 0;
                regs <= (others => '0');
            end if;
            if(data_read_i = '1')  then
                new_data_o <= '0';
            end if;
        end if;
    end process receive;
end architecture arch;
