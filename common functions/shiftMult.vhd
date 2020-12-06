LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 --
-------------------------------------------------------------------

ENTITY ShiftMult IS
   GENERIC( 
		NBits 	: integer := 22
   );
   PORT( 
       Input          	: IN     std_logic_vector (NBits-1 DOWNTO 0);
	   clk           	: IN     std_logic; 
	   clk_en           : IN     std_logic; 
	   Output           : OUT    std_logic_vector (NBits-1 DOWNTO 0)
   );
END ShiftMult ;


ARCHITECTURE Behavioral OF ShiftMult IS
	
begin 
		
	process(clk)	
		variable aux : std_logic_vector(NBits-1 DOWNTO 0):= (others => '0');
	begin
		if(rising_edge(clk)) then	
			if(clk_en='1') then
				aux := Input(NBits-3 DOWNTO 0) & "00"; -- multiplication by 4									
			end if;
		end if;
		Output <= aux;
	end process;
	
END Behavioral;