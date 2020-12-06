
-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Counter_En IS
	generic(
				delayEnbl 	 : integer := 4
	); 
  port(
			clk 			: in std_logic;
			sig_en    : out std_logic
		);
END Counter_En;

--Define ROM and initialize entries
ARCHITECTURE Behavioral OF Counter_En IS

	-- Signals
	signal counter 	: integer := 0;
	
BEGIN

	process(clk)
	begin
		if(rising_edge(clk)) then
			if (counter = delayEnbl-1) then
				counter <= delayEnbl-1;
				sig_en <= '1';
			else
				sig_en <= '0';		
				counter <= counter + 1;	
			end if;					
		end if;
	end process;
  
END Behavioral;
