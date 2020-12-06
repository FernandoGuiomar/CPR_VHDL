-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
use ieee.numeric_std.ALL;
use ieee.math_real.all;
---------------------------------------------------------

ENTITY DecisionCircuit64QAM IS
   GENERIC( 
      Input_int   	: integer := 2;
	  Input_frac  	: integer := 12;
	  AdrrWidth 	: integer := 6
   );
   PORT( 
      clk         	: IN  std_logic;
      clk_en      	: IN  std_logic;
	  Input_R 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
      Input_I 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	  DecodeSymAdrr : OUT std_logic_vector (AdrrWidth-1 DOWNTO 0)
   );
END DecisionCircuit64QAM;

ARCHITECTURE Struct OF DecisionCircuit64QAM IS
	
	signal Input_R_rg, Input_I_rg 					 : std_logic_vector((Input_int+Input_frac)-1 downto 0) := (others=>'0');
	signal SymAdrr0	, SymAdrr1, SymAdrr2, SymAdrr3	 : std_logic_vector(AdrrWidth-1 downto 0) := (others=>'0');
	signal QuadNumber_fd, Q0,Q1,Q2,Q3 				 : std_logic_vector(1 downto 0) := (others=>'0');

		 
BEGIN
	
	
	 
	U_FQ : entity work.FindQuad
     GENERIC MAP( 
	  QuadNbits 	=> 2
     )
     PORT MAP( 
      clk 		 => clk,
	  clk_en 	 => clk_en,
      Sign_I 	 => Input_I(Input_int+Input_frac-1),
      Sign_R 	 => Input_R(Input_int+Input_frac-1),
      QuadNumber => QuadNumber_fd
     );
	
	U_FQ0 : entity work.FindSubQuad064QAM
     GENERIC MAP( 
	  Input_int   	=> Input_int,
	  Input_frac  	=> Input_frac,
	  QuadNbits 	=> 2
	  )
     PORT MAP( 
      clk 		   => clk,
	  clk_en 	   => clk_en,
      Input_I 	   => Input_I,
      Input_R 	   => Input_R,
	  QuadNumber   => Q0
	  );

	U_FQ1 : entity work.FindSubQuad164QAM
     GENERIC MAP( 
	  Input_int   	=> Input_int,
	  Input_frac  	=> Input_frac,
	  QuadNbits 	=> 2
	  )
     PORT MAP( 
      clk 		   => clk,
	  clk_en 	   => clk_en,
      Input_I 	   => Input_I,
      Input_R 	   => Input_R,
	  QuadNumber   => Q1
	  );
	  
	 U_FQ2 : entity work.FindSubQuad264QAM
     GENERIC MAP( 
	  Input_int   	=> Input_int,
	  Input_frac  	=> Input_frac,
	  QuadNbits 	=> 2
	  )
     PORT MAP( 
      clk 		   => clk,
	  clk_en 	   => clk_en,
      Input_I 	   => Input_I,
      Input_R 	   => Input_R,
	  QuadNumber   => Q2
	  );
	  
	U_FQ3 : entity work.FindSubQuad364QAM
     GENERIC MAP( 
	  Input_int   	=> Input_int,
	  Input_frac  	=> Input_frac,
	  QuadNbits 	=> 2
	  )
     PORT MAP( 
      clk 		   => clk,
	  clk_en 	   => clk_en,
      Input_I 	   => Input_I,
      Input_R 	   => Input_R,
	  QuadNumber   => Q3
	  );
	-------------------------------- Symbol Selection ----------------------------------
	U_SS0 : entity work.SymbolSubQuad064QAM
     GENERIC MAP( 
	  Input_int   	=> Input_int,
	  Input_frac  	=> Input_frac,
	  QuadNbits 	=> 2,
	  AdrrWidth 	=> 6
     )
     PORT MAP( 
      clk 		   => clk,
	  clk_en 	   => clk_en,
      Input_I 	   => Input_I,
      Input_R 	   => Input_R,
	  QuadNumber   => Q0,
      SymbolAdrr   => SymAdrr0
     );
	
	U_SS1 : entity work.SymbolSubQuad164QAM
     GENERIC MAP( 
	  Input_int   	=> Input_int,
	  Input_frac  	=> Input_frac,
	  QuadNbits 	=> 2,
	  AdrrWidth 	=> 6
     )
     PORT MAP( 
      clk 		   => clk,
	  clk_en 	   => clk_en,
      Input_I 	   => Input_I,
      Input_R 	   => Input_R,
	  QuadNumber   => Q1,
      SymbolAdrr   => SymAdrr1
     );
	
	U_SS2 : entity work.SymbolSubQuad264QAM
     GENERIC MAP( 
	  Input_int   	=> Input_int,
	  Input_frac  	=> Input_frac,
	  QuadNbits 	=> 2,
	  AdrrWidth 	=> 6
     )
     PORT MAP( 
      clk 		   => clk,
	  clk_en 	   => clk_en,
      Input_I 	   => Input_I,
      Input_R 	   => Input_R,
	  QuadNumber   => Q2,
      SymbolAdrr   => SymAdrr2
     );
	 
	U_SS3 : entity work.SymbolSubQuad364QAM
     GENERIC MAP( 
	  Input_int   	=> Input_int,
	  Input_frac  	=> Input_frac,
	  QuadNbits 	=> 2,
	  AdrrWidth 	=> 6
     )
     PORT MAP( 
      clk 		   => clk,
	  clk_en 	   => clk_en,
      Input_I 	   => Input_I,
      Input_R 	   => Input_R,
	  QuadNumber   => Q3,
      SymbolAdrr   => SymAdrr3
     );
    
	DecodeSymAdrr <= SymAdrr0 when(QuadNumber_fd="00") else
						  SymAdrr1 when(QuadNumber_fd="01") else
						  SymAdrr2 when(QuadNumber_fd="10") else
						  SymAdrr3;
END Struct;