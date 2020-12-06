
-------------------------------------------------------------------
-- Authors: Celestino @ 2019 --
-------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.math_real.all;
use ieee.std_logic_signed.all;
USE ieee.numeric_std.all;
---------------------------------------------------------

ENTITY Unwrap_IT3 IS
  generic (
			NBitIn  		: integer := 8;
			NBitExt  	: integer := 8;
			NSamples  	: integer := 8
		); 
  port (
			PhaseJumpPOS	: in std_logic_vector(NBitIn-1 downto 0);
			PhaseJumpNEG	: in std_logic_vector(NBitIn-1 downto 0);
			phase_in 		: in std_logic_Vector(NBitIn*NSamples-1 downto 0);
			phase_out 		: out std_logic_vector((NBitExt-2)*NSamples-1 downto 0)
		);
END Unwrap_IT3;


ARCHITECTURE Behavioral OF Unwrap_IT3 IS

		constant ref : std_logic_vector(NBitExt-1 downto 0) := "0000110010010000";-- "00000011001001"; --<- (5,14)|(7,16) -> 0000001100100100 (5,16) -> 0000000011001001 (9,16) -> 0000000011001001
		--constant NbitOut : integer := NBits-2;
		--signal phaseDiff  : std_logic_Vector(NBitIn-1 downto 0) := (others =>'0');
		--signal last_phase : std_logic_Vector(NBitIn-1 downto 0) := (others =>'0');
BEGIN
	
	process(phase_in)
		variable phase_acum : std_logic_vector(NBitExt-1 downto 0) := (others =>'0');
		variable phase_aux : std_logic_vector(NBitExt-1 downto 0) := (others =>'0');
		variable phaseDiff  : std_logic_Vector(NBitIn-1 downto 0) := (others =>'0');
		variable last_phase : std_logic_Vector(NBitIn-1 downto 0) := (others =>'0');
	begin
		--last_phase := phase_in(NBits-1 DOWNTO 0);
		for i in 0 to NSamples-1 loop
			phaseDiff := phase_in((i+1)*NBitIn-1 DOWNTO i*NBitIn)-last_phase;
			if(phaseDiff > PhaseJumpPOS) then
				phase_acum := phase_acum(NBitExt-1 DOWNTO 0) - ref;
			elsif(phaseDiff < PhaseJumpNEG) then
				phase_acum := phase_acum(NBitExt-1 DOWNTO 0) + ref;
			else
				phase_acum := phase_acum(NBitExt-1 DOWNTO 0);
			end if;
			phase_aux := (phase_in((i+1)*NBitIn-1) & phase_in((i+1)*NBitIn-1) & phase_in((i+1)*NBitIn-1 DOWNTO i*NBitIn)) + phase_acum(NBitExt-1 DOWNTO 0);
			phase_out((i+1)*(NBitExt-2)-1 DOWNTO i*(NBitExt-2)) <= phase_aux(NBitExt-1 DOWNTO 2);
			last_phase := phase_in((i+1)*NBitIn-1 DOWNTO i*NBitIn);
			--phase_out((i+1)*(NBitExt-2)-1 DOWNTO i*(NBitExt-2)) <= phaseDiff;
		end loop;
	end process;
	
END Behavioral;
