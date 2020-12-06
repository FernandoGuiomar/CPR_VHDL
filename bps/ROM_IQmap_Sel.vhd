-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use ieee.math_real.all;
use std.textio.all;

entity ROM_IQmap_Sel is
GENERIC( 
       Data_width  : integer := 8;
	    Addr_width  : integer := 4
  );
port (
	clk     : in std_logic;
	clk_en  : in std_logic; 
	Addr    : in std_logic_vector (Addr_width-1 DOWNTO 0);  
	Data1   : out std_logic_vector (Data_width-1 DOWNTO 0);         
	Data2 	: out std_logic_vector (Data_width-1 DOWNTO 0)        
	);
	
end ROM_IQmap_Sel;

architecture BEHAVIOR of ROM_IQmap_Sel is

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
function init_mem(sel : in integer) return tmemory is
		variable temp_mem : tmemory;
		constant val1 : real := 0.235;
		constant val2 : real := -0.235;
		constant val3 : real := 0.707;
		constant val4 : real := -0.707;
		constant SCALE : real := 2**(real(Data_width-2));
	begin
		-- 4QAM
--		if (sel=0) then
--			temp_mem(0) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));
--			temp_mem(1) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));
--			temp_mem(2) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));
--			temp_mem(3) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));
--		else
--			temp_mem(0) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));
--			temp_mem(1) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));
--			temp_mem(2) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));
--			temp_mem(3) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));
--		end if;

		-- 16QAM
		if (sel=0) then
			temp_mem(0) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));
			temp_mem(1) := std_logic_vector(to_signed(INTEGER(val3*SCALE),Data_width));
			temp_mem(2) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));
			temp_mem(3) := std_logic_vector(to_signed(INTEGER(val3*SCALE),Data_width));
			temp_mem(4) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));			
			temp_mem(5) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));
			temp_mem(6) := std_logic_vector(to_signed(INTEGER(val4*SCALE),Data_width));
			temp_mem(7) := std_logic_vector(to_signed(INTEGER(val4*SCALE),Data_width));
			temp_mem(8) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));
			temp_mem(9) := std_logic_vector(to_signed(INTEGER(val4*SCALE),Data_width));
			temp_mem(10) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));
			temp_mem(11) := std_logic_vector(to_signed(INTEGER(val4*SCALE),Data_width));
			temp_mem(12) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));
			temp_mem(13) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));
			temp_mem(14) := std_logic_vector(to_signed(INTEGER(val3*SCALE),Data_width));
			temp_mem(15) := std_logic_vector(to_signed(INTEGER(val3*SCALE),Data_width));
		else
			temp_mem(0) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));
			temp_mem(1) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));
			temp_mem(2) := std_logic_vector(to_signed(INTEGER(val3*SCALE),Data_width));
			temp_mem(3) := std_logic_vector(to_signed(INTEGER(val3*SCALE),Data_width));
			temp_mem(4) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));			
			temp_mem(5) := std_logic_vector(to_signed(INTEGER(val3*SCALE),Data_width));
			temp_mem(6) := std_logic_vector(to_signed(INTEGER(val1*SCALE),Data_width));
			temp_mem(7) := std_logic_vector(to_signed(INTEGER(val3*SCALE),Data_width));
			temp_mem(8) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));
			temp_mem(9) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));
			temp_mem(10) := std_logic_vector(to_signed(INTEGER(val4*SCALE),Data_width));
			temp_mem(11) := std_logic_vector(to_signed(INTEGER(val4*SCALE),Data_width));
			temp_mem(12) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));
			temp_mem(13) := std_logic_vector(to_signed(INTEGER(val4*SCALE),Data_width));
			temp_mem(14) := std_logic_vector(to_signed(INTEGER(val2*SCALE),Data_width));
			temp_mem(15) := std_logic_vector(to_signed(INTEGER(val4*SCALE),Data_width));
		end if;
		return temp_mem;
	end;
	
	constant s_tmemory1 : tmemory := init_mem(".\..\..\..\Matlab_Functions\IQMap16QAMPilot_re14bits.txt");
	constant s_tmemory2 : tmemory := init_mem(".\..\..\..\Matlab_Functions\IQMap16QAMPilot_im14bits.txt");
	
	begin -- BEHAVIOR
		process (Clk)
			variable Aux_data1, Aux_data2 : std_logic_vector( Data_width -1 DOWNTO 0):= (others => '0');
			begin -- process
			if(rising_edge(Clk)) then
				if(clk_en = '1') then
					Aux_data1(Data_width-1 downto 0) := s_tmemory1(to_integer(unsigned(Addr)));
					Aux_data2(Data_width-1 downto 0) := s_tmemory2(to_integer(unsigned(Addr)));
				end if;
			end if;
			Data1 <= Aux_data1;
			Data2 <= Aux_data2;
		end process;
	
end BEHAVIOR;