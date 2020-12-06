-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  use std.textio.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned.all;
  use ieee.math_real.all;
  
  library work;
  USE work.constDef_pkg.all;
  
  ENTITY CpeBPS_tb IS
  GENERIC( 
		Input_int   		: integer := 2;
		Input_frac  		: integer := 6;
		Dist_int   			: integer := 2;
		Dist_frac  			: integer := 14;
		Output_int  		: integer := 2;
		Output_frac 		: integer := 6;
		data_lut_width		: integer := 6;
		symAdrr       		: integer := 6;
		Nsig  				: integer := 1
   );
  END CpeBPS_tb;

  ARCHITECTURE behavior OF CpeBPS_tb IS 

  -- Component Declaration
          COMPONENT CpePilotBPS
				PORT( 
				   Input_R    		: IN     std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);	  
					Input_I	    		: IN     std_logic_vector (Nsig*(Input_int+Input_frac)-1 DOWNTO 0);
					clk              	: IN     std_logic;
					clk_en          	: IN     std_logic;  
					Output_R    	   : OUT    std_logic_vector (Nsig*(Output_int+Output_frac)-1 DOWNTO 0);
					Output_I   	   : OUT    std_logic_vector (Nsig*(Output_int+Output_frac)-1 DOWNTO 0)
				);
			  END COMPONENT ;

          --Inputs
		signal Clk_tb 				   : std_logic := '0';
		signal Clk_en_tb 			   : std_logic := '1';
		signal Input_I_tb : std_logic_vector(Nsig*(Input_int+Input_frac)-1 downto 0) := (others => '0');
		signal Input_R_tb : std_logic_vector(Nsig*(Input_int+Input_frac)-1 downto 0) := (others => '0');
		
		--Outputs
		signal Out_MinDist_tb  : std_logic_vector (Nsig*4-1 DOWNTO 0);
		signal Output_re_tb 	  : std_logic_vector(Nsig*(Output_int+Output_frac)-1 downto 0);
		signal Output_im_tb 	  : std_logic_vector(Nsig*(Output_int+Output_frac)-1 downto 0);
      signal phaseOut_tb 	  : std_logic_vector(Nsig*TPhaseBit-1 downto 0) := (others => '0');
	   signal cos_re_tb 	  : std_logic_vector(Nsig*(Output_int+Output_frac)-1 downto 0) := (others => '0');
      signal sin_im_tb 	  : std_logic_vector(Nsig*(Output_int+Output_frac)-1 downto 0) := (others => '0');

		signal OutBits_tb 	  : std_logic_vector(Nsig*symAdrr-1 downto 0) := (others => '0');
		constant indexWitdh 	 		: integer := (integer(ceil(log2(real(NTphase)))));
		
		--constant clk_period : time := 10 ns;
		constant clk_period : time := 20 ps;
		
  BEGIN

  -- Component Instantiation
          uut: CpePilotBPS PORT MAP (
				 
				 Input_R => Input_R_tb,
				 Input_I => Input_I_tb,
				 clk 	=> clk_tb,
				 clk_en => clk_en_tb,
				 Output_R => Output_re_tb,
				 Output_I => Output_im_tb
        );
		
		-- Clock process definitions
		clk_process :process
		begin
			Clk_tb <= '0';
			wait for clk_period/2;
			Clk_tb <= '1';
			wait for clk_period/2;
		end process;

	 

		-- Stimulus process
	process
		--ficheiros com as componentes
		file file_pointer_Input_re, file_pointer_Input_img, file_pointer_cos, file_pointer_sin, file_pointer_Output_re, file_pointer_Output1, file_pointer_Output, file_pointer_Output_img, file_pointer_Output_re_bit, file_pointer_Output_re_bit0,file_pointer_Output_re_bit1,file_pointer_Output_re_bit2,file_pointer_Output_re_bit3,file_pointer_Output_re_bit4,file_pointer_Output_bits : text; 
			
		--ponteiros de linha
		variable line_pointer_Input_re, line_pointer_Input_img: line;
		variable line_pointer_Output_re, line_pointer_Output_img,line_pointer_cos, line_pointer_sin, line_pointer_Output, line_pointer_Output1: line;	
		variable line_pointer_Output_re_bit, line_pointer_Output_bits, line_pointer_Output_re_bit0, line_pointer_Output_re_bit1, line_pointer_Output_re_bit2,line_pointer_Output_re_bit3,line_pointer_Output_re_bit4: line;
		--informação retirada da linha
		variable var_input_re, var_input_img : integer := 0;

		
		--variáveis
		variable var_Inputs_Real, var_Inputs_Imag	: std_logic_vector(Nsig*(Input_int+Input_frac)-1 downto 0) := (others => '0');
		variable var_Outputs_Real, var_Outputs_Imag, var_Outputs_cos, var_Outputs_sin, var_Outputs, var_Outputs1	: integer := 0;
		Variable Count : Integer := 0;	
		
		--constant file_length : real := 131072.0+300.0;
		constant file_length : real := 40000.0;
		variable loop_cout : integer := integer(ceil((file_length/real(Nsig))))+1;
	begin
	
		--abrir vectores com as componentes dos sinais X e Y canais para leitura
		file_open(file_pointer_Input_re, string'(".\..\..\..\Matlab_Functions\Input_64QAM_R_PR64_BPScpe2.txt"), READ_MODE);
		file_open(file_pointer_Input_img, string'(".\..\..\..\Matlab_Functions\Input_64QAM_I_PR64_BPScpe2.txt"), READ_MODE);
						
		--abrir vectores de escrita
		file_open(file_pointer_Output, string'(".\..\..\..\Matlab_Functions\PhaseOutNp1.txt"), WRITE_MODE);
		file_open(file_pointer_Output_re, string'(".\..\..\..\Matlab_Functions\Output_64QAM_R_PR64_BPS.txt"), WRITE_MODE);
		file_open(file_pointer_Output_img, string'(".\..\..\..\Matlab_Functions\Output_64QAM_I_PR64_BPS.txt"), WRITE_MODE);
		file_open(file_pointer_cos, string'(".\..\..\..\Matlab_Functions\Output_cos_64PR64_BPS.txt"), WRITE_MODE);
		file_open(file_pointer_sin, string'(".\..\..\..\Matlab_Functions\Output_sin_64PR64_BPS.txt"), WRITE_MODE);
		file_open(file_pointer_Output1, string'(".\..\..\..\Matlab_Functions\Output_MinTPhase20.txt"), WRITE_MODE);
		
		file_open(file_pointer_Output_bits, string'(".\..\..\..\Matlab_Functions\Output_bits.txt"), WRITE_MODE);
		file_open(file_pointer_Output_re_bit0, string'(".\..\..\..\Matlab_Functions\Output_re0_bit.txt"), WRITE_MODE);
		file_open(file_pointer_Output_re_bit1, string'(".\..\..\..\Matlab_Functions\Output_re1_bit.txt"), WRITE_MODE);
		file_open(file_pointer_Output_re_bit2, string'(".\..\..\..\Matlab_Functions\Output_re2_bit.txt"), WRITE_MODE);
		
		file_open(file_pointer_Output_re_bit3, string'(".\..\..\..\Matlab_Functions\Output_re3_bit.txt"), WRITE_MODE);
		file_open(file_pointer_Output_re_bit4, string'(".\..\..\..\Matlab_Functions\Output_re4_bit.txt"), WRITE_MODE);
		--fazer o loop e gravar a informação agora
		for i in 0 to loop_cout+1 loop		
		--while (not endfile(file_pointer_Input_re)) loop
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
			
			Input_R_tb <= var_Inputs_Real;
			Input_I_tb <= var_Inputs_Imag;
			
		-- esperar por 1 período de clock
			wait for 1*clk_period;
			
			for counter in 0 to Nsig-1 loop
				
				var_Outputs_Real := conv_integer(Output_re_tb((counter+1) * (Output_int+Output_frac)-1 downto counter * (Output_int+Output_frac)));
				var_Outputs_Imag := conv_integer(Output_im_tb((counter+1) * (Output_int+Output_frac)-1 downto counter * (Output_int+Output_frac)));
				
				var_Outputs_cos := conv_integer(cos_re_tb((counter+1) * (Output_int+Output_frac)-1 downto counter * (Output_int+Output_frac)));
				var_Outputs_sin := conv_integer(sin_im_tb((counter+1) * (Output_int+Output_frac)-1 downto counter * (Output_int+Output_frac)));
				
				var_Outputs := conv_integer(phaseOut_tb((counter+1) * (TPhaseBit)-1 downto counter * (TPhaseBit)));
				write(line_pointer_Output, var_Outputs);
				writeline(file_pointer_Output, line_pointer_Output);

				write(line_pointer_Output_re, var_Outputs_Real);
				writeline(file_pointer_Output_re, line_pointer_Output_re);				
				write(line_pointer_Output_img, var_Outputs_Imag);
				writeline(file_pointer_Output_img, line_pointer_Output_img);
				
				write(line_pointer_cos, var_Outputs_cos);
				writeline(file_pointer_cos, line_pointer_cos);				
				write(line_pointer_sin, var_Outputs_sin);
				writeline(file_pointer_sin, line_pointer_sin);
				
			end loop;
			
			 Count := Count + 1;
			
		 end loop;
		
		wait;
		
	end process;

  END;