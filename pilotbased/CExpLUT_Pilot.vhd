-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;


entity CExpLutPilot_File is
GENERIC( 
		Data_width  : integer := 10;
	    Addr_width   : integer :=10
  );
port (
		clk    : in std_logic;
		clk_en : in std_logic;
		Addr   : in std_logic_vector (Addr_width-1 DOWNTO 0);      
		Cos_out  : out std_logic_vector (Data_width-1 DOWNTO 0);       
		Sin_out 	: out std_logic_vector (Data_width-1 DOWNTO 0) 
	);	
end CExpLutPilot_File;


architecture BEHAVIOR of CExpLutPilot_File is

	constant n_words: integer := 2**Addr_width;
	
	subtype memoryData is std_logic_vector(Data_width-1 DOWNTO 0);
	type tmemory is array (0 to n_words-1) of memoryData;
	
	impure function init_mem(mif_file_name : in string) return tmemory is
		 file mif_file : text open read_mode is mif_file_name;
		 variable mif_line : line;
		 variable temp_int_v : integer := 0;
		 variable temp_mem : tmemory;
	 begin
		 for i in 0 to n_words-1 loop
			 readline(mif_file, mif_line);
	
			 read(mif_line, temp_int_v);
			 temp_mem(i) := std_logic_vector(to_signed(temp_int_v, Data_width));
			
		 end loop;
		 return temp_mem;
	 end function;
	
	constant s_tmemory1 : tmemory := init_mem(".\..\..\..\Matlab_Functions\CExp_cos_10_14.txt");
	constant s_tmemory2 : tmemory := init_mem(".\..\..\..\Matlab_Functions\CExp_sin_10_14.txt");
		
	begin -- BEHAVIOR
		process (Clk)
			variable Cos_aux,Sin_aux : std_logic_vector(Data_width-1 DOWNTO 0):= (others => '0');
			begin -- process
			if(rising_edge(clk)) then
				if(clk_en = '1') then					
					Cos_aux := s_tmemory1(to_integer(unsigned(Addr)));
					Sin_aux := s_tmemory2(to_integer(unsigned(Addr)));
				end if;
			end if;
			Cos_out <= Cos_aux;
			Sin_out <= Sin_aux;
		end process;
	-- Cos_out <= Cos_out_aux;
	-- Sin_out <= Sin_out_aux;
end BEHAVIOR;

-- fftshift(sin((((-(NFFT/2):(NFFT/2)-1)*(1/(NFFT/(2*R)))*2*pi).^2)*B*L))