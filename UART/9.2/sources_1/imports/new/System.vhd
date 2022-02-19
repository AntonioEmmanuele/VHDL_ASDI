----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.02.2022 18:10:00
-- Design Name: 
-- Module Name: System - Structural
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity System is
    generic (
        CLK_FREQUENCY : integer := 100000000;
		BAUD_RATE     : integer := 9600;
		CENTERING     : integer := 16
    );
    port (
        -- Control pin
        clk, rst : in std_logic;
        -- Receiver interface
        oe, pe, fe, rda      : out std_logic
    );
end System;

architecture Structural of System is

component Node_A 
    generic (
        CLK_FREQUENCY : integer := 100000000;
		BAUD_RATE     : integer := 9600;
		CENTERING     : integer := 16
    );
    port (
        clk, rst : in std_logic;
        txd : out std_logic
    );
end component;

component Node_B 
    generic (
        CLK_FREQUENCY : integer := 100000000;
		BAUD_RATE     : integer := 9600;
		CENTERING     : integer := 16
    );
    port (
        clk, rst, rxd        : in std_logic;
        oe, pe, fe, rda      : out std_logic
    );
end component;

signal bus_data : std_logic := '1';

begin

A: Node_A 
    generic map (
        CLK_FREQUENCY => CLK_FREQUENCY,
		BAUD_RATE     => BAUD_RATE,
		CENTERING     => CENTERING
    )
    port map (
        clk => clk,
        rst => rst,
        txd => bus_data
    );
    
B: Node_B
    generic map (
        CLK_FREQUENCY => CLK_FREQUENCY,
		BAUD_RATE     => BAUD_RATE,
		CENTERING     => CENTERING
    )
    port map (
        clk => clk,
        rst => rst,
        rxd => bus_data,
        oe => oe,
        pe => pe,
        fe => fe,
        rda => rda
    );    

end Structural;
