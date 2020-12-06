

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity up_counter is
GENERIC( 
		 Data_width   : integer := 8
  );
    port (              
      clk    :in  std_logic;                      -- Input clock
		clk_en 	:in  std_logic;                      -- Enable counting                     
		cout   	:out std_logic_vector (Data_width-1 downto 0)  -- Output of the counter
    );
end entity;

architecture rtl of up_counter is
    signal count :std_logic_vector (Data_width-1 downto 0) := (others => '0');
begin
    process (clk) begin
        if (rising_edge(clk)) then
            if (clk_en = '1') then
                count <= count +  x"1";
            end if;
        end if;
    end process;
    cout <= count;
end architecture;