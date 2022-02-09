library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Questo e' il registro di appoggio in cui mettiamo l'input prima di darlo al cronometro.
entity Rete_input is
port(
  signal input:     in std_logic_vector(0 to 5);    --  switch in input
  signal sel:       in std_logic_vector(0 to 1);    --  segnale di decisione
  signal output:    out std_logic_vector(0 to 16)   --  Valore del registro in uscita
  );   
end Rete_input;

architecture Dataflow of Rete_input is
signal helper: std_logic_vector(0 to 16);
begin
    selection:process(sel)
    begin
        case sel is
            when "00" => helper(0 to 5) <= input;           --  Se 00 imposta i secondi
            when "01" => helper(6 to 11) <= input;          --  Se 01 imposta i minuti
            when "10" => helper(12 to 16) <= input(0 to 4); --  Se 10 imposta le ore
            when others => helper <=helper;                 --  Altrimenti non far nulla.
        end case;
    end process;
    output<=helper;
end Dataflow;