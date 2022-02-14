----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.02.2022 16:28:39
-- Design Name: 
-- Module Name: Transmitter - Behavioral
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

entity Transmitter is
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
end Transmitter;

architecture Behavioral of Transmitter is

-- q0: Non ho alcun dato da inviare, nel momento in cui ricevo un dato da inviare lo incomincio ad inviare ed incremento il contatore 
-- q1: Metto ready ad 1
-- q2: Aspetto che il ricevitore mi dia conferma con in_received, come diventa alto vado nello stato q3
-- q3: Questo come q1 e' uno stato di transizione. Controllo il contatore per vedere se ho inviato tutti i pacchetti.
--      Se ho  inviato tutti i pacchetti torno in q0 
--      Senno' vado in q4
--      In ogni caso in_ready viene abbassato
-- q4:  Vado ad inviare di nuovo
type stato is (q0,q1,q2,q3,q4);
signal sended_counter:integer:=0; -- Contatore di pacchetti ricevuti
signal stato_attuale:stato:=q0;
begin
  state_machine: process(ck)
    begin
        if( ck'event and ck='1') then 
            if(rst='1') then
                stato_attuale<=q0;
                sended_counter<=0;
                data_out<=(others =>'0');
                data_ready <= '1'; 
             else 
                case stato_attuale is
                    when q0=>
                        if(send='0') then  
                            stato_attuale<=q0;
                            data_ready <= '1'; 
                        else    
                            stato_attuale<=q1;
                            send_ok<='1'; -- conferma di inizio trasmissione
                            data_out<=data_buff(0 to Packet_Bits-1); --Invia
                            --data_helper( 0 to Packet_Bits-1)<=data_in; -- occupo i primi packet Bits
                            sended_counter<=sended_counter+1; -- Incremento il contatore
                            data_ready <= '0';                                                       
                        end if; 
                    when q1=> -- Questo stato ha il solo compito di mettere ready ad 1 e portarmi in q2
                        in_ready<='1';
                        stato_attuale<=q2;
                    when q2=> -- Aspetto che diventi 1 in_received, ossia che il ricevitore mi dia conferma di lettura
                        if(in_received='0') then  
                            stato_attuale<=q2;
                        else  
                            stato_attuale<=q3;
                        end if;
                    when q3=> -- in questo stato va effettuato il controllo sul contatore.
                        if(sended_counter=Num_Packets) then -- Se abbiamo inviato tutti i pacchetti
                            stato_attuale<=q0;
                            sended_counter<=0; -- Azzero il contatore, questo se usassimo un oggetto contatore esterno non e' detto che dovremmo farlo.
                            data_ready <= '1';
                        else   
                            stato_attuale<=q4;
                        end if;
                        in_ready<='0'; -- Metto a 0 in ogni caso
                    when q4=> -- Devo inviare e ripassare a q1
                           stato_attuale<=q1;       
                           sended_counter<=sended_counter+1; -- Incremento il contatore
                           data_out<=data_buff( Packet_Bits*sended_counter to Packet_Bits*sended_counter+Packet_Bits-1); 
                end case; -- case stato
            end if; -- if rst
        end if;-- if clock
    end process;
    
    -- Send e Send_Ok sono sostanzialnmente un ulteriore handshake tra il trasmettitore e chi vuole trasferire il dato, 
    -- per non appesantire il progetto e' stato, in maniera semplicistica, gestito il segnale in questa maniera senza un automa.
    -- send ok deve diventare 1 quando inizio a trasmettere il dato e deve diventare 0 quando il terzo abbassa send oppure quando
    -- si ritorna in q0
    send_ok_helper: process(ck)
    begin
         if( ck'event and ck='1') then 
            if(stato_attuale/=q0 and send='1') then
                send_ok<='1';
            else
                send_ok<='0';
            end if;
         end if;
    end process;


end Behavioral;
