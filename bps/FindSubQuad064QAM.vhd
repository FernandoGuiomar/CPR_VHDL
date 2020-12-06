-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------

-- Atraso = 1 clocks

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
use ieee.math_real.all;

library work;
USE work.constDef_pkg.all;
---------------------------------------------------------

ENTITY FindSubQuad064QAM IS
   GENERIC( 
	  Input_int   	: integer := 2;
	  Input_frac  	: integer := 16;
	  QuadNbits 	: integer := 3
	  );
   PORT( 
      clk         	: IN  std_logic;
      clk_en      	: IN  std_logic;
      Input_I 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
      Input_R 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
      QuadNumber    : OUT std_logic_vector (QuadNbits-1 DOWNTO 0)
   );
END FindSubQuad064QAM;

ARCHITECTURE Struct OF FindSubQuad064QAM IS
	
	signal aux    : std_logic_vector(QuadNbits-1 downto 0) := (others=>'0');
	
BEGIN

	process(Input_I,Input_R)
	
	begin				
		if (Input_I < dcQI0) and (Input_R < dcQR0) then
				aux <= "00";
		elsif (Input_I < dcQI0) and (Input_R > dcQR0) then
			aux <= "01";
		elsif (Input_I > dcQI0) and (Input_R < dcQR0) then
			aux <= "10";
		else
			aux <= "11";
		end if;				  
	end process;
	
	QuadNumber <= aux;
		
END Struct;