----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.02.2022 18:25:56
-- Design Name: 
-- Module Name: cla_adder - Dataflow
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity cla_adder is
    port (
        X : in std_logic_vector (4 downto 0);
        Y : in std_logic_vector (4 downto 0);
        Cin : in std_logic;
        Cout : out std_logic; 
        S : out std_logic_vector (4 downto 0)
    );
end cla_adder;

architecture Dataflow of cla_adder is

signal P : std_logic_vector (4 downto 0);
signal G : std_logic_vector (4 downto 0);
signal C : std_logic_vector (1 to 5);

begin

-- Generation/Propagation process
gp : process (X, Y) 
    begin    
        for i in 0 to 4 loop 
            P(i) <= X(i) XOR Y(i);
            G(i) <= X(i) AND Y(i);
        end loop;
end process gp;

C(1) <= G(0) OR (P(0) AND Cin);
C(2) <= G(1) OR (P(1) AND G(0)) OR  (P(1) AND P(0) AND Cin);
C(3) <= G(2) OR ( ( P(2) AND G(1) )OR (P(2) AND P(1) AND G(0) )OR (P(2) AND P(1) AND P(0) AND Cin) );
C(4) <= G(3) OR ( (P(3) AND G(2)) OR ( ( P(3) AND P(2) AND G(1) ) OR (P(3) AND P(2) AND P(1) AND G(0) )OR (P(3) AND P(2) AND P(1) AND P(0) AND Cin) ) ); 
C(5) <= G(4) OR ( (P(4) AND G(3)) OR ( (P(4) AND P(3) AND G(2)) OR ( (P(4) AND P(3) AND P(2) AND G(1) ) OR (P(4) AND P(3) AND P(2) AND P(1) AND G(0) )OR (P(4) AND P(3) AND P(2) AND P(1) AND P(0) AND Cin) ) ) );   

Cout <= C(5);
S(0) <= Cin XOR P(0);
S(1) <= C(1) XOR P(1);
S(2) <= C(2) XOR P(2);
S(3) <= C(3) XOR P(3);
S(4) <= C(4) XOR P(4);
end Dataflow;
