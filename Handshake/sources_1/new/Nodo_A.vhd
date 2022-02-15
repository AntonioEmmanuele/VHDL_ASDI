----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2022 18:08:58
-- Design Name: 
-- Module Name: Nodo_A - Behavioral
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

entity Node_A is
    -- Riceviamo 4 stringhe da 8 bit
    generic(
        N: integer := 4;
        M: integer := 8;
        Num_Packets:Integer:=8;     --  Numero di pacchetti che formano un messaggio 
        Packet_Bits: Integer:=1     --  Numero di bits in un pacchetto
    );
    port(
        clk,rst:   in std_logic; -- Clock e reset 
        in_ready: out std_logic; -- Segnale di ready dato dal trasmettitore
        in_received: in std_logic;  -- Conferma di avvenuta lettura
        data_out: out std_logic_vector(0 to Packet_Bits-1) -- dati in ingresso messi dal trasmettitore
    );  
end Node_A;

architecture Behavioral of Node_A is
type rom_type is array (N-1 downto 0) of std_logic_vector(M-1 downto 0); -- Definiamo un tipo rom
signal ROM : rom_type := (
X"AB",  -- 171 in decimale
X"BC",  -- 188
X"CD",  -- 205
X"DE"); -- 222
    
constant ADDR_len : integer := 2;
signal mem_data_out : std_logic_vector(M-1 downto 0);


signal count_done : std_logic :='U';
signal ADDR : std_logic_vector (0 to ADDR_len-1) := (others => '0');

component counter_mod_n 
    generic(
        N           : integer :=16;                                -- Max value
        Bit_number  : integer := 4;                                -- 2^Bit_number al pi? = N
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

signal ready_to_send : std_logic;
signal send_ok : std_logic;

component Transmitter 
    generic(
        Num_Packets:Integer:=8;     --  Numero di pacchetti che formano un messaggio 
        Packet_Bits: Integer:=1     --  Numero di bits in un pacchetto
    );
    port(
        ck,rst:   in std_logic; -- Clock e reset 
        send:     in std_logic; -- Segnale esterno che mi chiede di inviare il buffer 
        send_ok:  out std_logic;-- conferma che il buffer si e' iniziato ad inviare
        in_ready: out std_logic;-- Dice al trasmettitore che puo' prendersi il dato
        in_received: in std_logic; -- trasmettitore mi dice che ha preso il dato.
        data_buff: in std_logic_vector(0 to Num_Packets*Packet_Bits-1);-- Buffer di dati da inviare
        data_out: out std_logic_vector(0 to Packet_Bits-1);
        data_ready: out std_logic -- Enable logico del contatore del nodo A
    );
end component;

begin

contatore: counter_mod_n
    generic map (
        N           => N,
        Bit_number  => ADDR_len,                                -- 2^Bit_number al pi? = N
        CLK_period  => 10ns                               -- Periodo clock, supposto 1s
    )
    port map(
        enable => ready_to_send,
        load => '0',
        input_value => (others => '0'),
        ck => clk,
        rst => rst,
        cnt_done => count_done,
        count_value => ADDR
    );  

mem: process (clk)
begin
    if(clk'event and clk='1') then    
        mem_data_out<=ROM(to_integer(unsigned(ADDR)));
    end if;
end process;

trasmettitore : Transmitter 
    generic map(
        Num_Packets => Num_Packets,     --  Numero di pacchetti che formano un messaggio 
        Packet_Bits => Packet_Bits    --  Numero di bits in un pacchetto
    )
    port map(
        ck => clk,
        rst => rst,
        send => ready_to_send, -- Segnale esterno che mi chiede di inviare il buffer 
        send_ok => send_ok,-- conferma che il buffer si e' iniziato ad inviare
        in_ready => in_ready, -- Dice al trasmettitore che puo' prendersi il dato
        in_received => in_received, -- trasmettitore mi dice che ha preso il dato.
        data_buff => mem_data_out,
        data_out => data_out,
        data_ready => ready_to_send -- Enable logico del contatore del nodo A
    );

end Behavioral;