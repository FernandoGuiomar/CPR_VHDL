-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------

ENTITY ShiftDiv IS
   GENERIC( 
		NBits 	: integer := 22;
		NBitsOut : integer := 22
   );
   PORT( 
       Input          	: IN     std_logic_vector (NBits-1 DOWNTO 0);
	   clk           	: IN     std_logic; 
	   clk_en           : IN     std_logic; 
	   Output           : OUT    std_logic_vector (NBitsOut-1 DOWNTO 0)
   );
END ShiftDiv ;


ARCHITECTURE Behavioral OF ShiftDiv IS
	
begin 
		
	process(clk)	
	
	begin
		if(rising_edge(clk)) then	
			if(clk_en='1') then
				Output <= Input(NBits-1) & Input(NBits-1) & Input(NBits-1 DOWNTO 2); -- division by 4
			end if;
		end if;
	end process;
	
END Behavioral;