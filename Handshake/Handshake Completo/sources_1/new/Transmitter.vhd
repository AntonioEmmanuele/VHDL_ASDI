library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Transmitter is
    generic(
        --  Numero di pacchetti che formano un messaggio 
        Num_Packets:Integer:= 8;  
        --  Numero di bits in un pacchetto   
        Packet_Bits: Integer:= 1     
    );
    port(
        -- Clock e reset
        ck,rst:   in std_logic;  
        -- Segnale esterno che mi chiede di inviare il buffer 
        send:     in std_logic; 
        -- Dice al ricevitore che puo' prendersi il dato
        in_ready: out std_logic;
        -- ricevitore mi dice che ha preso il dato.
        in_received: in std_logic; 
        -- Data ack
        in_ack : in std_logic;
        -- Buffer di dati da inviare
        data_buff: in std_logic_vector(0 to Num_Packets*Packet_Bits-1);
        data_out: out std_logic_vector(0 to Packet_Bits-1);
        -- Enable logico del contatore del nodo A
        ready_to_send: out std_logic 
    );
end Transmitter;

architecture Behavioral of Transmitter is

type stato is (q0_1,q0_2,q1,q2,q3,q4,q5,qwait);

signal counter : integer := 0;
signal stato_attuale : stato:=q0_1;
signal stato_prossimo : stato := q0_1;
signal data_to_tsmt: std_logic_vector(0 to Num_Packets*Packet_Bits-1);
begin

trasmettitore : process (stato_attuale, send, in_received, in_ack)
    begin
        case stato_attuale is
            when q0_1 => 
                ready_to_send <= '1';
                if (send = '0') then
                    stato_prossimo <= q0_1;
                    data_out <= (others => '0');
                    in_ready <= '0';
                    --ready_to_send <= '1';
                    counter <= 0;
            
                elsif (send = '1') then
                   -- ready_to_send <= '0'; 
                    data_to_tsmt <= data_buff ;
                    --counter <= counter+1;
                    stato_prossimo <= q0_2;
                end if;
            when q0_2=>
                counter <= counter+1;
                stato_prossimo<=q1;
                data_out <= data_to_tsmt (0 to Packet_Bits-1);
            when q1 =>
                ready_to_send <= '0'; 
                in_ready <= '1';
                stato_prossimo <= q2;
            when q2 => 
                if (in_ack = '1') then
                    stato_prossimo <= q3;
                elsif (in_ack = '0') then
                    stato_prossimo <= q2;
                end if;
            when q3 => 
                if (in_received = '1') then
                    stato_prossimo <= q4;
                    in_ready <= '0';
                elsif (in_received = '0') then
                    stato_prossimo <= q3;
                end if;
            when q4 => 
                if (counter = Num_Packets) then
                    stato_prossimo <= qwait;
                elsif (counter < Num_Packets) then
                    stato_prossimo <= q5;
                end if;
            when q5 => 
                data_out <= data_to_tsmt (counter*Packet_Bits to counter*Packet_Bits+Packet_Bits-1);
                counter <= counter+1;
                stato_prossimo <= q1;
            when qwait => 
                if (send = '1') then
                    stato_prossimo <= qwait;
                elsif (send = '0') then
                    stato_prossimo <= q0_1;
                    ready_to_send <= '1';
                end if;
        end case;
    
end process;

update : process (ck)
    begin
        if (ck = '1' and ck'event) then
            if (rst = '1') then
                stato_attuale <= q0_1;
            elsif (rst = '0') then
                stato_attuale <= stato_prossimo;
            end if;
        end if;
end process;
 
end Behavioral;
