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

entity Node_A is
    generic (
        CLK_FREQUENCY : integer := 100000000;
		BAUD_RATE     : integer := 9600;
		CENTERING     : integer := 16
    );
    port (
        input : in std_logic_vector (0 to 7);
        write : in std_logic;
        clk, rst : in std_logic;
        txd : out std_logic
    );
end Node_A;

architecture Behavioral of Node_A is

signal tempdbout : std_logic_vector (7 downto 0);
signal temprda : std_logic;
signal temptbe : std_logic;
signal tempfe : std_logic;
signal temppe : std_logic;
signal tempoe : std_logic;

component UARTcomponent is
	Generic (
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

signal data_to_send : std_logic_vector (15 downto 0);
-- Internal write
signal int_write    : std_logic := '0';

signal crc_rst : std_logic := '0';
signal crc_in : std_logic;
signal crc_new_input : std_logic := '0';
signal crc_result_ready : std_logic;

signal t_input : std_logic_vector (7 downto 0);

type stato is (q0,q1,q2,q3, q4, qwait);
signal stato_attuale:stato:=q0;

begin

control_unit : process (clk)
    variable count : integer := 0;
    variable msg_count : integer := 0;
    begin
        if (rising_edge (clk)) then
            if (rst = '1') then
                stato_attuale <= q0;
                data_to_send <= (others => '0');
                crc_new_input <= '0';
                int_write <= '0';
            elsif (rst = '0') then
                case stato_attuale is
                    when q0 => 
                        crc_new_input <= '0';
                        crc_rst <= '0';
                        if (write = '1') then
                           data_to_send (15 downto 8) <= input;
                           stato_attuale <= q1;
                        elsif (write = '0') then
                           stato_attuale <= q0;
                        end if;
                    when q1 => 
                        if (count > 7) then 
                            count := 0;
                            stato_attuale <= q2;
                            crc_new_input <= '0';
                            --t_input <= data_to_send (15 downto 8);    
                        elsif (count <= 7) then
                            crc_in <= data_to_send (15 - count);
                            count := count + 1;
                            crc_new_input <= '1';
                        end if;
                    when q2 =>                      
                        if (crc_result_ready = '1') then
                            stato_attuale <= qwait;          
                        end if;
                    when qwait => 
                        t_input <= data_to_send (15-8*msg_count downto 8-8*msg_count);    
                        stato_attuale <= q3;  
                    when q3 =>
                        if (temptbe = '1') then
                            int_write <= '1';
                        elsif (temptbe = '0') then
                            int_write <= '0';
                            stato_attuale <= q4;
                        end if;
                    when q4 => 
                        if (temptbe = '1') then
                            if (msg_count >= 1) then 
                                stato_attuale <= q0;
                                msg_count := 0;
                                crc_rst <= '1';
                            elsif (msg_count < 1) then
                                stato_attuale <= qwait;
                                msg_count := msg_count + 1;
                            end if;
                        end if;
                end case;
            end if; 
        end if;
end process control_unit;

crc : crc_core 
    port map(
        clk => clk,
        rst => crc_rst,
        data_in => crc_in,
        new_input => crc_new_input,
        result => data_to_send (7 downto 0),
        result_ready => crc_result_ready
    );

transmitter: UARTcomponent
	Generic map(
		BAUD_DIVIDE_G => CLK_FREQUENCY / (BAUD_RATE*CENTERING), 	--115200 baud
		BAUD_RATE_G   => CLK_FREQUENCY / BAUD_RATE
	)
	Port map (	
		TXD 	=> txd,					
		RXD 	=> '1',
		CLK 	=> clk,
		DBIN 	=> t_input,
		DBOUT 	=> tempdbout,
		RDA		=> temprda,
		TBE		=> temptbe,
		RD		=> '0',
		WR		=> write,
		PE		=> temppe,
		FE		=> tempfe,
		OE		=> tempoe,
		RST		=> rst
    );

end Behavioral;
