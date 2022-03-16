library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;
entity Receiver is
    generic(
        --  Numero di pacchetti che formano un messaggio 
        Num_Packets:Integer:= 8;  
        --  Numero di bits in un pacchetto   
        Packet_Bits: Integer:= 1     
    );
    port(
        --  Clock e reset
        ck,rst:   in std_logic;  
        -- Trasmettitore ha messo il dato
        in_ready: in std_logic; 
        -- Dico di aver preso il dato
        in_received: out std_logic; 
        -- Dico di aver ricevuto la richiesta
        in_ack : out std_logic;
        -- Buffer di dati in output
        data_out: out std_logic_vector(0 to Num_Packets*Packet_Bits-1);
        -- Dati in input
        data_in: in std_logic_vector(0 to Packet_Bits-1);
        -- Data Ready
        data_ready: out std_logic;
        -- Data Read
        data_read:  in std_logic
    ); 

end Receiver;

architecture Behavioral of Receiver is
--  Q0 e' lo stato in cui il ricevitore aspetta in ready
--  Q1 e' lo stato in cui conferma il dato con l'ack
--  Q2 e' lo stato in cui prende il dato ed alza l'in_received
--  Q3 e' lo stato in cui aspetta che l'in_ready vada a 0
--  Q4 e' lo stato di transizione in cui decide se deve ricevere ancora o andare in Q0
--  Q5 e' lo stato in cui ricomincia la ricezione, continua ad aspettare che in ready diventi alto.
type stato is (q0,q1,q2,q3,q4,q5);
signal stato_attuale: stato:=q0;
signal stato_prossimo: stato;
signal counter:integer:=0;
-- Buffer contenente i dati ricevuti
signal data_buff: std_logic_vector( 0 to Num_Packets*Packet_Bits-1);
-- Abilita la scrittura del dato in uscita
signal out_enable:std_logic:='0';
begin
update_out: process(ck) 
begin
    if (ck'event and ck='0') then
        if (out_enable='1') then
            data_ready<='1';
            data_out<=data_buff;
         elsif (out_enable ='0' and data_read='1') then
            data_ready<='0';
         end if;
    end if;
end process;
automa_update:process(ck)
begin
    if(ck'event and ck='1')then
        if(rst='1') then
            stato_attuale<=q0;
        elsif (rst='0')then
            stato_attuale<=stato_prossimo;
         end if;
     end if;
end process;
automa: process(stato_attuale, in_ready) 
begin
    case stato_attuale is
        when q0=>
            out_enable<='0';
            if(in_ready='0')then
                stato_prossimo<=q0;
            elsif (in_ready='1') then
                stato_prossimo<=q1;
                counter<=0;
                data_buff<=(others=>'0');
             end if;
       when q1=>
            in_ack<='1';
            data_buff(counter*Packet_Bits to counter*Packet_Bits+Packet_Bits-1) <=data_in;
            stato_prossimo<=q2;
            counter<=counter+1;
       when q2=>
            in_received<='1';
            stato_prossimo<=q3;
       when q3=>
            -- Do piu' tempo per vedere ack, per questo lo disattivo qui e non prima
            in_ack<='0';
            if( in_ready='1') then
                stato_prossimo<=q3;
            elsif(in_ready='0') then
                in_received<='0';
                stato_prossimo<=q4;
            end if;
        when q4=>
            if(counter=Num_Packets) then
                out_enable<='1';
                stato_prossimo<=q0;
            else 
                stato_prossimo<=q5;
            end if;
        when q5=>
            if(in_ready='0')then
                stato_prossimo<=q5;
            elsif (in_ready='1') then
                stato_prossimo<=q1;
             end if;
    end case;
  end process;
end Behavioral;
