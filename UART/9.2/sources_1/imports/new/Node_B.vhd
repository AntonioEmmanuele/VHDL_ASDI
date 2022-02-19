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
use IEEE.NUMERIC_STD.ALL;

entity Node_B is
    generic (
        CLK_FREQUENCY : integer := 100000000;
		BAUD_RATE     : integer := 9600;
		CENTERING     : integer := 16
    );
    port (
        clk, rst, rxd        : in std_logic;
        oe, pe, fe, rda      : out std_logic
    );
end Node_B;

architecture Behavioral of Node_B is

constant N : integer := 4;
constant Bit_Number : integer := 2;

-- Segnali temporanei
signal temptxd : std_logic;
signal temptbe : std_logic;
signal count_done_h : std_logic;

-- Segnali intermedi
signal strobe : std_logic;
signal ADDR   : std_logic_vector (0 to Bit_number-1);
signal data_out : std_logic_vector (0 to 7);

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

component counter_mod_n 
    generic(
        N           : integer :=16;                                -- Max value
        Bit_number  : integer := 4;                                -- 2^Bit_number al più = N
        CLK_period  : time := 1000ms                               -- Periodo clock, supposto 1s
    );
    port(
        enable:         IN std_logic;                              --  Abilita il contatore
        load:           IN std_logic;                              --  Dobbiamo caricare un valore nel contatore.
        input_value:    IN std_logic_vector(0 to Bit_number-1);    --  Valore da caricare, considerato solo se load=1
        ck:             IN std_logic;                              --  Clock
        rst:            IN std_logic;                              --  Reset  
        cnt_done:       OUT std_logic;                             --  Conteggio finito
        count_value:    OUT std_logic_vector(0 to Bit_number-1)    --  Valore di conteggio
    );   
end component;

type mem_type is array (0 to N-1) of std_logic_vector(7 downto 0);
signal MEM : mem_type := (
    X"00",  -- 0            -- Indirizzo 0
    X"00",  -- 0    
    X"00",  -- 0            
    X"00"); -- 0            -- Indirizzo N-1
    
type Stato is (Q0, Q1);
signal stato_corrente : stato := Q0;

signal rda_help         : std_logic := '0';
signal rd_help          : std_logic := '0';

begin

rda <= rda_help;

update: process (clk)
    begin
        if (rising_edge(clk)) then
            if (rd_help = '1') then
                Mem (to_integer(unsigned(ADDR))) <= data_out;
            end if;
        end if;
end process;

controller: process (clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                strobe <= '0';
                rd_help <= '0';
                stato_corrente <= Q0;
            else
                case stato_corrente is
                    when Q0 => 
                        if (rda_help = '0') then
                            rd_help <= '0';
                            stato_corrente <= Q0;
                        elsif (rda_help = '1') then
                            rd_help <= '1';
                            stato_corrente <= Q1;
                        end if;
                        strobe <= '0';
                    when Q1 => 
                        if (rda_help = '1') then
                            rd_help <= '1';
                            strobe <= '0';
                            stato_corrente <= Q1;
                        elsif (rda_help = '0') then
                            rd_help <= '0';
                            strobe <= '1';
                            stato_corrente <= Q0;
                        end if;
                end case;
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
    
contatore: counter_mod_n
    generic map (
        N           => N,
        Bit_number  => Bit_Number,
        CLK_period  => 10ns
    )
    port map (
        enable         => strobe,
        load           => '0',
        input_value    => (others => '0'),
        ck             => clk,
        rst            => rst,
        cnt_done       => count_done_h,
        count_value    => ADDR
    );

end Behavioral;
