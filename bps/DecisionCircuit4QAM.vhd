-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
use ieee.numeric_std.ALL;
use ieee.math_real.all;
---------------------------------------------------------

ENTITY DecisionCircuit4QAM IS
   GENERIC( 
      Input_int   	: integer := 2;
	  Input_frac  	: integer := 6;
	  AdrrWidth 	: integer := 4
   );
   PORT( 
      clk         	: IN  std_logic;
      clk_en      	: IN  std_logic;
	  Input_R 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
      Input_I 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	  DecodeSymAdrr : OUT std_logic_vector (AdrrWidth-1 DOWNTO 0)
   );
END DecisionCircuit4QAM;

ARCHITECTURE Struct OF DecisionCircuit4QAM IS
	
	signal aux : std_logic_vector(AdrrWidth-1 downto 0) := (others=>'0');
	
BEGIN
	
	process(Input_R,Input_I)

	begin		
		if (Input_I(Input_int+Input_frac-1) = '0') and (Input_R(Input_int+Input_frac-1) = '0') then
			aux <= "00";
		elsif (Input_I(Input_int+Input_frac-1) = '0') and (Input_R(Input_int+Input_frac-1) = '1') then
			aux <= "01";
		elsif (Input_I(Input_int+Input_frac-1) = '1') and (Input_R(Input_int+Input_frac-1) = '1') then
			aux <= "10";
		elsif (Input_I(Input_int+Input_frac-1) = '1') and (Input_R(Input_int+Input_frac-1) = '0') then
			aux <= "11";
		else
			aux <= "00";
		end if;
			
	end process;
	
	DecodeSymAdrr <= aux;
    
END Struct;