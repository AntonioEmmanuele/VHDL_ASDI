--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:27:08 11/13/2021
-- Design Name:   
-- Module Name:   /home/ise/Mux_16-1/mux_4_1_TB.vhd
-- Project Name:  Mux_16-1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mux_4_1
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY mux_4_1_TB IS
END mux_4_1_TB;
 
ARCHITECTURE behavior OF mux_4_1_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT mux_4_1
    PORT(
         IN0 : IN  std_logic;
         IN1 : IN  std_logic;
         IN2 : IN  std_logic;
         IN3 : IN  std_logic;
         S : IN  std_logic_vector(0 to 1);
         Y : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
		signal input 	 : STD_LOGIC_VECTOR (0 to 3) := (others => 'U');
		signal control  : STD_LOGIC_VECTOR (0 to 1) := (others => 'U');
		signal output	 : STD_LOGIC					  := 'U';


 	--Outputs
   signal Y : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mux_4_1 PORT MAP (
			IN0 => input(0),
			IN1 => input(1),
			IN2 => input(2),
			IN3 => input(3),
			S(0) => control(0),
			S(1) => control(1),
			Y => output
        );


  --  Test Bench Statements
     tb : PROCESS
     BEGIN

        wait for 100 ns; -- wait until global set/reset completes
		  input <= "1001";
		  wait for 10 ns;
		  control <= "00";
		  wait for 10 ns;
		  control <= "01";
		  wait for 10 ns;
		  control <= "10";
		  wait for 10 ns;
		  control <= "11";

        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 


END;
