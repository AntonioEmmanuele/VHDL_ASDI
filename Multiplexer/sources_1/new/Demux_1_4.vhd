----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:11:00 11/15/2021 
-- Design Name: 
-- Module Name:    Demux_1_4 - Behavioral 
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

entity Demux_1_4 is
    Port ( Y0 : out  STD_LOGIC;
           Y1 : out  STD_LOGIC;
           Y2 : out  STD_LOGIC;
           Y3 : out  STD_LOGIC;
		   S : in STD_LOGIC_VECTOR(0 to 1);
		   INPUT : in  STD_LOGIC
			  );		
end Demux_1_4;

architecture Dataflow of Demux_1_4 is

begin
	Y0 <= INPUT AND (NOT(S(0))) AND (NOT(S(1)));
	Y1 <= INPUT AND (NOT(S(0))) AND ((S(1)));
	Y2 <= INPUT AND ((S(0))) AND (NOT(S(1)));
	Y3 <= INPUT AND ((S(0))) AND ((S(1)));

end Dataflow;

