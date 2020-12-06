-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;
use ieee.math_real.all;

library work;
USE work.constDef_pkg.all;
---------------------------------------------------------

ENTITY CpePilotBPS IS
   GENERIC( 
		Input_int   		: integer := 2;
		Input_frac  		: integer := 6;
		Dist_int   			: integer := 2;
		Dist_frac  			: integer := 14;
		Output_int  		: integer := 2;
		Output_frac 		: integer := 6;
		interp_frac  		: integer := 10;
		AdrrWidthUpC   	: integer := 10; -- log2 number of pilots 7,9,10
		NtapPilot			: integer := 4;
		RatePil				: integer := 64;
		Npilot				: integer := 520; -- 520,258,128,64 
		data_lut_width		: integer := 8;
		Nsig  				: integer := 8;
		NTphase				: integer := 2;
		NtapBPS				: integer := 31;
		L           		: integer := 2
   );
   PORT( 
      Input_R    		: IN     std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);	  
	   Input_I	    		: IN     std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);
      clk              	: IN     std_logic;
      clk_en          	: IN     std_logic;      		
		Output_R    	   : OUT    std_logic_vector (Nsig*(Output_int+Output_frac)-1 DOWNTO 0);
	   Output_I   	   : OUT    std_logic_vector (Nsig*(Output_int+Output_frac)-1 DOWNTO 0)
   );
END CpePilotBPS ;


ARCHITECTURE Struct OF CpePilotBPS IS
	
   SIGNAL Output_R_temp, Output_I_temp	: std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0) := (others =>'0');   

BEGIN
    
	-------------------------------	1 Polarization ----------------------------------
	---------------------------------------------------------------------------------
	U0 : entity work.pilotPhaseEstimation 
	GENERIC MAP (
			Input_int		=>	Input_int,
			Input_frac  	=>	Input_frac,
			Output_int   	=>	Output_int,
			Output_frac  	=>	Output_frac,
			interp_frac  	=>	interp_frac,
			AdrrWidthUpC   =>	AdrrWidthUpC,
			NtapPilot		=>	NtapPilot,
			RatePil			=>	RatePil,
			Npilot			=>	Npilot,
			Nsig				=>	Nsig
		)
	PORT MAP (
          clk => clk,
          clk_en => clk_en,
          Input_R => Input_R,
          Input_I => Input_I,
          Output_R => Output_R_temp,
	      Output_I => Output_I_temp
        );
	
	U1 : entity work.CpeBPS 
	GENERIC MAP (
			Input_int		=>	Input_int,
			Input_frac  	=>	Input_frac,
			Dist_int   		=>	Dist_int,
			Dist_frac  		=>	Dist_frac,
			Output_int   	=>	Output_int,
			Output_frac  	=>	Output_frac,
			data_lut_width  =>	data_lut_width,
			Nsig   			=>	Nsig,
			NTphase			=>	NTphase,
			Ntap			=>	NtapBPS,
			L				=>	2
		)
	PORT MAP (				 
		 Input_re => Output_R_temp,
		 Input_im => Output_I_temp,
		 clk 	=> clk,
		 clk_en => clk_en,
		 Output_re => Output_R,
		 Output_im => Output_I
        );
END Struct;