----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:10:43 11/15/2021 
-- Design Name: 
-- Module Name:    Rete_16_4 - Structural 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Rete_16_4 is
    Port (
            INPUT : in STD_LOGIC_VECTOR (0 to 15);
            SELECTION_DEST 	  	: STD_LOGIC_VECTOR (0 to 1); -- SELECTION DEMUX
              SELECTION_SRC		: STD_LOGIC_VECTOR (0 to 3);	-- SELECTION MUX
			  output 	  	  		: out  STD_LOGIC_VECTOR (0 to 3)
			  );	
end Rete_16_4;

architecture Structural of Rete_16_4 is
	signal mid_output : STD_LOGIC := 'U';
	
	
	component Demux_1_4
		 Port ( Y0 : out  STD_LOGIC;
				  Y1 : out  STD_LOGIC;
				  Y2 : out  STD_LOGIC;
				  Y3 : out  STD_LOGIC;
				  S : in STD_LOGIC_VECTOR(0 to 1);
				  INPUT : in  STD_LOGIC
				  );		
	end component;
	
	component mux_16_1
		 Port ( 	INPUT 			  : in  STD_LOGIC_VECTOR (0 to 15);
					SELECTION 	  : in STD_LOGIC_VECTOR(0 to 3);
					output 	  	  : out  STD_LOGIC
		  );	
	end component;
begin

	mux: mux_16_1
		Port map (
			INPUT => INPUT,
			SELECTION => SELECTION_SRC  ,			
			output => mid_output
		);
		
	demux: Demux_1_4
		Port map (
				Y0 => output(0),
				Y1 => output(1),
				Y2 => output(2),
				Y3 => output(3),
				S => SELECTION_DEST,
				INPUT => mid_output
		);
end Structural;

