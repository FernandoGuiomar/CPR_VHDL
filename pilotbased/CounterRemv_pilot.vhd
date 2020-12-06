-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY CounterRemv_pilot IS
  generic(
			countMax 		: integer := 4
	); 
  port(
			clk 	: in std_logic;
			sig_en    : out std_logic
		);
END CounterRemv_pilot;

--Define ROM and initialize CounterRemv_pilot
ARCHITECTURE Behavioral OF CounterRemv_pilot IS

	-- Signals
	signal counter 	  : integer := 1;
	signal sig_en_aux 	  : std_logic := '0';
BEGIN

	process(clk)

	begin
		if(rising_edge(clk)) then
			if (counter = countMax-1) then
				counter <= 0;
				sig_en_aux <= '1';
			else
				sig_en_aux <= '0';		
				counter <= counter + 1;	
			end if;					
		end if;
	end process;
   sig_en <= sig_en_aux;
END Behavioral;
