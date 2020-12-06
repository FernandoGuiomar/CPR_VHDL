-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;
use ieee.math_real.all;

---------------------------------------------------------

ENTITY SquaredError IS
   GENERIC( 
		Input_int   	: integer := 2;
		Input_frac  	: integer := 6;
		Dist_int   		: integer := 2;
		Dist_frac  		: integer := 14;
		plusBit  		: integer := 6;
		AdrrWidth  		: integer := 2
   );
   PORT( 
      Input_re    	: IN     std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);	  
	  Input_im	    : IN     std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	  Tphase_re     : IN     std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);	  
	  Tphase_im	    : IN     std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	  clk           : IN     std_logic;
	  clk_en        : IN     std_logic;
	  Output_dist   : OUT    std_logic_vector ((Dist_int+Dist_frac)-1 DOWNTO 0)
   );
END SquaredError ;


ARCHITECTURE Struct OF SquaredError IS
	
   SIGNAL Input_re_rg   : std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
   SIGNAL Input_im_rg   : std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
   SIGNAL Out_re_cm     : std_logic_vector ((Input_int+Input_frac+plusBit)-1 DOWNTO 0);
   SIGNAL Out_im_cm     : std_logic_vector ((Input_int+Input_frac+plusBit)-1 DOWNTO 0);
   SIGNAL Out_re_dc     : std_logic_vector ((Input_int+Input_frac+plusBit)-1 DOWNTO 0);
   SIGNAL Out_im_dc     : std_logic_vector ((Input_int+Input_frac+plusBit)-1 DOWNTO 0);
   SIGNAL Out_re_cm_dl  : std_logic_vector ((Input_int+Input_frac+plusBit)-1 DOWNTO 0);
   SIGNAL Out_im_cm_dl  : std_logic_vector ((Input_int+Input_frac+plusBit)-1 DOWNTO 0);
   SIGNAL Out_re_sb    	: std_logic_vector ((Input_int+Input_frac+plusBit)-1 DOWNTO 0);
   SIGNAL Out_im_sb    	: std_logic_vector ((Input_int+Input_frac+plusBit)-1 DOWNTO 0);
   SIGNAL Out_abs     	: std_logic_vector ((Dist_int+Dist_frac)-1 DOWNTO 0);
   signal SymAdrr 		: std_logic_vector(AdrrWidth-1 downto 0) := (others=>'0');

	
BEGIN
	
	U_CM : entity work.ComplexMultiplierN_Signed
	  GENERIC MAP (
		 Input_fracCM   => Input_frac,
		 Input_intCM    => Input_int,
		 Output_fracCM  => Input_frac+plusBit,
		 Output_intCM   => Input_int
	  )
	  PORT MAP (
		 clk    => clk,
		 clk_en => clk_en,
		 input_re1 => Input_re,
		 input_img1 => Input_im,
		 input_re2 => Tphase_re,
		 input_img2 => Tphase_im,
		 result_re => Out_re_cm,
		 result_img => Out_im_cm
	   );	
		
	-- delay of 1 clock cycle
	U_DC0 : entity work.DecisionCircuit64QAM
	   GENERIC MAP (
		  Input_frac   => Input_frac+plusBit,
		  Input_int    => Input_int,
		  AdrrWidth    => AdrrWidth
	   )
	   PORT MAP (
		  clk    	=> clk,
		  clk_en 	=> clk_en,
		  Input_R   => Out_re_cm,
		  Input_I 	=> Out_im_cm,
		  DecodeSymAdrr	=> SymAdrr
	   );

		 
	 U_ROM : entity work.ROM_IQmap_Sel 
	  GENERIC MAP( 
         Data_width  => Input_int + Input_frac + plusBit,
	      Addr_width  => AdrrWidth
	  )
	  PORT MAP(
		 clk 		=> clk,
	    clk_en 	=> clk_en, 
		 Addr    => SymAdrr,
		 Data1   => Out_re_dc,
		 Data2 	=> Out_im_dc     
	  );	
		
	 D_0 : entity work.Delay_IT
       GENERIC MAP (
          depth 		 => 1,
			 Datawidth	 => (Input_int + Input_frac + plusBit)
			 )
		 PORT MAP(	
			 clk 		=> clk,
			 clk_en 	 	=> clk_en,
			 Din		 	=> Out_re_cm,
			 Dout 		=> Out_re_cm_dl
       );
		
	 D_1 : entity work.Delay_IT
       GENERIC MAP (
          depth 		 => 1,
			 Datawidth	 => (Input_int + Input_frac + plusBit)
			 )
		 PORT MAP(	
			 clk 		=> clk,
			 clk_en 	 	=> clk_en,
			 Din		 	=>  Out_im_cm,
			 Dout 		=> Out_im_cm_dl
       );
	
	U_S0 : entity work.Subtractor_IT
	  GENERIC MAP (
		 NBitsIn  => Input_int + Input_frac + plusBit,
		 NBitsOut => Input_int + Input_frac + plusBit,
		 Index    => 1
	  )
	  PORT MAP (
		 input1 => Out_re_cm_dl,
		 input2 => Out_re_dc,
		 result => Out_re_sb
	  );
		  
	U_S1 : entity work.Subtractor_IT
	  GENERIC MAP (
		 NBitsIn  => Input_int + Input_frac + plusBit,
		 NBitsOut => Input_int + Input_frac + plusBit,
		 Index    => 1
	  )
	  PORT MAP (
		 input1 => Out_im_cm_dl,
		 input2 => Out_im_dc,
		 result => Out_im_sb
	  );	  
	  
	U_Abs0 : entity work.AbsCValue2 
    GENERIC MAP ( 
      Input_int   => Input_int,
	  Input_frac   => Input_frac + plusBit,
      Output_int  => Dist_int,
	  Output_frac  => Dist_frac
    )
    PORT MAP ( 
       clk         	=> clk,
       clk_en      	=> clk_en,
	    Input_re   	=> Out_re_sb,
       Input_im  	=> Out_im_sb,
	    Result  	=> Out_abs
    );
    
	U_R1 : entity work.Register_IT
		GENERIC MAP (
			DataWidth 	=> (Dist_int+Dist_frac)
		)
		PORT MAP (
			clk      	=> clk,
			clk_en   	=> clk_en,
			data_in  	=> Out_abs,
			data_out 	=> Output_dist
		);
	 
END Struct;