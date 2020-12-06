-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
use ieee.numeric_std.ALL;
use ieee.math_real.all;
---------------------------------------------------------

ENTITY DecisionCircuit16QAM IS
   GENERIC( 
      Input_int   	: integer := 2;
	  Input_frac  	: integer := 12;
	  AdrrWidth 	: integer := 4
   );
   PORT( 
      clk         	: IN  std_logic;
      clk_en      	: IN  std_logic;
	  Input_R 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
      Input_I 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	  DecodeSymAdrr : OUT std_logic_vector (AdrrWidth-1 DOWNTO 0)
   );
END DecisionCircuit16QAM;

ARCHITECTURE Struct OF DecisionCircuit16QAM IS
	
	signal Input_R_rg, Input_I_rg		 : std_logic_vector((Input_int+Input_frac)-1 downto 0) := (others=>'0');
	signal QuadNumber_fd 				 : std_logic_vector(1 downto 0) := (others=>'0');

	
	COMPONENT FindQuad
     GENERIC( 
	  QuadNbits 	: integer := 3
     );
     PORT( 
      clk         	: IN  std_logic;
      clk_en      	: IN  std_logic;
      Sign_I 		: IN  std_logic;
      Sign_R 		: IN  std_logic;
      QuadNumber    : OUT std_logic_vector (QuadNbits-1 DOWNTO 0)
     );
    END COMPONENT;
	
	COMPONENT SymbolSelection
     GENERIC( 
	  Input_int   	: integer := 2;
	  Input_frac  	: integer := 16;
	  QuadNbits 	: integer := 3;
	  AdrrWidth 	: integer := 3
    );
    PORT( 
      clk         	: IN  std_logic;
      clk_en      	: IN  std_logic;
      Input_I 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
      Input_R 		: IN  std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	   QuadNumber    : IN std_logic_vector (QuadNbits-1 DOWNTO 0);
      SymbolAdrr    : OUT std_logic_vector (AdrrWidth-1 DOWNTO 0)
    );
	END COMPONENT;
	
	COMPONENT Register_IT 
	 generic(
				DataWidth 	: integer := 8
			);
	 port(
				clk 			: in std_logic;
				clk_en 		: in std_logic;
				data_in     : in std_logic_vector(DataWidth-1 downto 0);
				data_out    : out std_logic_vector(DataWidth-1 downto 0)
		 );
	 END COMPONENT;
	 
BEGIN
	 
	U_FQ : FindQuad
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
	
	U_SS : SymbolSelection
     GENERIC MAP( 
	  Input_int   	=> Input_int,
	  Input_frac  	=> Input_frac,
	  QuadNbits 	=> 2,
	  AdrrWidth 	=> 4
     )
     PORT MAP( 
      clk 		   => clk,
	  clk_en 	   => clk_en,
      Input_I 	   => Input_I,
      Input_R 	   => Input_R,
	  QuadNumber   => QuadNumber_fd,
      SymbolAdrr   => DecodeSymAdrr
     );

END Struct;