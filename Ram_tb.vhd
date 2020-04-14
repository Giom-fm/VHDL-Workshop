library ieee;
use ieee.std_logic_1164.all;


entity testbench_ram is
end entity testbench_ram;

architecture arch of testbench_ram is
      
    signal aclr		:  STD_LOGIC  := '0';
	signal clock	:  STD_LOGIC  := '1';
	signal data		:  STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal rdaddress:  STD_LOGIC_VECTOR (4 DOWNTO 0);
	signal wraddress:  STD_LOGIC_VECTOR (4 DOWNTO 0);
	signal wren		:  STD_LOGIC  := '0';
	signal q		:  STD_LOGIC_VECTOR (7 DOWNTO 0);
    
begin

    sysClock : process begin
        wait for 10 ns;
        clock <= not clock;
    end process sysClock;
    
    dataIn : process begin 
        report "starte tests ram" Severity note;
        
        -- set write address
        rdaddress <= "00001";
        --set read address
        wraddress <= "00001";
        
        --write enable
        
       
        --set data to save
        data <= "11110101";
        --wait for atat to save
        wait for 20 ns;
        wren <= '1';
        wait for 10 ns;
        wren <= '0';
        --it takes 50ns before the data is availible at q so wait for 60ns and then check data
        wait for 60 ns;
       
        assert(q = "11110101")  report "gelesene Daten entsprechen nicht den geschriebenen" Severity error;
       
        report "ende tests ram" Severity note;
        wait;
    end process dataIn;
    
   
    dut : entity work.ram(SYN) port map(	
		clock,		
		data,	
		rdaddress,		
		wraddress,	
		wren,		
		q	
    );

      
end architecture arch;