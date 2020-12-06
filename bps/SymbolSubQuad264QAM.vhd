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

ENTITY SymbolSubQuad264QAM IS
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
END SymbolSubQuad264QAM;

ARCHITECTURE Struct OF SymbolSubQuad264QAM IS
	
	signal aux    : std_logic_vector(AdrrWidth-1 downto 0) := (others=>'0');
	
BEGIN

	process(QuadNumber,Input_I,Input_R)
	
	begin
		
		C0: case QuadNumber is
			  when "00" => 
					if (Input_I < dcI10) and (Input_R < dcR10) then
							aux <= "100111";
					elsif (Input_I < dcI10) and (Input_R > dcR10) then
						aux <= "100011";
					elsif (Input_I > dcI10) and (Input_R < dcR10) then
						aux <= "100110";
					else
						aux <= "100010";
					end if;
			  when "01" => 
					if (Input_I < dcI10) and (Input_R < dcR11) then
							aux <= "101011";
					elsif (Input_I < dcI10) and (Input_R > dcR11) then
						aux <= "101111";
					elsif (Input_I > dcI10) and (Input_R < dcR11) then
						aux <= "101010";
					else
						aux <= "101110";
					end if;
			  when "10" => 
					if (Input_I < dcI11) and (Input_R < dcR10) then
							aux <= "100100";
					elsif (Input_I < dcI11) and (Input_R > dcR10) then
						aux <= "100000";
					elsif (Input_I > dcI11) and (Input_R < dcR10) then
						aux <= "100101";
					else
						aux <= "100001";
					end if;
			  when "11" => 
					if (Input_I < dcI11) and (Input_R < dcR11) then
							aux <= "101000";
					elsif (Input_I < dcI11) and (Input_R > dcR11) then
						aux <= "101100";
					elsif (Input_I > dcI11) and (Input_R < dcR11) then
						aux <= "101001";
					else
						aux <= "101101";
					end if;
				WHEN OTHERS => 
					aux <= "000000";
		end case C0;

	end process;
	
	SymbolAdrr <= aux;
		
END Struct;