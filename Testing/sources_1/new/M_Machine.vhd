----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.02.2022 16:50:30
-- Design Name: 
-- Module Name: M_Machine - Dataflow
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

entity M_Machine is
port(
    x: in std_logic_vector(0 to 3);
    y: out std_logic_vector(0 to 2)
);
end M_Machine;

architecture Dataflow of M_Machine is
begin
y(0)<= x(0) and x(1) and x(2);
y(1)<= x(1) and x(2) and x(3);
y(2)<= x(2) and x(3) and x(0);
end Dataflow;
