-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY CounterInterp IS
  generic(
		Data_width   : integer := 8;
		countMax 	 : integer := 4
	); 
  port(
		clk    :in  std_logic;                      -- Input clock
		clk_en 	:in  std_logic;
		cout   	:out std_logic_vector (Data_width-1 downto 0) 
		);
END CounterInterp;

ARCHITECTURE Behavioral OF CounterInterp IS

	-- Signals
	signal count :std_logic_vector (Data_width-1 downto 0) := (others => '0');

BEGIN

	process(clk)
		variable varInit : std_logic_vector (Data_width-1 downto 0) := (others => '0');
	begin
		if(rising_edge(clk)) then
			if clk_en = '1' then
				if (count = countMax-1) then
					count <= varInit;
				else	
					count <= count +  1;	
				end if;
			end if;
		end if;		
	end process;
	cout <= count;
END Behavioral;