----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Antonio Emmanuele, Giuseppe De Rosa
-- 
-- Create Date: 13.02.2022 08:58:11
-- Design Name: 
-- Module Name: Reveiver - Behavioral
-- Project Name: Esercizio Handshaking
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

-- Questo ricevitore funziona con un handshake classico.
-- 1- Il trasmettitore mette un pacchetto nella linea, pacchetto che puo' essere da 1 o piu' bit a seconda del parallelismo, mette ready ad alto.
-- 2- Il ricevitore vede ready ad alto, ottiene il dato e mette in_received ad alto.
-- 3- Il trasmettitore, vedendo in_received alto abbassa ready.
-- 4- Il ricevitore vedendo ready basso abbassa in_received.
-- 5- A questo punto si devono distinguere i casi:
--      5.1- Se ho ricevuto tutti i pacchetti allora ritorno in uno stato iniziale
--      5.2- Se non ho ricevuto tutti i pacchetti allora aspetto che ready si alzi per ottenere il successivo.
entity Receiver is
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
end Receiver;

architecture Behavioral of Receiver is
-- q0: Non ho ricevuto alcun pacchetto ed ready continua ad essere false
-- q1: Ready e' stato messo ad 1 ed ho ottenuto il dato. Questo e' uno stato di transizione che mi serve per fare alzare in_received
-- q2: Aspetto che in ingresso diventi basso il segnale ready, quando lo diventa abbasso in_received e vado in q3.
-- q3: Questo come q1 e' uno stato di transizione. Controllo il contatore per vedere se ho ricevuto tutti i pacchetti.
--      Se ho  ricevuto tutti i pacchetti torno in q0 con in_received basso.
--      Senno' vado in q4
-- q4:  Mi preparo per ottenere un altro segnale
type stato is (q0,q1,q2,q3,q4);
signal received_counter:integer:=0; -- Contatore di pacchetti ricevuti
--signal stato_corrente: stato:=q0;
signal stato_attuale:stato:=q0;
signal data_helper:std_logic_vector( 0 to Num_Packets*Packet_Bits-1);
signal data_ready_h:std_logic:='0';
begin
   -- data_out<= data_helper;
    data_ready<=data_ready_h;
    state_machine: process(ck)
    begin
        if( ck'event and ck='1') then 
            if(rst='1') then
                stato_attuale<=q0;
                in_received<='0';
                received_counter<=0;
                data_ready_h<='0';
                data_helper<=(others=>'0');
             else 
                case stato_attuale is
                    when q0=>
                        if(data_ready_h='1' and data_taken='1') then
                            data_ready_h<='0' ; 
                        end if;
                        if(in_ready='0') then  -- se ready e' 0 non devo fare nulla
                            stato_attuale<=q0;
                        else    -- Altrimenti devo portarmi in q1 e prendere il dato
                            stato_attuale<=q1;
                            data_helper( 0 to Packet_Bits-1)<=data_in; -- occupo i primi packet Bits
                            received_counter<=received_counter+1; -- Incremento il contatore
                            --data_ready<='0'; 
                        end if;
                    when q1=> -- Questo stato ha il solo compito di mettere received ad 1 e portarmi in q2
                        if(data_ready_h='1' and data_taken='1') then
                            data_ready_h<='0' ; 
                        end if;
                        in_received<='1';
                        stato_attuale<=q2;
                    when q2=> -- Aspetto che diventi 0 in_ready
                        if(data_ready_h='1' and data_taken='1') then
                            data_ready_h<='0' ; 
                        end if;
                        if(in_ready='1') then  
                            stato_attuale<=q2;
                        else  -- Non abbasso ancora l'in_received perche' il ricevitore deve prima capire lui in che stato portarsi
                            stato_attuale<=q3;
                        end if;
                    when q3=> -- in questo stato va effettuato il controllo sul contatore.
                        if(data_ready_h='1' and data_taken='1') then
                            data_ready_h<='0' ; 
                        end if;
                        if(received_counter=Num_Packets) then -- Se abbiamo ricevuto tutti i pacchetti
                            stato_attuale<=q0;
                            received_counter<=0; -- Azzero il contatore, questo se usassimo un oggetto contatore esterno non e' detto che dovremmo farlo.
                            data_ready_h<='1';
                            data_out<=data_helper;
                        else    -- Altrimenti lo stato prossimo deve essere q4
                            stato_attuale<=q4;
                        end if;
                        in_received<='0';
                    when q4=> -- Stato di campionamento dei bit intermedi
                        if(data_ready_h='1' and data_taken='1') then
                            data_ready_h<='0' ; 
                        end if;
                        if(in_ready='0') then  -- se ready e' 0 non devo fare nulla
                            stato_attuale<=q4;
                        else    
                            stato_attuale<=q1;
                            -- NB: Stiamo andando cosi a calcolare un offset come faremmo in C.
                            -- Questo puo' portare alla sintesi aggiuntiva di macchine non volute, tipo un moltiplicatore.
                            -- Al momento pero' non ce ne curiamo perche' stiamo testando il solo funzionamento dell'automa.
                            data_helper( Packet_Bits*received_counter to Packet_Bits*received_counter+Packet_Bits-1)<=data_in; -- Offset dato da quanti bits abbiamo gia' ricevuto, Packet_Bits*received_counter
                            received_counter<=received_counter+1; -- Incremento il contatore
                        end if;
                end case; -- case stato
            end if; -- if rst
        end if;-- if clock
    end process;

end Behavioral;
