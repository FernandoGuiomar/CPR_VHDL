
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

ENTITY CpeBPS IS
   GENERIC( 
		Input_int   		: integer := 2;
		Input_frac  		: integer := 6;
		Dist_int   			: integer := 2;
		Dist_frac  			: integer := 14;
		Output_int  		: integer := 2;
		Output_frac 		: integer := 6;
		data_lut_width		: integer := 8;
		Nsig  				: integer := 32;
		NTphase				: integer := 2;
		Ntap				 	: integer := 51;
		L           		: integer := 2
   );
   PORT( 
      Input_re    		: IN     std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);	  
	   Input_im	    		: IN     std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);
      clk              	: IN     std_logic;
      clk_en          	: IN     std_logic;      		
		Output_re    	   : OUT    std_logic_vector (Nsig*(Output_int+Output_frac)-1 DOWNTO 0);
	   Output_im   	   : OUT    std_logic_vector (Nsig*(Output_int+Output_frac)-1 DOWNTO 0)
   );
END CpeBPS ;


ARCHITECTURE Struct OF CpeBPS IS
	
   SIGNAL Input_re_dl, Input_im_dl, Input_re_D, Input_im_D, Cos_temp, Sin_temp	: std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0) := (others =>'0');
   SIGNAL Lut_Out_re 		: std_logic_vector ((NTphase)*(Input_int+Input_frac)-1 DOWNTO 0); 
   SIGNAL Lut_Out_im 		: std_logic_vector ((NTphase)*(Input_int+Input_frac)-1 DOWNTO 0); 
   SIGNAL Out_MinDist    	: std_logic_vector (Nsig*indexWitdh-1 DOWNTO 0) := (others =>'0');
	SIGNAL PhaseOutTemp     : std_logic_vector (Nsig*(TPhaseBit)-1 DOWNTO 0) := (others =>'0');
	SIGNAL PhaseW     		: std_logic_vector (Nsig*(TPhaseBit)-1 DOWNTO 0);
	SIGNAL PhaseW2,PhaseUW, phaseW2_rg  : std_logic_vector (Nsig*TPhaseBit-1 DOWNTO 0);
	SIGNAL Input_reNorm, Input_imNorm	: std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0) := (others =>'0');

	signal Arr_DS 				: ArrayIn1;
	signal Out_DS_memOut 	: ArrayOut;
	
	signal sig_en : std_logic := '0';

BEGIN
	
	D_0 : entity work.Delay_IT
	 GENERIC MAP (
		 depth 		 => 1,
		 Datawidth	 => Nsig*(Input_int+Input_frac)
		 )
	 PORT MAP(	
		 clk 			=> clk,
		 clk_en 	 	=> clk_en,
		 Din		 	=> Input_re,
		 Dout 		=> Input_re_dl
	 );	

	D_1 : entity work.Delay_IT
	 GENERIC MAP (
		 depth 		 => 1,
		 Datawidth	 => Nsig*(Input_int+Input_frac)
		 )
	 PORT MAP(	
		 clk 			=> clk,
		 clk_en 	 	=> clk_en,
		 Din		 	=> Input_im,
		 Dout 		=> Input_im_dl
	);
		
	---------------------------------------------------------------
-------------- LUT Read ---------------------------------------
	
	 U_L0 : entity work.TPhaseExpLut_File 
	   GENERIC MAP (
			 Addr_width   => indexWitdh,
			 Data_width   => data_lut_width,
			 NTphase      => NTphase
       )
	 PORT MAP (
			 clk 		=> clk,
			 clk_en 	=> clk_en,
			 Cos_out 	=> Lut_Out_re,
			 Sin_out 	=> Lut_Out_im   
	   );
	
	U_EPF : for I in 0 to NTphase-1 generate		
	   U_EP : entity work.DistanceAvrg
		GENERIC MAP ( 
					Input_int   	=> Input_int,
					Input_frac   	=> Input_frac,
					Dist_int   		=> Dist_int,
					Dist_frac  		=> Dist_frac,
					AdrrWidth  		=> ROMIQ_AdrrWidth,
					SetBitMult  	=> SetBitMult,
					Nsample  		=> Nsig,
					NtapCPE			=> Ntap,
					Nd					=> Nd
		)
		PORT MAP ( 
				  Input_re   	=> Input_re_dl,
				  Input_im  	=> Input_im_dl,
				  Tphase_re   	=> Lut_Out_re((I+1)*(data_lut_width) -1 DOWNTO I*(data_lut_width)),
				  Tphase_im  	=> Lut_Out_im((I+1)*(data_lut_width) -1 DOWNTO I*(data_lut_width)),
				  clk          => clk,
				  clk_en       => clk_en,     
				  Out_AvgDist  => Arr_DS(I)
		);				
	end generate;
	
	U_RAM0 : entity work.Array2Array 
		GENERIC MAP (
			Data_width		=> Dist_int+Dist_frac,
			NsigIn			=> Nsig,
			NsigOut			=> NTphase
		)
		PORT MAP ( 
			DataIn 		 => Arr_DS,
			Clk          => clk,
			Clk_en       => clk_en,    
			DataOut		 => Out_DS_memOut
		);
	
	U_MAF : for I in 0 to Nsig-1 generate
		U_MA : entity work.MinArray
		 GENERIC MAP(
			  DataWidth		=> Dist_int+Dist_frac,
			  IndexWidth	=>	indexWitdh,
			  Nsample 			=> NTphase 
			  --L				=> L
		 )
		 PORT MAP( 
			  clk          => clk,
			  clk_en       => clk_en, 
			  A 				=> Out_DS_memOut(I),
			  Y 				=> Out_MinDist((I+1)*(indexWitdh)-1 DOWNTO I*(indexWitdh))
		 );
	end generate; 
	
	U_AdrrF : for I in 0 to Nsig-1 generate
		U_ROM : entity work.TPhaseLut_Sel 
		  GENERIC MAP( 
				Data_width  => TPhaseBit,
				Addr_width  => indexWitdh,
				NTphase     => NTphase
		  )
		  PORT MAP(
			 clk 		=> clk,
			 clk_en 	=> clk_en, 
			 Addr    => Out_MinDist((I+1)*(indexWitdh)-1 DOWNTO I*(indexWitdh)),
			 phaseOut   => phaseW((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit))     
		  );
	end generate; 
	
	
