--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:00:12 11/13/2021
-- Design Name:   
-- Module Name:   /home/ise/Mux_16-1/mux_16_1_TB.vhd
-- Project Name:  Mux_16-1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mux_16_1
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.textio.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY mux_16_1_TB IS
END mux_16_1_TB;
 
ARCHITECTURE behavior OF mux_16_1_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT mux_16_1
    PORT(
         INPUT : IN  std_logic_vector(0 to 15);
         SELECTION : IN  std_logic_vector(0 to 3);
         output : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal input : std_logic_vector(0 to 15) := (others => '0');
   signal control : std_logic_vector(0 to 3) := (others => '0');

 	--Outputs
   signal y : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mux_16_1 PORT MAP (
          INPUT => input,
          SELECTION => control,
          output => y
        );

  --  Test Bench Statements
     tb : PROCESS
     BEGIN

        wait for 100 ns; -- wait until global set/reset completes
		  input <= "1001001011000110";

		for i in 0 to 15 loop
			control <= std_logic_vector (to_unsigned(i, control'length));
			wait for 50 ns;
			assert y = input (i)
			report "errore"
			severity failure;
		end loop;
		
		wait;
	   END PROCESS tb;

END;