
-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
---------------------------------------------------------

entity DelayBit_IT is
	generic ( depth		: integer :=1;
			Datawidth	: integer :=1
		);
	port(	clk 		: in std_logic;
			clk_en 		: in std_logic;
			Din			: in std_logic;
			Dout 		: out std_logic
		);
			
end DelayBit_IT;

architecture Behavioral of DelayBit_IT is

	signal D_Line: std_logic_vector(depth downto 0):=(others => '0');
begin

	D_Line(0) <= Din;
	dline : for i in 1 to depth generate
	
		process(clk)
		begin
			if(rising_edge(clk)) then
				if(clk_en='1') then
					D_Line(i)<=D_Line(i-1);
				end if;
			end if;
		end process;
		
	end generate;
	
	Dout <= D_Line(depth);
	
end Behavioral;

