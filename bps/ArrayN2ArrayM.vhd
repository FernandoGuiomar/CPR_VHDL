
-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

library work;
USE work.constDef_pkg.all;

entity Array2Array is
	Generic (
		Data_width		: integer := 2;
		NsigIn			: integer := 2;
		NsigOut			: integer := 4
	);
	Port ( 
		DataIn 		: in  ArrayIn1;
		Clk 		: in  STD_LOGIC;
		Clk_en 		: in  STD_LOGIC;
		DataOut		: out ArrayOut
	);
end Array2Array;

architecture Behavioral of Array2Array is
	signal Aux_dataTemp : std_logic_vector( NsigOut * Data_width - 1 downto 0):= (others => '0');
begin
	
	-- Read process
	process (Clk)
		variable Aux_dataIn : std_logic_vector( NsigIn * Data_width - 1 downto 0):= (others => '0');
		variable Aux_dataOut : std_logic_vector( NsigOut * Data_width - 1 downto 0):= (others => '0');
	begin
		if rising_edge(Clk) then			
			if Clk_en = '1' then
				for k in 0 to NsigIn-1 loop
					for i in 0 to NsigOut-1 loop
						Aux_dataIn := DataIn(i);
						Aux_dataOut((i+1)*Data_width-1 downto i*Data_width) := Aux_dataIn((k+1)*Data_width-1 downto k*Data_width);
					end loop;
					DataOut(k) <= Aux_dataOut;
				end loop;
			end if;
		end if;
	end process;
end Behavioral;