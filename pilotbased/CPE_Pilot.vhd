LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;
use ieee.math_real.all;

---------------------------------------------------------

ENTITY pilotPhaseEstimation IS
   GENERIC( 
		Input_int   	: integer := 2;
		Input_frac  	: integer := 6;		
		Output_int   	: integer := 4;
		Output_frac  	: integer := 10;
		interp_frac  	: integer := 10;
		AdrrWidthUpC   : integer := 10; -- log2 number of pilots 7,9,10
		NtapPilot		: integer := 4;
		RatePil			: integer := 256;
		Npilot			: integer := 128; -- 520,258,128,64 
		Nsig				: integer := 8
   );
   PORT(
	  clk           : IN     std_logic;
	  clk_en        : IN     std_logic;
     Input_R    	 : IN     std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);	  
	  Input_I	    : IN     std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);
	  Output_R	    : OUT    std_logic_vector (Nsig*(Input_int+Input_frac+0)-1 DOWNTO 0);
	  Output_I	    : OUT    std_logic_vector (Nsig*(Input_int+Input_frac+0)-1 DOWNTO 0)
   );
END pilotPhaseEstimation ;


ARCHITECTURE Struct OF pilotPhaseEstimation IS
	
    SIGNAL Out_compConj  : std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
    SIGNAL clk_en_pilot, clk_en_pilot_rg0, clk_en_pilot_rg1, clk_en_pilot_rg2, clk_en_pilot_rg3  : std_logic := '0';
	SIGNAL Out_reg1		 : std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	signal upCount 		: std_logic_vector(AdrrWidthUpC-1 downto 0) := (others=>'0');
	SIGNAL OutLUTpil_real  : std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	SIGNAL OutLUTpil_imag  : std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	SIGNAL Input_R_D,Input_I_D : std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);
	SIGNAL Cos_temp,Sin_temp : std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);
	signal OutMult_R0	: std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	signal OutMult_I0	: std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	constant pi_over2   : std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0) := "01100101"; 
	signal OutAngle	: std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0) := (others =>'0');
	signal OutAngle_mult	: std_logic_vector (2*(Input_int+Input_frac)-1 DOWNTO 0);
    SIGNAL Out_AvgDist    : std_logic_vector (Nsig*(2*(Input_int+Input_frac))-1 DOWNTO 0);
	 SIGNAL Out_AvgDist_rg    : std_logic_vector (Nsig*(2*(Input_int+Input_frac))-1 DOWNTO 0);
	SIGNAL Out_buffer0    	 : std_logic_vector ((Nsig+NtapPilot-1)*(2*(Input_int+Input_frac))-1 DOWNTO 0);
   SIGNAL Out_buffer1    	 : std_logic_vector (2*(2*Input_int+interp_frac)-1 DOWNTO 0);
	SIGNAL outInterp    	 : std_logic_vector (Nsig*(Input_int+Input_frac+6)-1 DOWNTO 0);
	signal sig_en : std_logic := '0';

