--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:18:39 11/15/2021
-- Design Name:   
-- Module Name:   /home/ise/Mux_16-1/Demux_1_4_TB.vhd
-- Project Name:  Mux_16-1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Demux_1_4
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
 
ENTITY Demux_1_4_TB IS
END Demux_1_4_TB;
 
ARCHITECTURE behavior OF Demux_1_4_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Demux_1_4
    PORT(
         Y0 : OUT  std_logic;
         Y1 : OUT  std_logic;
         Y2 : OUT  std_logic;
         Y3 : OUT  std_logic;
         S : IN  std_logic_vector(0 to 1);
         INPUT : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal selection : std_logic_vector(0 to 1) := (others => '0');
   signal input_demux : std_logic := '0';

 	--Outputs
   signal output0 : std_logic;
   signal output1 : std_logic;
   signal output2 : std_logic;
   signal output3 : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Demux_1_4 PORT MAP (
          Y0 => output0,
          Y1 => output1,
          Y2 => output2,
          Y3 => output3,
          S => selection,
          INPUT => input_demux
        );
		  
	--  Test Bench Statements
     tb : PROCESS
     BEGIN

        wait for 100 ns; -- wait until global set/reset completes
		  input_demux <= '1';
		  wait for 10 ns;
		  selection <= "00";
		  wait for 10 ns;
		  selection <= "01";
		  wait for 10 ns;
		  selection <= "10";
		  wait for 10 ns;
		  selection <= "11";

        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 


END;
