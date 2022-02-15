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
        N: integer := 4;    -- numero di Pacchetti
        M: integer := 8;    -- Lunghezza di un numero
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

-- Definizione della rom in cui teniamo i valori da sommare
-- ROM valori di B
type rom_type is array (N-1 downto 0) of std_logic_vector(M-1 downto 0); -- Definiamo un tipo rom
constant ROM : rom_type := ( -- diamo un valore costante come rom.
    X"26",  -- 38 in decimale
    X"FF",  -- 255
    X"BD",  -- 189
    X"58"); -- 88
type mem_type is array (N-1 downto 0) of std_logic_vector(2*M-1 downto 0);    -- definiamo un tipo memoria in cui andare a salvare i valori
signal MEM: mem_type:=(others=>(others=>'0')); -- memoria in cui salvo i valori.
-- Contatore per indirizzare i componenti
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

-- Segnali contatore
constant ADDR_len : integer := 2; -- lunghezza del bit di indirizzo della rom
signal mem_load : std_logic := '0'; -- dico alla mia memoria di salvare il dato 
signal count_done : std_logic :='U';                                 -- segnale di appoggio da dare al contatore
signal ADDR : std_logic_vector (0 to ADDR_len-1) := (others => '0'); -- Indirizzo da dare alla rom
signal counter_strobe: std_logic:='0'; -- strobe da dare al contatore
-- Ricevitore
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
        data_ready: out std_logic; -- Il data_out ha valore, e' possibile prenderlo.
        data_taken:in std_logic    -- Segnale in input che ci dice che il dato e' stato preso
    );  
end component;
-- Segnali ricevitore
signal dato_ricevuto : std_logic := '0'; -- Segnale di dato ricevuto, associato a data ready
signal data_taken:std_logic:='0'; -- segnale di dato preso. 
signal buffer_ricevuto : std_logic_vector (0 to M-1);-- buffer in cui il ricevitore inserisce il dato ricevuto
--signal mem_data_out : std_logic_vector (0 to M-1);

-- Q0: Il ricevitore non ha ancora fornito data ready.
-- Q1: il ricevitore ha fornito il dato, ho preso il dato e la rom
-- Q2: Ho messo data taken ad 1, aspetto che il ricevitore mi dia 0, qualora ci rimanga levo lo strobe al contatore dato nella transizione Q1-> Q2, in cui ho messo la somma a 0
type stato_controller  is (q0,q1,q2);
signal mem_data_in : std_logic_vector (0 to 2*M-1) := (others => '0');
signal stato_attuale_controller:stato_controller:=q0;
begin

contatore: counter_mod_n
    generic map (
        N           => N,
        Bit_number  => ADDR_len,                          -- 2^Bit_number al più = N
        CLK_period  => 10ns                               -- Periodo clock, supposto 1s
    )
    port map(
        enable => counter_strobe,                          
        load => '0',
        input_value => (others => '0'),
        ck => clk,
        rst => rst,
        cnt_done => count_done,
        count_value => ADDR
    );  
    
ricevitore : Receiver 
    generic map(
        Num_Packets => Num_Packets,     --  Numero di pacchetti che formano un messaggio 
        Packet_Bits => Packet_Bits      --  Numero di bits in un pacchetto
    )
    port map(
        ck => clk,                      
        rst => rst,
        in_ready => in_ready,
        in_received => in_received,
        data_in => data_in,
        data_out => buffer_ricevuto,
        data_ready => dato_ricevuto,
        data_taken=>data_taken
        
    );
 
controller: process (clk)
variable sum:integer;
--variable op2:std_logic_vector(0 to M-1);
begin
    if( clk'event and clk='1') then
        if (rst='1') then 
            stato_attuale_controller<=q0;
            data_taken<='0';
            counter_strobe<='0';
        else
         case stato_attuale_controller is
            -- Nello stato q0 aspetto il dato in ingresso, non appena arriva calcolo la somma e passo a q1
            when q0=>
                if(dato_ricevuto='0') then
                    stato_attuale_controller<=q0;
                elsif(dato_ricevuto='1') then 
                     stato_attuale_controller<=q1; -- cambia stato e salva gli operandi
                     sum:=to_integer(unsigned(buffer_ricevuto))+to_integer(unsigned(ROM(to_integer(unsigned(ADDR)))));
                     --op2:=ROM(to_integer(unsigned(ADDR)));
                end if;
                counter_strobe<='0';
                data_taken<='0';
            -- Stato di transizione, salvo somma, metto data taken per hand shake e do il conteggio
            when q1=>
                data_taken<='1';
                MEM(to_integer(unsigned(ADDR)))<=std_logic_vector(to_unsigned(sum,2*M-1));
                counter_strobe<='1';
               
            when q2=>
                counter_strobe<='0'; -- in ogni caso glielo devo togliere
                if(dato_ricevuto='1') then
                    stato_attuale_controller<=q2;
                elsif(dato_ricevuto='0') then
                     stato_attuale_controller<=q0;
                     data_taken<='0';
                end if;
         end case;
        end if; -- fine controllo reset
    end if;
end process;
    
end Behavioral;
