----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.02.2022 17:38:53
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
    -- Riceviamo 4 stringhe da 8 bit
    generic(
        N: integer := 4;
        M: integer := 8;
        Num_Packets:Integer:=8;     --  Numero di pacchetti che formano un messaggio 
        Packet_Bits: Integer:=1     --  Numero di bits in un pacchetto
    );
    port(
        clk,rst:   in std_logic; -- Clock e reset 
        in_ready: in std_logic; -- Segnale di ready dato dal trasmettitore
        in_received: out std_logic;  -- Conferma di avvenuta lettura
        data_in: in std_logic_vector(0 to Packet_Bits-1) -- dati in ingresso messi dal trasmettitore
    );  
end Node_B;

architecture Behavioral of Node_B is

constant ADDR_len : integer := 2;
signal mem_data_in : std_logic_vector (0 to 2*M-1) := (others => '0');
signal mem_load : std_logic := '0';

-- Memoria precaricata dei valori
component Memory
    generic (
        N: integer := 4;
        M: integer := 8;
        N_BitNum : integer := 2
    );
    port(
        CLK : in std_logic; -- clock della board
        RST : in std_logic;
        READ : in std_logic; -- segnale che abilita la lettura, inserito tramite un bottone
        LOAD : in std_logic; 
        INPUT : in std_logic_vector (M-1 downto 0); 
        ADDR : in std_logic_vector(N_BitNum-1 downto 0); --2 bit di indirizzo per accedere agli elementi della ROM,
        DATA : out std_logic_vector(M-1 downto 0) -- dato su 8 bit letto dalla ROM
        );
end component;

signal count_done : std_logic :='U';
signal ADDR : std_logic_vector (0 to ADDR_len-1) := (others => '0');

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

signal dato_ricevuto : std_logic := '0';
signal buffer_ricevuto : std_logic_vector (0 to M-1);
signal mem_data_out : std_logic_vector (0 to M-1);

component Receiver 
    generic(
        Num_Packets:Integer:=8;     --  Numero di pacchetti che formano un messaggio 
        Packet_Bits: Integer:=1     --  Numero di bits in un pacchetto
    );
    port(
        ck,rst:   in std_logic; -- Clock e reset 
        in_ready: in std_logic; -- Segnale di ready dato dal trasmettitore
        in_received: out std_logic;  -- Conferma di avvenuta lettura
        data_in: in std_logic_vector(0 to Packet_Bits-1); -- dati in ingresso messi dal trasmettitore
        data_out: out std_logic_vector( 0 to Num_Packets*Packet_Bits-1); -- Intero dato ricostruito
        data_ready: out std_logic
    );  
end component;

-- ROM valori di B
type rom_type is array (N-1 downto 0) of std_logic_vector(M-1 downto 0);
signal ROM : rom_type := (
    X"26",  -- 38 in decimale
    X"FF",  -- 255
    X"BD",  -- 189
    X"58"); -- 88

begin

contatore: counter_mod_n
    generic map (
        N           => N,
        Bit_number  => ADDR_len,                                -- 2^Bit_number al più = N
        CLK_period  => 10ns                               -- Periodo clock, supposto 1s
    )
    port map(
        enable => dato_ricevuto,
        load => '0',
        input_value => (others => '0'),
        ck => clk,
        rst => rst,
        cnt_done => count_done,
        count_value => ADDR
    );  
    
memoria: Memory 
    generic map (
        N => N,
        M => 2*M,
        N_BitNum => ADDR_len
    )
    port map (
        CLK => clk,
        RST => rst,
        READ => '0',
        LOAD => mem_load, 
        INPUT => mem_data_in,
        ADDR => ADDR,
        DATA => mem_data_out
    );

ricevitore : Receiver 
    generic map(
        Num_Packets => 8,     --  Numero di pacchetti che formano un messaggio 
        Packet_Bits => 1     --  Numero di bits in un pacchetto
    )
    port map(
        ck => clk,
        rst => rst,
        in_ready => in_ready,
        in_received => in_received,
        data_in => data_in,
        data_out => buffer_ricevuto,
        data_ready => dato_ricevuto
    );
    
prod: process (dato_ricevuto)
    variable prod : integer := 0;
    begin
        mem_load <= '1';
        prod := to_integer (unsigned(buffer_ricevuto)) 
        * to_integer(unsigned(ROM (to_integer(unsigned(ADDR)))));
        mem_data_in <= std_logic_vector(to_unsigned(prod, mem_data_in'length));
end process;

update: process (mem_load)
    begin
        if (mem_load = '1') then
            ROM(to_integer(unsigned(ADDR))) <= mem_data_in;
            mem_load <= '0';
        end if;
end process;  
    
end Behavioral;
