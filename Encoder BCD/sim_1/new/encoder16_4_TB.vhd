----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.01.2022 17:43:38
-- Design Name: 
-- Module Name: encoder16_4_TB - Behavioral
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

entity encoder16_4_TB is
--  Port ( );
end encoder16_4_TB;

ARCHITECTURE behavior OF encoder16_4_TB IS 

-- Component Declaration
        COMPONENT encoder16_4
        Port ( X : in STD_LOGIC_VECTOR (15 downto 0);
               Y : out STD_LOGIC_VECTOR (3 downto 0);        
               Z : out STD_LOGIC);      
        END COMPONENT;

        signal inputs : std_logic_vector(15 downto 0) := (others => '0');
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

    uut: encoder16_4 PORT MAP(
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
        for i in 0 to 15 loop
            inputs(i) <= '1';
            tmp <= std_logic_vector(to_unsigned(i, tmp'length));
            wait for 25 ns;
            assert output = tmp and flag = '0'
            report "errore." & " Unexpected value. i = " & to_hstring(tmp) 
            & " Output " & to_hstring(output)
            severity failure;
            wait for 25 ns;
            --inputs <= (others => '0');
        end loop;
        
        wait;
    end process tb;
	                  
--  End Test Bench 

END;