BEGIN
		
		 
	U_0 : entity work.CounterRemv_pilot 
	GENERIC MAP (
		   countMax   => RatePil
	    )
	PORT MAP (
		 clk    => clk,
		 sig_en => clk_en_pilot		 
	   );	
		
	U_DB0 : entity work.DelayBit_IT
		GENERIC MAP (
			depth 		 => 2,
			DataWidth 	=> 1
		)
		PORT MAP (
			clk      	=> clk,
			clk_en   	=> clk_en,
			Din  			=> clk_en_pilot,
			Dout	 		=> clk_en_pilot_rg0
		);
				
	U_DB1 : entity work.DelayBit_IT
		GENERIC MAP (
			depth 		 => 4,
			DataWidth 	=> 1
		)
		PORT MAP (
			clk      	=> clk,
			clk_en   	=> clk_en,
			Din  			=> clk_en_pilot,
			Dout	 		=> clk_en_pilot_rg1
		);
	
	U_DB2 : entity work.DelayBit_IT
		GENERIC MAP (
			depth 		 => 5,
			DataWidth 	=> 1
		)
		PORT MAP (
			clk      	=> clk,
			clk_en   	=> clk_en,
			Din  			=> clk_en_pilot,
			Dout	 		=> clk_en_pilot_rg2
		);
	U_DB3 : entity work.DelayBit_IT
		GENERIC MAP (
			depth 		 => 6,
			DataWidth 	=> 1
		)
		PORT MAP (
			clk      	=> clk,
			clk_en   	=> clk_en,
			Din  			=> clk_en_pilot,
			Dout	 		=> clk_en_pilot_rg3
		);
		
	-- delay of 1 clock cycle
	 U_1 : entity work.complexConjLUT
	    GENERIC MAP (
		   Data_width   => Input_frac+Input_int,
		   Addr_width    => 8
	    )
	    PORT MAP (
		   clk    	=> clk,
		   clk_en 	=> clk_en_pilot,
		   Addr   	=> Input_I((Input_int+Input_frac)-1 DOWNTO 0),
		   out_val 	=> Out_compConj
	    );
	
	U_R1 : entity work.Register_IT
		GENERIC MAP (
			DataWidth 	=> (Input_frac+Input_int)
		)
		PORT MAP (
			clk      	=> clk,
			clk_en   	=> clk_en_pilot,
			data_in  	=> Input_R((Input_int+Input_frac)-1 DOWNTO 0),
			data_out 	=> Out_reg1
		);
	U_3 : entity work.up_counter
	    GENERIC MAP (
		   Data_width   => AdrrWidthUpC
	    )
	    PORT MAP (
		   clk    	=> clk,
		   clk_en 	=> clk_en_pilot,
		   cout 		=> upCount
	    );
	U_ROM : entity work.LutPilotsSymb 
	  GENERIC MAP( 
         Data_width  => Input_int + Input_frac,
	      Addr_width  => AdrrWidthUpC,
			Npilot  		=> Npilot
	  )
	  PORT MAP(
		 clk 			=> clk,
	    clk_en 		=> clk_en_pilot, 
		 Addr    	=> upCount,
		 out_real   => OutLUTpil_real,
		 out_imag 	=> OutLUTpil_imag     
	  );	
	   
	ID_CM0: FOR i IN 0 TO 1-1 GENERATE
	   BEGIN
		  U_20 : entity work.ComplexMultiplier_IT
			 GENERIC MAP (
					NBits    => Input_int+Input_frac,
					Index		=> 2,
					IndexM	=> 3
			 )
			 PORT MAP (
				clk      => clk,
				clk_en   => clk_en,
				Input_Rx => OutLUTpil_real((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
				Input_Ix => OutLUTpil_imag((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
				Input_Ry => Out_reg1((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
				Input_Iy => Out_compConj((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
				Output_R => OutMult_R0((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
				Output_I => OutMult_I0((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac))
			 );
	   END GENERATE ID_CM0;
	
	U_CA : entity work.ComplexToAngle_IT
		generic map (
				NBits 		=> Input_int+Input_frac
		)														-- 1 = PI/2, 2 = PI
		port map (
				clk      => clk,
				clk_en   => clk_en_pilot_rg0,
				Input_R	=> OutMult_R0,
				Input_I  =>	OutMult_I0,
				Result   => OutAngle
			);	
	
	U_M0 : entity work.Multiplier_IT
		GENERIC MAP (
			NbitsIn 	=> (Input_int+Input_frac),
			NbitsOut 	=> (Input_int+Input_frac)*2,
			Index 		=> 1
			)
		  PORT MAP (
			 clk    => clk,
			 clk_en => clk_en,
			 input1 => pi_over2,
			 input2 => OutAngle,
			 result => OutAngle_mult
		  );
	
	U_B0 : entity work.Buffer_IT
      GENERIC MAP (
					NBits 			=> (Input_int+Input_frac)*2,
					NSamplesIn  	=> 1,
					NSamplesOut 	=> NtapPilot + Nsig - 1
			)
	  PORT MAP (
					clk    		=> clk,
					clk_en 		=> clk_en_pilot_rg1,
					Data_in		=> OutAngle_mult,
					Data_out	=> Out_buffer0
	  );
	  
	U_AVG : for I in 0 to Nsig-1 generate
		U_AV : entity work.Average_IT
		 GENERIC MAP (
			NBits  =>  (Input_int+Input_frac)*2,
			NSamples =>  NtapPilot,
			Index =>  0
		 )
		 PORT MAP (
		  A  				=> Out_buffer0((I+NtapPilot)*((Input_int+Input_frac)*2) -1 DOWNTO I*((Input_int+Input_frac)*2)),
		  Y 				=> Out_AvgDist((I+1)*((Input_int+Input_frac)*2) -1 DOWNTO I*((Input_int+Input_frac)*2))
		);		
	 end generate;  
	
	U_B1 : entity work.Buffer_IT
      GENERIC MAP (
					NBits 			=> 2*Input_int+interp_frac,
					NSamplesIn  	=> 1,
					NSamplesOut 	=> 2
			)
	  PORT MAP (
					clk    		=> clk,
					clk_en 		=> clk_en_pilot_rg2,
					Data_in		=> Out_AvgDist(2*(Input_int+Input_frac)-1 downto 2*Input_frac-interp_frac),
					Data_out		=> Out_buffer1
	  );
	 
	 	U_CE : entity work.Counter_En
			GENERIC MAP (
				 delayEnbl 		 => 3*RatePil+4+RatePil				 
			 )
		  port map(
					clk 	 => clk,
					sig_en => sig_en
				);

   U_IL : entity work.interpLinearB1 
		GENERIC MAP( 
			Input_int   	=> Input_int*2,
			Input_frac   	=> interp_frac,
			Output_int   	=> Input_int*2,
			Output_frac  	=> interp_frac,
			Rpil				=> RatePil,
			Nsig		      => Nsig
	  )
		PORT MAP (
          clk 			=> clk,
          clk_en 		=> sig_en,			 
          Input0 		=> Out_buffer1(2*Input_int+interp_frac-1 downto 0),
          Input1 		=> Out_buffer1(2*(2*Input_int+interp_frac)-1 downto 2*Input_int+interp_frac),
          Output 		=> outInterp
        );

	U_Exp : for I in 0 to Nsig-1 generate
		U_ROM2 : entity work.CExpLutPilot_File 
		  GENERIC MAP( 
				Data_width  => Input_int+Input_frac,
				Addr_width  => 2*Input_int+interp_frac
		  )
		  PORT MAP(
			 clk 		=> clk,
			 clk_en 	=> clk_en, 
			 Addr    => outInterp((I+1)*(2*Input_int+interp_frac)-1 DOWNTO I*(2*Input_int+interp_frac)),
			 Cos_out   => Cos_temp((I+1)*(Input_int+Input_frac)-1 DOWNTO I*(Input_int+Input_frac)),  
			 Sin_out   => Sin_temp((I+1)*(Input_int+Input_frac)-1 DOWNTO I*(Input_int+Input_frac))  
		  );
	end generate;
	
   U_D0 : entity work.Delay_IT
      GENERIC MAP (
         depth     => 2*RatePil+4+RatePil+4+1,
         Datawidth => Nsig*(Input_int+Input_frac)
      )
      PORT MAP (
         clk    => clk,
         clk_en => clk_en,
         Din    => Input_R,
         Dout   => Input_R_D
      );
		
   U_D1 : entity work.Delay_IT
      GENERIC MAP (
         depth     => 2*RatePil+4+RatePil+4+1,
         Datawidth => Nsig*(Input_int+Input_frac)
      )
      PORT MAP (
         clk    => clk,
         clk_en => clk_en,
         Din    => Input_I,
         Dout   => Input_I_D
      );
		
		
   ID_CM1: FOR i IN 0 TO Nsig-1 GENERATE
   BEGIN
      U_20 : entity work.ComplexMultiplier_IT
         GENERIC MAP (
				NBits    => Input_int+Input_frac,
				Index		=> 2,
				IndexM	=> 3
         )
         PORT MAP (
            clk      => clk,
            clk_en   => clk_en,
            Input_Rx => Input_R_D((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
            Input_Ix => Input_I_D((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
            Input_Ry => Cos_temp((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
            Input_Iy => Sin_temp((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
				Output_R => Output_R((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
            Output_I => Output_I((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac))
         );
   END GENERATE ID_CM1;
	
END Struct;