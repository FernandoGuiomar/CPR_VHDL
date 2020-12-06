-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
use ieee.math_real.all;

library work;
USE work.constDef_pkg.all;
---------------------------------------------------------

ENTITY SymbolSubQuad364QAM IS
   GENERIC( 
	  Input_int   	: integer := 2;
	  Input_frac  	: integer := 16;
	  QuadNbits 	: integer := 3;
	  AdrrWidth 	: integer := 3
   );
   PORT( 
      clk         	: IN  std_logic;
      clk_en      	: IN  std_logic;
      Input_I 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
      Input_R 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	  QuadNumber    : IN std_logic_vector (QuadNbits-1 DOWNTO 0);
      SymbolAdrr    : OUT std_logic_vector (AdrrWidth-1 DOWNTO 0)
   );
END SymbolSubQuad364QAM;

ARCHITECTURE Struct OF SymbolSubQuad364QAM IS
	
	signal aux    : std_logic_vector(AdrrWidth-1 downto 0) := (others=>'0');
	
BEGIN

	process(QuadNumber,Input_I,Input_R)
	
	begin
		
		C0: case QuadNumber is
			  when "00" => 
					if (Input_I < dcI10) and (Input_R < dcR00) then
							aux <= "110110";
					elsif (Input_I < dcI10) and (Input_R > dcR00) then
						aux <= "110111";
					elsif (Input_I > dcI10) and (Input_R < dcR00) then
						aux <= "110010";
					else
						aux <= "110011";
					end if;
			  when "01" => 
					if (Input_I < dcI10) and (Input_R < dcR01) then
							aux <= "110101";
					elsif (Input_I < dcI10) and (Input_R > dcR01) then
						aux <= "110100";
					elsif (Input_I > dcI10) and (Input_R < dcR01) then
						aux <= "110001";
					else
						aux <= "110000";
					end if;
			  when "10" => 
					if (Input_I < dcI11) and (Input_R < dcR00) then
							aux <= "111010";
					elsif (Input_I < dcI11) and (Input_R > dcR00) then
						aux <= "111011";
					elsif (Input_I > dcI11) and (Input_R < dcR00) then
						aux <= "111110";
					else
						aux <= "111111";
					end if;
			  when "11" => 
					if (Input_I < dcI11) and (Input_R < dcR01) then
							aux <= "111001";
					elsif (Input_I < dcI11) and (Input_R > dcR01) then
						aux <= "111000";
					elsif (Input_I > dcI11) and (Input_R < dcR01) then
						aux <= "111101";
					else
						aux <= "111100";
					end if;
				WHEN OTHERS => 
					aux <= "000000";
		end case C0;

	end process;
	
	SymbolAdrr <= aux;
		
END Struct;