-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY interpLinearB0 IS
   GENERIC(
	    Input_int   : integer := 4;
	    Input_frac  : integer := 6;
	    Output_int  : integer := 4;
	    Output_frac : integer := 6		
   );
   PORT( 
      clk       : IN     std_logic;
      clk_en    : IN     std_logic;
	   mFactor0   : IN     std_logic_vector (Input_int+Input_frac-1 DOWNTO 0);
		mFactor1   : IN     std_logic_vector (Input_int+Input_frac-1 DOWNTO 0);
      Input0 	: IN     std_logic_vector (Input_int+Input_frac-1 DOWNTO 0);
      Input1   	: IN     std_logic_vector (Input_int+Input_frac-1 DOWNTO 0);
      Output  	: OUT    std_logic_vector ((Output_int+Output_frac)-1 Downto 0)
   );
END interpLinearB0;


ARCHITECTURE Struct OF interpLinearB0 IS
	
   SIGNAL outMult0, outMult1   : std_logic_vector(2*(Input_int+Input_frac)-1 DOWNTO 0);
   SIGNAL outAdder 		: std_logic_vector(2*(Input_int+Input_frac)+1-1 DOWNTO 0);
BEGIN
	   	        
   U_M0 : entity work.Multiplier_IT
	GENERIC MAP (
		NbitsIn 	=> Input_int+Input_frac,
		NbitsOut 	=> 2*(Input_int+Input_frac),
		Index 		=> 0
		)
	  PORT MAP (
		 clk    => clk,
		 clk_en => clk_en,
		 input1 => mFactor0,
		 input2 => Input0,
		 result => outMult0
	  );
	
	U_M1 : entity work.Multiplier_IT
	GENERIC MAP (
		NbitsIn 	=> Input_int+Input_frac,
		NbitsOut 	=> 2*(Input_int+Input_frac),
		Index 		=> 0
		)
	  PORT MAP (
		 clk    => clk,
		 clk_en => clk_en,
		 input1 => mFactor1,
		 input2 => Input1,
		 result => outMult1
	  );
			
   U_2 : entity work.Adder_IT
	  GENERIC MAP (
		 NBitsIn  	=> 2*(Input_int+Input_frac),
		 NBitsOut 	=> 2*(Input_int+Input_frac)+1,
		 Index		=> 1
	  )
	  PORT MAP (
		 input1 	=> outMult0,
		 input2 	=> outMult1,
		 result 	=> outAdder
	  );
	Output <= outAdder(Input_int+2*Input_frac-1 downto Input_frac);
END Struct;