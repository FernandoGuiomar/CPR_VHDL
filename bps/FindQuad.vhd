-----------------------------------------
-- Authors: 
-----------------------------------------



LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
use ieee.math_real.all;
---------------------------------------------------------

ENTITY FindQuad IS
   GENERIC( 
	  QuadNbits 	: integer := 2
   );
   PORT( 
      clk         	: IN  std_logic;
      clk_en      	: IN  std_logic;
      Sign_I 		: IN  std_logic;
      Sign_R 		: IN  std_logic;
      QuadNumber    : OUT std_logic_vector (QuadNbits-1 DOWNTO 0)
   );
END FindQuad;

ARCHITECTURE Struct OF FindQuad IS
	
	signal aux : std_logic_vector(QuadNbits-1 downto 0) := (others=>'0');
	
BEGIN
	
	process(Sign_I,Sign_R)
	begin
		if (Sign_I = '0') and (Sign_R = '0') then
			aux <= "00";
		elsif (Sign_I = '0') and (Sign_R = '1') then
			aux <= "01";
		elsif (Sign_I = '1') and (Sign_R = '1') then
			aux <= "10";
		elsif (Sign_I = '1') and (Sign_R = '0') then
			aux <= "11";
		else
			aux <= "00";
		end if;
	end process;
	
	QuadNumber <= aux;
	
END Struct;