--	U_CE : entity work.Counter_En
--	  port map(
--				clk 	 => clk,
--				sig_en => sig_en
--			);
--	
--	U_MultF : for I in 0 to Nsig-1 generate
--		U_S0 : entity work.ShiftMult 
--		  GENERIC MAP( 
--				NBits  => TPhaseBit
--		  )
--		  PORT MAP(
--			 Input    => phaseW((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit)),
--			 clk 		=> clk,
--			 clk_en 	=> sig_en, 
--			 Output    => phaseW2((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit)) 
--		  );
--		  --phaseOut((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit)) <= phaseW2((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit));
--	end generate;
--
----	U_CE : entity work.Counter_En
----	  port map(
----				clk 	 => clk,
----				sig_en => sig_en
----			);
----	
----	U_FR : for I in 0 to Nsig-1 generate
----		U_Rg : entity work.Register_IT
----			GENERIC MAP (
----				DataWidth => TPhaseBit
----			)
----			PORT MAP (
----				clk      => clk,
----				clk_en   => sig_en,
----				data_in  => phaseW2((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit)),
----				data_out => phaseW2_rg((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit))
----			);
----			phaseOut((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit)) <= phaseW2_rg((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit));
----	end generate;
--	
--	U_0 : entity work.Unwrap_IT3
--		GENERIC MAP (
--			NBitIn 	 	=> TPhaseBit,
--			NBitExt 	 	=> 16,
--			NSamples 	=> Nsig
--		)
--		PORT MAP (
--			PhaseJumpPOS 	=> PhaseJumpPOS,
--			PhaseJumpNEG	=> PhaseJumpNEG,
--			phase_in  		=> phaseW2,	-- in
--			phase_out  		=> phaseUW		-- out
--	);
--	
--	U_DivF : for I in 0 to Nsig-1 generate
--		U_S1 : entity work.ShiftDiv 
--		  GENERIC MAP( 
--				NBits  => TPhaseBit,
--				NBitsOut => DCBits
--		  )
--		  PORT MAP(
--			 Input    => phaseUW((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit)),
--			 clk 		=> clk,
--			 clk_en 	=> clk_en, 
--			 Output    => PhaseOutTemp((I+1)*(DCBits)-1 DOWNTO I*(DCBits)) 
--		  );		  
--		  phaseOut((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit)) <= PhaseOutTemp((I+1)*(TPhaseBit)-1 DOWNTO I*(TPhaseBit));
--	end generate;	
	
	U_Exp : for I in 0 to Nsig-1 generate
		U_ROM2 : entity work.CExpLut_File 
		  GENERIC MAP( 
				Data_width  => Input_int+Input_frac,
				Addr_width  => DCBits
		  )
		  PORT MAP(
			 clk 		=> clk,
			 clk_en 	=> clk_en, 
			 Addr    => phaseW((I+1)*(DCBits) -1 DOWNTO I*(DCBits)),
			 Cos_out   => Cos_temp((I+1)*(Input_int+Input_frac)-1 DOWNTO I*(Input_int+Input_frac)),  
			 Sin_out   => Sin_temp((I+1)*(Input_int+Input_frac)-1 DOWNTO I*(Input_int+Input_frac))  
		  );
	end generate;
	
	-- Equalization
   U_18 : entity work.Delay_IT
      GENERIC MAP (
			depth     => 8+(Ntap-1)/2+4,
         Datawidth => Nsig*(Input_int+Input_frac)
      )
      PORT MAP (
         clk    => clk,
         clk_en => clk_en,
         Din    => Input_re,
         Dout   => Input_re_D
      );
		
   U_19 : entity work.Delay_IT
      GENERIC MAP (
			depth     => 8+(Ntap-1)/2+4,
         Datawidth => Nsig*(Input_int+Input_frac)
      )
      PORT MAP (
         clk    => clk,
         clk_en => clk_en,
         Din    => Input_im,
         Dout   => Input_im_D
      );
		
   ID_4: FOR i IN 0 TO Nsig-1 GENERATE
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
            Input_Rx => Input_re_D((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
            Input_Ix => Input_im_D((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
            Input_Ry => Cos_temp((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
            Input_Iy => Sin_temp((i+1)*(Input_int+Input_frac)-1 DOWNTO i*(Input_int+Input_frac)),
				Output_R => Output_re((i+1)*(Output_int+Output_frac)-1 DOWNTO i*(Output_int+Output_frac)),
            Output_I => Output_im((i+1)*(Output_int+Output_frac)-1 DOWNTO i*(Output_int+Output_frac))
         );
   END GENERATE ID_4;
	
END Struct;