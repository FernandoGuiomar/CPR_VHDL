-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;
use ieee.math_real.all;

---------------------------------------------------------

ENTITY DistanceAvrg IS
   GENERIC( 
		Input_int   	: integer := 2;
		Input_frac  	: integer := 6;
		Dist_int   		: integer := 2;
		Dist_frac  		: integer := 14;
		AdrrWidth  		: integer := 6;
		SetBitMult  	: integer := 6;
		Nsample  		: integer := 1;
		NtapCPE			: integer := 5;
		Nd					: integer := 5
   );
   PORT( 
     Input_re     : IN     std_logic_vector (Nsample*(Input_int+Input_frac)-1 DOWNTO 0);	  
	  Input_im	    : IN     std_logic_vector (Nsample*(Input_int+Input_frac)-1 DOWNTO 0);
	  Tphase_re     : IN     std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);	  
	  Tphase_im	    : IN     std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	  clk           : IN     std_logic;
	  clk_en        : IN     std_logic;
	  Out_AvgDist   : OUT    std_logic_vector ((Nsample)*(Dist_int+Dist_frac)-1 DOWNTO 0)
  );
END DistanceAvrg ;


ARCHITECTURE Struct OF DistanceAvrg IS
  
   SIGNAL Out_distSquare    : std_logic_vector (Nsample*(Dist_int+Dist_frac)-1 DOWNTO 0);
   SIGNAL Out_buffer    	 : std_logic_vector ((Nsample+NtapCPE-1+Nd)*(Dist_int+Dist_frac)-1 DOWNTO 0);
   SIGNAL Out_AvgDist_rg    : std_logic_vector (Nsample*(Dist_int+Dist_frac)-1 DOWNTO 0);
	
BEGIN
    
	U_SDist : for I in 0 to Nsample-1 generate
	   U_SD : entity work.SquaredError
		GENERIC MAP ( 
					Input_int      => Input_int,
					Input_frac     => Input_frac,
					Dist_int       => Dist_int,
					Dist_frac      => Dist_frac,
					plusBit  	   => SetBitMult,
					AdrrWidth      => AdrrWidth
		)
		PORT MAP ( 
				  Input_re   	=> Input_re((I+1)*(Input_int+Input_frac)-1 DOWNTO (I)*(Input_int+Input_frac)),
				  Input_im  	=> Input_im((I+1)*(Input_int+Input_frac)-1 DOWNTO (I)*(Input_int+Input_frac)),
				  Tphase_re   	=> Tphase_re,
				  Tphase_im  	=> Tphase_im,
				  clk           => clk,
				  clk_en        => clk_en,     
				  Output_dist   => Out_distSquare((I+1)*(Dist_int+Dist_frac)-1 DOWNTO (I)*(Dist_int+Dist_frac))
			);
	end generate;
		 
	U_B : entity work.Buffer_IT
      GENERIC MAP (
					NBits 			=> Dist_int+Dist_frac,
					NSamplesIn  	=> Nsample,
					NSamplesOut 	=> NtapCPE + Nsample - 1 + Nd
			)
	  PORT MAP (
					clk    		=> clk,
					clk_en 		=> clk_en,
					Data_in		=> Out_distSquare,
					Data_out		=> Out_buffer
	  );
	  
	U_AVG : for I in 0 to Nsample-1 generate
		U_AV : entity work.Average_IT
		 GENERIC MAP (
			NBits  =>  Dist_int+Dist_frac,
			NSamples =>  NtapCPE,
			Index =>  0
		 )
		 PORT MAP (
		  A  				=> Out_buffer((I+NtapCPE)*(Dist_int+Dist_frac) -1 DOWNTO I*(Dist_int+Dist_frac)),
		  Y 				=> Out_AvgDist((I+1)*(Dist_int+Dist_frac) -1 DOWNTO I*(Dist_int+Dist_frac))
		);		
	 end generate;  

END Struct;