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

ENTITY SymbolSelection IS
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
END SymbolSelection;

ARCHITECTURE Struct OF SymbolSelection IS
	
	signal aux    : std_logic_vector(AdrrWidth-1 downto 0) := (others=>'0');
	
BEGIN

	process(QuadNumber,Input_I,Input_R)

	begin

		C0: case QuadNumber is
			  when "00" => 
					if (Input_I < dcI1) and (Input_R < dcR1) then
							aux <= "0000";
					elsif (Input_I < dcI1) and (Input_R > dcR1) then
						aux <= "0001";
					elsif (Input_I > dcI1) and (Input_R < dcR1) then
						aux <= "0010";
					else
						aux <= "0011";
					end if;
			  when "01" => 
					if (Input_I < dcI1) and (Input_R < dcR2) then
							aux <= "0100";
					elsif (Input_I < dcI1) and (Input_R > dcR2) then
						aux <= "0101";
					elsif (Input_I > dcI1) and (Input_R < dcR2) then
						aux <= "0110";
					else
						aux <= "0111";
					end if;
			  when "10" => 
					if (Input_I < dcI2) and (Input_R < dcR2) then
							aux <= "1000";
					elsif (Input_I < dcI2) and (Input_R > dcR2) then
						aux <= "1001";
					elsif (Input_I > dcI2) and (Input_R < dcR2) then
						aux <= "1010";
					else
						aux <= "1011";
					end if;
			  when "11" => 
					if (Input_I < dcI2) and (Input_R < dcR1) then
							aux <= "1100";
					elsif (Input_I < dcI2) and (Input_R > dcR1) then
						aux <= "1101";
					elsif (Input_I > dcI2) and (Input_R < dcR1) then
						aux <= "1110";
					else
						aux <= "1111";
					end if;
				WHEN OTHERS => 
					aux <= "0000";
		end case C0;

	end process;
	
	SymbolAdrr <= aux;
		
END Struct;