-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.math_real.all; 

ENTITY interpLinearB1 IS
   GENERIC(
	    Input_int   : integer := 4;
	    Input_frac  : integer := 6;
	    Output_int  : integer := 4;
	    Output_frac : integer := 6;
		 Rpil	 		 : integer := 32;
		 Nsig	 		 : integer := 32
   );
   PORT( 
      clk        : IN     std_logic;
      clk_en     : IN     std_logic;
      Input0 	: IN     std_logic_vector (Input_int+Input_frac-1 DOWNTO 0);
      Input1   	: IN     std_logic_vector (Input_int+Input_frac-1 DOWNTO 0);
      Output  	: OUT    std_logic_vector (Nsig*(Output_int+Output_frac)-1 Downto 0)
   );
END interpLinearB1;


ARCHITECTURE Struct OF interpLinearB1 IS
	
   SIGNAL mFactor0, mFactor1 : std_logic_vector(Nsig*(Input_int+Input_frac)-1 DOWNTO 0);
   SIGNAL Input0_rg, Input1_rg   : std_logic_vector(1*(Input_int+Input_frac)-1 DOWNTO 0);
   SIGNAL outMult0, outMult1   : std_logic_vector(Nsig*(Input_int+Input_frac)-1 DOWNTO 0);
   signal upCount, upCount_rg	: std_logic_vector(integer(ceil(log2(real(Rpil))))-1 downto 0) := (others=>'0');
   
BEGIN
	
   U_C0 : entity work.CounterInterp
	    GENERIC MAP (
		   Data_width   => integer(ceil(log2(real(Rpil)))),
		   countMax 	=> Rpil
	    )
	    PORT MAP (
		   clk    	=> clk,
		   clk_en 	=> clk_en,
		   cout		=> upCount
	    );
	U_R0 : entity work.Register_IT
      GENERIC MAP (
         DataWidth => integer(ceil(log2(real(Rpil))))
      )
      PORT MAP (
         clk      => clk,
         clk_en   => clk_en,
         data_in  => upCount,
         data_out => upCount_rg
      );
		
   U_R1 : entity work.Register_IT
      GENERIC MAP (
         DataWidth => Input_int+Input_frac
      )
      PORT MAP (
         clk      => clk,
         clk_en   => clk_en,
         data_in  => Input0,
         data_out => Input0_rg
      );
	U_R2 : entity work.Register_IT
      GENERIC MAP (
         DataWidth => Input_int+Input_frac
      )
      PORT MAP (
         clk      => clk,
         clk_en   => clk_en,
         data_in  => Input1,
         data_out => Input1_rg
      );
		
		U_ROM : entity work.LutInterpFactorM 
		  GENERIC MAP( 
				Data_width  => Input_int+Input_frac,
			  Addr_width  => integer(ceil(log2(real(Rpil)))),
			  Nsample     => Nsig
		  )
		  PORT MAP(
			 clk 			=> clk,
			  clk_en 	=> clk_en, 
			 Addr    	=> upCount_rg,
			 out0   		=> mFactor0,
			 out1 		=> mFactor1     
		  );
		  
	U_Interp : for I in 0 to Nsig-1 generate  		
		  U_IL : entity work.interpLinearB0 
			GENERIC MAP( 
				Input_int   	=> Input_int,
				Input_frac   	=> Input_frac,
				Output_int   	=> Output_int,
				Output_frac  	=> Output_frac
		  )
			PORT MAP (
				 clk 			=> clk,
				 clk_en 		=> clk_en,
				 mFactor0 	=> mFactor0((I+1)*(Input_int+Input_frac)-1 DOWNTO I*(Input_int+Input_frac)),
				 mFactor1 	=> mFactor1((I+1)*(Input_int+Input_frac)-1 DOWNTO I*(Input_int+Input_frac)),
				 Input0 		=> Input0_rg,
				 Input1 		=> Input1_rg,
				 Output 		=> Output((I+1)*(Output_int+Output_frac)-1 DOWNTO I*(Output_int+Output_frac))
			  );
		end generate;
		
END Struct;