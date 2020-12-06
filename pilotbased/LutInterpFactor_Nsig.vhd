-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;


entity LutInterpFactorM is
GENERIC( 
		 Data_width   : integer := 8;
	     Addr_width   : integer := 2;
		 Nsample	      : integer := 4
  );
port (
		clk    		: in std_logic;
		clk_en 		: in std_logic;
		Addr   		: in std_logic_vector  (Addr_width-1 DOWNTO 0);      
		out0  		: out std_logic_vector ((Nsample)*Data_width-1 DOWNTO 0);       
		out1 		: out std_logic_vector ((Nsample)*Data_width-1 DOWNTO 0)
	);	
end LutInterpFactorM;


architecture BEHAVIOR of LutInterpFactorM is

	constant n_words: integer := 2**Addr_width;
	subtype memoryData is std_logic_vector(Data_width-1 DOWNTO 0);
	type tmemory is array (0 to n_words-1) of memoryData;
	
	impure function init_mem(mif_file_name : in string) return tmemory is
		file mif_file : text open read_mode is mif_file_name;
		variable mif_line : line;
		variable temp_int_v : integer := 0;
		variable temp_mem : tmemory;
	begin
		for i in 0 to Nsample-1 loop
			readline(mif_file, mif_line);	
			read(mif_line, temp_int_v);
			temp_mem(i) := std_logic_vector(to_signed(temp_int_v, Data_width));			
		end loop;
		return temp_mem;
	end function;
	
	constant s_tmemory1 : tmemory := init_mem(".\..\..\..\Matlab_Functions\LUT_K0PR64_10_14.txt");
	constant s_tmemory2 : tmemory := init_mem(".\..\..\..\Matlab_Functions\LUT_K1PR64_10_14.txt");

	begin -- BEHAVIOR
		process (Clk)
			variable Aux_data1, Aux_data2 : std_logic_vector( Nsample*Data_width -1 DOWNTO 0):= (others => '0');
			begin -- process
			if(rising_edge(Clk)) then
				if(clk_en = '1') then					
					for i in 0 to Nsample-1 loop
						Aux_data1((i+1)*Data_width-1 downto i*Data_width) := s_tmemory1(i);
						Aux_data2((i+1)*Data_width-1 downto i*Data_width) := s_tmemory2(i);
					end loop;
				end if;
			end if;
			out0 <= Aux_data1;
			out1 <= Aux_data2;
		end process;
		
end BEHAVIOR;