-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use ieee.math_real.all;
use std.textio.all;

entity TPhaseLut_Sel is
GENERIC( 
		 Data_width   : integer := 8;
	    Addr_width   : integer := 2;
		 NTphase      : integer := 4
  );
port (
		clk    	: in std_logic;
		clk_en 	: in std_logic;
		Addr   	: in std_logic_vector  (Addr_width-1 DOWNTO 0);      
		phaseOut  : out std_logic_vector (Data_width-1 DOWNTO 0)
	);	
end TPhaseLut_Sel;

architecture BEHAVIOR of TPhaseLut_Sel is

	constant n_words: integer := 2**Addr_width;
	subtype memoryData is std_logic_vector(Data_width-1 DOWNTO 0);
	type tmemory is array (0 to n_words-1) of memoryData;
	constant phiInt 	: real := 1.5708;
	constant delayBPS : integer := 14+1; -- 8 + Nsig*(Ntap-1)/2 
	signal counter 	: integer := 0;
	

	 impure function init_mem(mif_file_name : in string) return tmemory is
		 file mif_file : text open read_mode is mif_file_name;
		 variable mif_line : line;
		 variable temp_int_v : integer := 0;
		 variable temp_mem : tmemory;
	 begin
		 for i in 0 to NTphase-1 loop
			 readline(mif_file, mif_line);
	
			 read(mif_line, temp_int_v);
			 temp_mem(i) := std_logic_vector(to_signed(temp_int_v, Data_width));
			
		 end loop;
		 return temp_mem;
	 end function;
	 
	 --constant s_tmemory : tmemory := init_mem(".\..\..\..\Matlab_Functions\phaseTest32_7_14.txt");
	 --constant s_tmemory : tmemory := init_mem(".\..\..\..\Matlab_Functions\phaseTest16_9_14.txt");
	 constant s_tmemory : tmemory := init_mem(".\..\..\..\Matlab_Functions\phaseTest3_9_14.txt");

	begin -- BEHAVIOR
		process (Clk)
			variable Aux_data : std_logic_vector(Data_width -1 DOWNTO 0):= (others => '0');
			begin -- process
			if(rising_edge(Clk)) then
				if(clk_en = '1') then
					if (counter = delayBPS-1) then
						counter <= delayBPS-1;
						Aux_data := s_tmemory(to_integer(unsigned(Addr)));
					else
						counter <= counter + 1;					
					end if;					
				end if;
			end if;
			phaseOut <= Aux_data;
		end process;
		
end BEHAVIOR;