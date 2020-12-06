-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;


 
ENTITY pilotPhaseEstimation_tb IS
GENERIC( 
      Input_int   	: integer := 2;
		Input_frac  	: integer := 6;		
		Output_int   	: integer := 4;
		Output_frac  	: integer := 10;
		Nsig				: integer := 4
   );
END pilotPhaseEstimation_tb;
 
ARCHITECTURE behavior OF pilotPhaseEstimation_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pilotPhaseEstimation
    PORT(
        clk           : IN     std_logic;
		  clk_en        : IN     std_logic;
		  Input_R    	 : IN     std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);	  
		  Input_I	    : IN     std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);
		  Output_R	    : OUT    std_logic_vector (Nsig*(Input_int+Input_frac+nTempM)-1 DOWNTO 0);
		  Output_I	    : OUT    std_logic_vector (Nsig*(Input_int+Input_frac+nTempM)-1 DOWNTO 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal clk_en : std_logic := '1';
   signal Input_I : std_logic_vector(Nsig*(Input_int+Input_frac)-1 downto 0) := (others => '0');
   signal Input_R : std_logic_vector(Nsig*(Input_int+Input_frac)-1 downto 0) := (others => '0');

 	--Outputs
   signal Output_R : std_logic_vector(Nsig*(Input_int+Input_frac+nTempM)-1 downto 0);
	signal Output_I : std_logic_vector(Nsig*(Input_int+Input_frac+nTempM)-1 downto 0);
	
	signal out0 : std_logic_vector(Input_int+Input_frac-1 downto 0);
	signal out1 : std_logic_vector(Input_int+Input_frac-1 downto 0);
	signal out2 : std_logic_vector(Input_int+Input_frac-1 downto 0);
	signal out3 : std_logic_vector(Input_int+Input_frac+nTempV-1 downto 0);
	signal Output_Ph : std_logic_vector(Input_int+Input_frac+nTempM-1 downto 0);
	
	constant kx : integer := 6;
   -- Clock period definitions
   constant clk_period : time := 20 ps;
   --constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pilotPhaseEstimation PORT MAP (
          clk => clk,
          clk_en => clk_en,
          Input_R => Input_R,
          Input_I => Input_I,
          Output_R => Output_R,
		  Output_I => Output_I
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
 

   -- Stimulus process
   process
		--begin		

		--ficheiros com as componentes
		file file_pointer_Input_re, file_pointer_Input_img, file_pointer_Output_re, file_pointer_Output_img, file_pointer_Output_re_bit : text; 
		file file_pointer_Output0, file_pointer_Output1, file_pointer_Output2, file_pointer_Output3,file_pointer_Output4 : text; 	
		--ponteiros de linha
		variable line_pointer_Input_re, line_pointer_Input_img: line;
		variable line_pointer_Output_re, line_pointer_Output_img, line_pointer_Output0, line_pointer_Output1, line_pointer_Output2, line_pointer_Output3,line_pointer_Output4: line;	
		variable line_pointer_Output_re_bit: line;
		--informação retirada da linha
		variable var_input_re, var_input_img : integer := 0;

		
		--variáveis
		variable var_Inputs_Real, var_Inputs_Imag	: std_logic_vector(Nsig*(Input_int+Input_frac)-1 downto 0) := (others => '0');
		variable var_Outputs_Real, var_Outputs_Imag, var_Outputs0, var_Outputs1, var_Outputs2, var_Outputs3,var_Outputs4	: integer := 0;
		
		Variable Count : Integer := 0;		
		constant file_length : real := 40000.0;
		--constant file_length : real := 400.0;
		variable loop_cout : integer := integer(ceil((file_length/real(Nsig))))+1;
	begin
	
	
		--abrir vectores com as componentes dos sinais X e Y canais para leitura
		file_open(file_pointer_Input_re, string'(".\..\..\..\Matlab_Functions\Input_64QAM_R_PR64_PtoB.txt"), READ_MODE);
		file_open(file_pointer_Input_img, string'(".\..\..\..\Matlab_Functions\Input_64QAM_I_PR64_PtoB.txt"), READ_MODE);
		
		--file_open(file_pointer_Input_re, string'("C:\Users\csmartins\Dropbox\_PhD\MyWorks\VHDL\Matlab_Functions\Input_16QAM_R_PR128_P1.txt"), READ_MODE);
		--file_open(file_pointer_Input_img, string'("C:\Users\csmartins\Dropbox\_PhD\MyWorks\VHDL\Matlab_Functions\Input_16QAM_I_PR128_P1.txt"), READ_MODE);
						
		--abrir vectores de escrita
		file_open(file_pointer_Output_re, string'(".\..\..\..\Matlab_Functions\Output_64QAM_R_PR64_PtoB.txt"), WRITE_MODE);
		file_open(file_pointer_Output_img, string'(".\..\..\..\Matlab_Functions\Output_64QAM_I_PR64_PtoB.txt"), WRITE_MODE);
		
		file_open(file_pointer_Output4, string'(".\..\..\..\Matlab_Functions\Output_16PR256_Ph.txt"), WRITE_MODE); 
		
        file_open(file_pointer_Output0, string'(".\..\..\..\Matlab_Functions\Output0_64QAM_PR64_PtoB.txt"), WRITE_MODE); 
		file_open(file_pointer_Output1, string'(".\..\..\..\Matlab_Functions\Output1_64QAM_PR64_PtoB.txt"), WRITE_MODE); 
	    file_open(file_pointer_Output2, string'(".\..\..\..\Matlab_Functions\Output2_64QAM_PR64_PtoB.txt"), WRITE_MODE); 
		file_open(file_pointer_Output3, string'(".\..\..\..\Matlab_Functions\Output3_64QAM_PR64_PtoB.txt"), WRITE_MODE); 
		--fazer o loop e gravar a informação agora
		for i in 0 to loop_cout loop		
		
			for counter in 0 to Nsig-1 loop	
			
				--if(not endfile(file_pointer_Input_re)) then
					
					readline(file_pointer_Input_re,line_pointer_Input_re);
					readline(file_pointer_Input_img,line_pointer_Input_img);
					read(line_pointer_Input_re, var_input_re);
					read(line_pointer_Input_img, var_input_img);
															
					var_Inputs_Real((counter+1) * (Input_int+Input_frac)-1 downto counter * (Input_int+Input_frac)) := std_logic_vector(to_signed(var_input_re, (Input_int+Input_frac)));
					var_Inputs_Imag((counter+1) * (Input_int+Input_frac)-1 downto counter * (Input_int+Input_frac)) := std_logic_vector(to_signed(var_input_img, (Input_int+Input_frac)));
												
				 --end if;
			  end loop;			
			
			--atribuir as entradas

			Input_R <= var_Inputs_Real;
			Input_I <= var_Inputs_Imag;
						
			-- esperar por 1 período de clock
			wait for 1*clk_period;
			
			for counter in 0 to Nsig-1 loop

					--retirar as saídas e armazenar num ficheiro
				
				var_Outputs_Real := conv_integer(Output_R((counter+1) * (Input_int+Input_frac+kx)-1 downto counter * (Input_int+Input_frac+kx)));	
				var_Outputs_Imag := conv_integer(Output_I((counter+1) * (Input_int+Input_frac+kx)-1 downto counter * (Input_int+Input_frac+kx)));					
				write(line_pointer_Output_re, var_Outputs_Real);
				writeline(file_pointer_Output_re, line_pointer_Output_re);
				write(line_pointer_Output_img, var_Outputs_Imag);
				writeline(file_pointer_Output_img, line_pointer_Output_img);
				
				var_Outputs4 := conv_integer(Output_Ph((counter+1) * (Input_int+Input_frac+kx)-1 downto counter * (Input_int+Input_frac+kx)));	
				write(line_pointer_Output4, var_Outputs4);
				writeline(file_pointer_Output4, line_pointer_Output4);
				
				var_Outputs0 := conv_integer(Out0((counter+1) * (Input_int+Input_frac)-1 downto counter * (Input_int+Input_frac)));	
				write(line_pointer_Output0, var_Outputs0);
				writeline(file_pointer_Output0, line_pointer_Output0);
				
				var_Outputs1 := conv_integer(Out1((counter+1) * (Input_int+Input_frac)-1 downto counter * (Input_int+Input_frac)));	
				write(line_pointer_Output1, var_Outputs1);
				writeline(file_pointer_Output1, line_pointer_Output1);
				
				var_Outputs2 := conv_integer(Out2((counter+1) * (Input_int+Input_frac)-1 downto counter * (Input_int+Input_frac)));	
				write(line_pointer_Output2, var_Outputs2);
				writeline(file_pointer_Output2, line_pointer_Output2);
				
				var_Outputs3 := conv_integer(Out3((counter+1) * (Input_int+Input_frac)-1 downto counter * (Input_int+Input_frac)));	
				write(line_pointer_Output3, var_Outputs3);
				writeline(file_pointer_Output3, line_pointer_Output3);
				
			END LOOP;
			
		 end loop;
		
		wait;
   end process;

END;

