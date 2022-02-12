----------------------------------------------------------------------------------
-- Company: 
-- Engineer: De Rosa Giuseppe,Emmanuele Antonio
-- 
-- Create Date: 30.01.2022 12:43:18
-- Design Name: 
-- Module Name: encoderBCD - Structural
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
entity encoderBCD is
    Port ( X : in STD_LOGIC_VECTOR (9 downto 0);    -- Segnale in input
           Y : out STD_LOGIC_VECTOR (3 downto 0);   -- Segnale in output
           Z : out STD_LOGIC);                      -- Flag di non validita'
end encoderBCD;

architecture Structural of encoderBCD is

    component encoder16_4

    Port ( INPUT : in STD_LOGIC_VECTOR (15 downto 0);
           OUTPUT : out STD_LOGIC_VECTOR (3 downto 0);
           FLAG : out STD_LOGIC);
    end component;

begin

    encoder : encoder16_4 
        port map (
        -- BYTE<= (7 => '1', 5 downto 1 => '1', 6 => B_BIT, others => '0');
            --INPUT => (15 downto 10 => '0', (9 downto 0) => '0'),
            --INPUT => (15 downto 10 => '0', 9 downto 0 => X),
            INPUT (15 downto 10) => (others => '0'),
            INPUT (9 downto 0) => X,
            OUTPUT => Y,
            FLAG => Z
        );

end Structural;