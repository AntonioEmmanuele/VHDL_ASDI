library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--  Voglio realizzare un multiplexer 2:1
--  Dichiarare un entity di un componente e' come dichiarare il pinout di un circuito integrato
--  Ogni pin puo' essere sia di input che di output.
--  Un pin di input puo' solo essere letto un pin di output puo' solo essere scritto
--  Abbiamo anche 2 altre tipologie di pin che sono:
entity mux_2_1 is
    port(
        --  STD_LOGIC e' un tipo del VHDL.
        --  In pratica il tipo bit puo' rappresentare solo valori come 0 ed 1
        --  STD_LOGIC invece puo' rappresentare vari tipi diversi che spaziano dal 
        --  U -> Non inizializzato
        --  X -> Sconosciuto
        --  0,1 ed Z (alta impedenza(
        --  W -> Segnale debole, non posso dire se 0 o 1
        --  L -> Debolmente 0
        --  H  -> Debolmente 1
        --  -  -> Don't care
        a0: in STD_LOGIC;-- Primo ingresso del mux
        a1: in STD_LOGIC;
        s:  in STD_LOGIC;-- Segnale di selezione
        y:  out STD_LOGIC -- Uscita
        );
end mux_2_1;

--  Una entity puo' avere diverse " implementazioni che chiamiamo architectures.
--  Una architecture ha un nome e si riferisce ad un'unica entity
--  Le architectures possono principalmente essere di 3 tipi
--  Dataflow -> Uscite dell'integrato vengono specificate mediante una equazione, descriviamo proprio il flusso di dati
--  Strutturale -> Uscite dell'integrato/entity vengono calcolate mediante la composizione di altre macchine 
--  Behavioural -> Uscite dell'integrato/entity vengono calcolate mediante una descrizione ad alto livello
architecture Dataflow of mux_2_1 is
--Qui vanno inseriti tutti i segnali intermedi ed in generale le dichiarazioni che servono all'architecture
begin
    --Reale implementazione
    y <= (a0 AND (NOT s)) OR ( a1 AND ( s)); -- Esce a0 se y=0 altrimenti esce 1
end Dataflow;
