----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.03.2022 11:44:03
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
        -- clock reset e pin di ricezione
        clk, rst, rxd        : in std_logic;
        -- dato + crc
        data_out             : out std_logic_vector (15 downto 0);
        -- Valore del bit di controllo CRC
        crc_ok               : out std_logic;
        -- Conferma la ricezione di un nuovo pacchetto
        new_data             : out std_logic:='0';
        -- Segnali di controllo del ricevitore
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

--  Nello stato q0 il controller aspetta di ricevere il primo byte
--  non appena questo viene ricevuto si passa in q1 alzando read
--  In Q1 il controller calcola il secondo byte
--  In q2 vengono dati i due byte di calcolo al crc
--  In q3 si attedge la fine del calcolo ossia result_ready=1
--  vengono portati in uscita il dato ricevuto ed il crc, settando
--  il bit crc_ok ad 1 in caso di crc di valore 0
type controller_state is(q0,q1,q2,q3);
signal stato_attuale: controller_state:=q0;
-- uscita del ricevitore UART.
signal db_out_helper:std_logic_vector(7 downto 0);
-- Si ricevono due byte, prima il byte di dato e poi il crc
signal data_rcv: std_logic_vector( 15 downto 0):=(others =>'0');

-- byte dato
--signal data: std_logic_vector( 7 downto 0):=(others =>'0');
-- byte crc
--signal crc_rcv:  std_logic_vector(7 downto 0):=(others=>'0');

component crc_core 
    port(
        -- Clock e reset
        clk,rst:    in std_logic;
        -- Data in input
        data_in :   in std_logic;
        -- Segnale che segnala l'inizio di un nuovo input.
        new_input    :   in std_logic;
        -- Risultato del crc
        result  :   out std_logic_vector(7 downto 0);
        -- risultato pronto
        result_ready: out std_logic
    );
end component;

--  crc calcolato
signal crc_calc: std_logic_vector(7 downto 0);
--  reset del crc
signal crc_rst: std_logic;
--  input nel crc
signal crc_in:  std_logic;
-- Segnala al crc che si ha un nuovo input
signal crc_new_input: std_logic;
-- risultato calcolato
signal crc_result_ready: std_logic;

begin

rda <= rda_help;

read: process (clk)
    -- variabile usata per dare input al crc
    variable count: integer:=0;
    begin
        if (clk'event and clk='1') then
            if rst='1' then
                stato_attuale<=q0;
                crc_rst<='1';
                data_out<=(others=>'0');
                crc_ok<='0';
                crc_new_input<='0';
                data_rcv<=(others=>'0');
                new_data<='0';
            elsif rst='0' then
                case stato_attuale is
                    when q0=>
                        crc_rst<='0';
                        if rda_help='1' then
                            rd_help<='1';
                            data_rcv(15 downto 8)<=db_out_helper;
                            stato_attuale<=q1;
                            new_data<='0';
                        elsif rda_help='0' then
                            rd_help<='0';
                            stato_attuale<=q0;
                        end if;
                    when q1=>
                        if rda_help='1' then
                            rd_help<='1';
                            data_rcv(7 downto 0)<=db_out_helper;
                            stato_attuale<=q2;
                        elsif rda_help='0' then
                            rd_help<='0';
                            stato_attuale<=q1;
                        end if;
                    when q2=>
                        if (count > 15) then 
                            count := 0;
                            stato_attuale <= q3;
                            crc_new_input <= '0';
                            --t_input <= data_to_send (15 downto 8);    
                        elsif (count <= 15) then
                            crc_in <= data_rcv (15 - count);
                            count := count + 1;
                            crc_new_input <= '1';
                        end if;
                   when q3 =>                      
                        if (crc_result_ready = '1') then
                            stato_attuale <= q0; 
                            data_out<=data_rcv;
                            -- de morgan, affinche' sia 1
                            -- devono essere tutti 0
                            crc_ok<=not(crc_calc(0) or crc_calc(1) or crc_calc(2) or  crc_calc(3)or crc_calc(4)or crc_calc(5)or crc_calc(6) or crc_calc(7)); 
                            crc_rst<='1';
                            new_data<='1';
                        end if;
                end case;
            end if; -- fine if rst
        end if; -- fine if ck
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
		DBOUT 	=> db_out_helper,
		RDA		=> rda_help,
		TBE		=> temptbe,
		RD		=> rd_help,
		WR		=> '0',
		PE		=> pe,
		FE		=> fe,
		OE		=> oe,
		RST		=> rst
    );
crc : crc_core 
    port map(
        clk => clk,
        rst => crc_rst,
        data_in => crc_in,
        new_input => crc_new_input,
        result => crc_calc,
        result_ready => crc_result_ready
    );
end Behavioral;
