----------------------------------------------------------------------------------
-- Nome Esercizio: Registro a scorrimento Structural.
-- Numero Esercizio:  4.
-- Autori: Antonio Emmanuele, Giuseppe De Rosa.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ff_et is
    --  TO DO:
    --      Dovrei in una implementazione piu' realistica fare un controllo sui tempi di setup e di hold
    --      I tempi andrebbero specificati come parametri qui nel generic.  
    generic(
        RISING :std_logic:='1'
    );
    port(
        CK:     IN std_logic;   --  Clock del flip flop edge triggered
        RST:    IN std_logic;   --  Segnale di reset 
        D:      IN std_logic;   --  Segnale di dato 
        Q:      OUT std_logic   --  Segnale di uscita 
    );
end ff_et;

architecture Behavioral of ff_et is      
    begin
        main: process(CK)
            variable state: std_logic;   -- Variabile che rappresenta lo stato
            begin
                if(CK'EVENT and CK=RISING) then -- Effettuo il controllo direttamente con rising per paragonarlo al fronte di clock con cui voglio lavori.
                    if(RST='1') then
                        state:='0';
                    else -- Altrimenti devo aggiornare lo stato
                        state:=D;
                    end if;     --fine controllo reset
                    Q<=state;   --Salvo l'uscita
                end if;         -- fine controllo clock
        end process main;
end Behavioral;
