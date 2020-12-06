-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;


ENTITY AbsCValue2 IS
   GENERIC( 
      Input_int   : integer := 2;
	  Input_frac  : integer := 6;
      Output_int  : integer := 2;
	  Output_frac : integer := 6
   );
   PORT( 
       clk         	: IN     std_logic;
       clk_en      	: IN     std_logic;
	   Input_re   	: IN     std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
       Input_im  	: IN     std_logic_vector ((Input_int+Input_frac)-1 DOWNTO 0);
	   result  		: OUT    std_logic_vector ((Output_int+Output_frac)-1 DOWNTO 0)
   );

END AbsCValue2 ;


ARCHITECTURE Struct OF AbsCValue2 IS

   SIGNAL Out_adder   		: std_logic_vector(1+2*(Input_int+Input_frac)-1 DOWNTO 0) := (others => '0');
   SIGNAL mult1 			: std_logic_vector(2*(Input_int+Input_frac )-1 DOWNTO 0) := (others => '0');
   SIGNAL mult2 			: std_logic_vector(2*(Input_int+Input_frac)-1 DOWNTO 0) := (others => '0');
	
BEGIN


   -- Instance port mappings.
   U_M0 : entity work.Multiplier_IT
		GENERIC MAP (
			NbitsIn 	=> (Input_int+Input_frac),
			NbitsOut => (Input_int+Input_frac)*2,
			Index 	=> 1
			)
      PORT MAP (
         clk    => clk,
         clk_en => clk_en,
         input1 => Input_re,
         input2 => Input_re,
         result => mult1
      );
	-- Multiplier A^2
   U_M1 : entity work.Multiplier_IT
		GENERIC MAP (
			NbitsIn 	=> (Input_int+Input_frac),
			NbitsOut => (Input_int+Input_frac)*2,
			Index 	=> 1
			)
      PORT MAP (
         clk    => clk,
         clk_en => clk_en,
         input1 => Input_im,
         input2 => Input_im,
         result => mult2
      );
	
	U_1 : entity work.Adder_IT
      GENERIC MAP (
			NbitsIn 	=> (Input_int+Input_frac)*2,
			NbitsOut => (Input_int+Input_frac)*2+1,
			Index 	=> 0
      )
      PORT MAP (
         input1 => mult1,
         input2 => mult2,
         result => Out_adder
      );	  
	
	U_E3 : entity work.Expander_NSigned
	 GENERIC MAP (
		  Inputs_int   => Input_int*2+1,
		  Inputs_frac  => Input_frac*2,
		  Outputs_int  => Output_int,
		  Outputs_frac => Output_frac
	 )
	 PORT MAP (
		  Din  => Out_adder,
		  Dout => result
	 );
END Struct;