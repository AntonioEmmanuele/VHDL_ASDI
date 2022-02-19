----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.02.2022 17:34:43
-- Design Name: 
-- Module Name: Node_B - Behavioral
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

entity Node_B is
    generic (
        CLK_FREQUENCY : integer := 100000000;
		BAUD_RATE     : integer := 9600;
		CENTERING     : integer := 16
    );
    port (
        clk, rst, rxd        : in std_logic;
        data_out             : out std_logic_vector (7 downto 0);
        oe, pe, fe, rda      : out std_logic
    );
end Node_B;

architecture Behavioral of Node_B is

signal temptxd : std_logic;
signal temptbe : std_logic;

component UARTcomponent is
	Generic (
		--@48MHz
--		BAUD_DIVIDE_G : integer := 26; 	--115200 baud
--		BAUD_RATE_G   : integer := 417

		--@26.6MHz
		BAUD_DIVIDE_G : integer := 14; 	--115200 baud
		BAUD_RATE_G   : integer := 231
	);
	Port (	
		TXD 	: out 	std_logic  	:= '1';					-- Transmitted serial data output
		RXD 	: in  	std_logic;							-- Received serial data input
		CLK 	: in  	std_logic;							-- Clock signal
		DBIN 	: in  	std_logic_vector (7 downto 0);		-- Input parallel data to be transmitted
		DBOUT 	: out 	std_logic_vector (7 downto 0);		-- Recevived parallel data output
		RDA		: inout  std_logic;							-- Read Data Available
		TBE		: out 	std_logic 	:= '1';					-- Transfer Buffer Emty
		RD		: in  	std_logic;							-- Read Strobe
		WR		: in  	std_logic;							-- Write Strobe
		PE		: out 	std_logic;							-- Parity error		
		FE		: out 	std_logic;							-- Frame error
		OE		: out 	std_logic;							-- Overwrite error
		RST		: in  	std_logic	:= '0');				-- Reset signal
						
end component;

signal rda_help         : std_logic := '0';
signal rd_help          : std_logic := '0';

begin

rda <= rda_help;

read: process (clk)
    begin
        if (rising_edge(clk)) then
            if (rda_help = '1') then
                rd_help <= '1';
            elsif (rda_help = '0') then
                rd_help <= '0';
            end if;
        end if;
end process;

receiver: UARTcomponent
	Generic map(
		BAUD_DIVIDE_G => CLK_FREQUENCY / (BAUD_RATE*CENTERING), 	--115200 baud
		BAUD_RATE_G   => CLK_FREQUENCY / BAUD_RATE
	)
	Port map (	
		TXD 	=> temptxd,					
		RXD 	=> rxd,
		CLK 	=> clk,
		DBIN 	=> (others => '0'),
		DBOUT 	=> data_out,
		RDA		=> rda_help,
		TBE		=> temptbe,
		RD		=> rd_help,
		WR		=> '0',
		PE		=> pe,
		FE		=> fe,
		OE		=> oe,
		RST		=> rst
    );

end Behavioral;
