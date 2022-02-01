----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.01.2022 13:28:02
-- Design Name: 
-- Module Name: encoderBCD_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.numeric_std.all; 
USE STD.textio.ALL;
use IEEE.std_logic_textio.all;   

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encoderBCD_TB is
--  Port ( );
end encoderBCD_TB;

architecture Behavioral of encoderBCD_TB is

    component encoderBCD is
        Port ( X : in STD_LOGIC_VECTOR (9 downto 0);
               Y : out STD_LOGIC_VECTOR (3 downto 0);
               Z : out STD_LOGIC);
    end component;

    signal inputs : std_logic_vector(9 downto 0) := (others => '0');
    signal flag : STD_LOGIC := '0';
    
    --Outputs
    signal output : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
    signal tmp : std_logic_vector (3 downto 0) := (others => '0');   
    
    function to_hstring (SLV : std_logic_vector) return string is
        variable L : LINE;
        begin
            hwrite(L,SLV);
            return L.all;
    end function to_hstring; 

    
BEGIN

-- Component Instantiation

    uut: encoderBCD PORT MAP(
          X => inputs,
          Y => output,
          Z => flag 
    );

--  Test Bench Statements
    tb : process
    begin
        wait for 100ns; 
        inputs <= (others => '0');
        
        wait for 25 ns;
        
        assert flag = '1';
        report "errore flag"
        severity warning;
        
        wait for 75ns; 
        for i in 0 to 9 loop
            inputs(i) <= '1';
            tmp <= std_logic_vector(to_unsigned(i, tmp'length));
            wait for 25 ns;
            assert output = tmp and flag = '0'
            report "errore." & " Unexpected value. i = " & to_hstring(tmp) 
            & " Output " & to_hstring(output)
            severity warning;
            wait for 25 ns;
            --inputs <= (others => '0');
        end loop;
        
        wait;
    end process tb;
	                  
--  End Test Bench 

END;
