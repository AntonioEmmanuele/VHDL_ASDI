----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  De Rosa Giuseppe, Emmanuele Antonio
-- 
-- Create Date: 28.01.2022 17:10:12
-- Design Name: 
-- Module Name: encoder16_4 - Behavioral
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
use IEEE.Numeric_Std.ALL;

entity encoder16_4 is
    Port ( INPUT : in STD_LOGIC_VECTOR (15 downto 0);
           OUTPUT : out STD_LOGIC_VECTOR (3 downto 0);
           FLAG : out STD_LOGIC);
end encoder16_4;

architecture Behavioral of encoder16_4 is
begin
    process(INPUT)
    begin
        -- Encoder a priorità
        if (INPUT = std_logic_vector (to_unsigned (0, INPUT'length))) then
            FLAG <= '1';
            OUTPUT <= "0000";
        else
            FLAG <= '0';
        end if;

        for i in 15 downto 0 loop
            if (INPUT(i) = '1') then
                OUTPUT <= std_logic_vector (to_unsigned (i, OUTPUT'length));
                exit;
            end if;
        end loop;
       
     end process;                 
end Behavioral;