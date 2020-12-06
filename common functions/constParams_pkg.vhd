-------------------------------------------------------------------
-- Authors: Celestino Martins @ 2019 -- 
-------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.math_real.all; 

package constDef_pkg is
	
	constant Data_width 	 		: integer := 16; -- Dist_int+Dist_frac
	constant ROMIQ_AdrrWidth 	: integer := 4;  -- IQ ROM Adress width (QPSK->2,16QAM->4,32QAM->5,64QAM->6)
	constant nBit 			 		: integer := 14; -- IQ ROM Data width 
	constant NTphase    	 		: integer := 2; 
	constant Nsig    		 		: integer := 8; 
	constant SetBitMult 	 		: integer := 6;       -- Bit width extension after phase multiplication
   constant indexWitdh 	 		: integer := (integer(ceil(log2(real(NTphase)))));  -- Test phase ROM Adress width
	constant TPhaseBit  			: integer := 14;  -- Test phase ROM Data width (only phase)
	constant DCBits				: integer := 14;
   type ArrayIn1  is array ((NTphase) - 1 downto 0) of std_logic_vector(Nsig * Data_width - 1 downto 0);
	type ArrayOut  is array (Nsig - 1 downto 0) of std_logic_vector((NTphase) * Data_width - 1 downto 0);
   constant NtapConf 	 		: integer := 17; 
	constant Nd			 	 		: integer := 2; 
	
	--constant val1 		: real := 0.4714;
	--constant val2 		: real := -0.4714;
	
	constant val1 		: real := 0.2418;
	constant val2 		: real := -0.2418;
	
	constant SCALE 		: real := 2**(real(nBit-2));
	
--	constant dcI1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := std_logic_vector(to_signed(INTEGER(val1*SCALE),nBit));
--	constant dcR1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := STD_LOGIC_VECTOR(to_signed(INTEGER(val1*SCALE),nBit));
--	constant dcI2 : STD_LOGIC_VECTOR(nBit-1 downto 0) := STD_LOGIC_VECTOR(to_signed(INTEGER(val2*SCALE),nBit));
-- constant dcR2 : STD_LOGIC_VECTOR(nBit-1 downto 0) := STD_LOGIC_VECTOR(to_signed(INTEGER(val2*SCALE),nBit));

	-- (12,14)
	constant dcIPt1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00101000111001";
	constant dcRPt1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00101000111001";
	constant dcIPt2 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11010111000111";
	constant dcRPt2 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11010111000111";
	
		-- (12,14)
--	constant dcI1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00011110001011";
--	constant dcR1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00011110001011";
--	constant dcI2 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11100001110101";
--	constant dcR2 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11100001110101";
	
	constant dcI1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00001111011110";
	constant dcR1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00001111011110";
	constant dcI2 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11110000100010";
	constant dcR2 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11110000100010";
	
--	--------------- 64QAM Decision Circuit ---------------
--	constant dcI00 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00001100111011";
--	constant dcR00 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00001100111011";
--	constant dcI01 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00100110110011";
--	constant dcR01 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00100110110011";
--	constant dcI10 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11110011000101";
--	constant dcR10 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11110011000101";
--	constant dcI11 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11011001001101";
--	constant dcR11 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11011001001101";
--	constant dcQR0 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00011001110111";
--	constant dcQI0 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00011001110111";
--	constant dcQR1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11100110001001";
--	constant dcQI1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11100110001001";

--------------- 64QAM Decision Circuit ---------------
	constant dcI00 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00000110100001";
	constant dcR00 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00000110100001";
	constant dcI01 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00010011100100";
	constant dcR01 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00010011100100";
	constant dcI10 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11111001011111";
	constant dcR10 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11111001011111";
	constant dcI11 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11101100011100";
	constant dcR11 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11101100011100";
	constant dcQR0 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00001101000010";
	constant dcQI0 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "00001101000010";
	constant dcQR1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11110010111110";
	constant dcQI1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "11110010111110";
	
			-- (14,16)
--	constant dcI1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "0001111000101011";
--	constant dcR1 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "0001111000101011";
--	constant dcI2 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "1110000111010101";
-- 	constant dcR2 : STD_LOGIC_VECTOR(nBit-1 downto 0) := "1110000111010101";
	
	-- (6,8)
--	constant dcI1 : STD_LOGIC_VECTOR(7 downto 0) := "00011110";
--	 constant dcR1 : STD_LOGIC_VECTOR(7 downto 0) := "00011110";
--	 constant dcI2 : STD_LOGIC_VECTOR(7 downto 0) := "11100010";
-- 	 constant dcR2 : STD_LOGIC_VECTOR(7 downto 0) := "11100010";
	--constant PhaseJumpPOS     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "000011001001"; -- (6,12)
   --constant PhaseJumpNEG     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "111100110111"; -- (6,12)
	--constant PhaseJumpPOS     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "000000001100100100";   -- (10,18)
   --constant PhaseJumpNEG     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "111111110011011100";   -- (5,12)

	--constant PhaseJumpPOS     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "00000110010010";   -- (7,14)
   --constant PhaseJumpNEG     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "11111001101110";   -- (7,14)
	
	constant PhaseJumpPOS     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "00011001001000";   -- (9,14)
   constant PhaseJumpNEG     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "11100110111000";   -- (9,14)
	
	--constant PhaseJumpPOS     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "00000001100101";   -- (5,14)
   --constant PhaseJumpNEG     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "11111110011011";   -- (5,14)
	--constant PhaseJumpPOS     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "0000000001100101"; -- (5,16)
   --constant PhaseJumpNEG     : std_logic_vector (TPhaseBit-1 DOWNTO 0) := "1111111110011011"; -- (5,16)
	
end constDef_pkg;

