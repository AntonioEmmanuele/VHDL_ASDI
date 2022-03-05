
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
        -- Transmission interface
        input : in std_logic_vector (0 to 7);
        write : in std_logic;
        data_trasmitted: out std_logic;
        -- Control pin
        clk, rst : in std_logic;
        -- Receiver interface
        data_out             : out std_logic_vector (15 downto 0);
        crc_ok               : out std_logic;
        new_data             : out std_logic:='0';
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
        input : in std_logic_vector (0 to 7);
        write : in std_logic;
        clk, rst : in std_logic;
        txd : out std_logic;
        data_trasmitted: out std_logic
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
        data_out             : out std_logic_vector (15 downto 0);
        crc_ok               : out std_logic;
        new_data             : out std_logic:='0';
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
        input => input,
        write => write,
        clk => clk,
        rst => rst,
        txd => bus_data,
        data_trasmitted=>data_trasmitted
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
        data_out => data_out,
        crc_ok=>crc_ok,
        new_data=> new_data,
        oe => oe,
        pe => pe,
        fe => fe,
        rda => rda
    );    

end Structural;