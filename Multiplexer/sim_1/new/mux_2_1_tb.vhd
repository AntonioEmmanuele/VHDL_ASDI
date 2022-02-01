-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

--  Un TB e' un'entity che non alcuna ragione di comunicare con l'esterno.
--  L'unico obiettivo del TB e' quello di istanziare il componente che vogliamo testare.
--  Istanziare un componente ci ricorda la distinzione tra classe ed oggetto.
--  In input al componente vanno associati ai pin dei segnali.
--  Quindi dando specifici valori ai segnali di input ci aspettiamo specifici valori nei segnali di output.
--  Un poco come il test di unita'.
entity mux_2_1_tb is
    -- TB e' una entity che non ha pin.
end;

architecture bench of mux_2_1_tb is
  --Per istanziare il componente per prima cosa devo dichiararlo.
  component mux_2_1
      port(
          a0: in STD_LOGIC;
          a1: in STD_LOGIC;
          s:  in STD_LOGIC;
          y:  out STD_LOGIC
          );
  end component;

  --    Dichiaro dei segnali intermedi.
  --    Ricordati che un segnale in VHDL ha delle regole di assegnazioni parallele e concorrenti.
  --    Ogni assegnazione di un segnale avviene all'istante T e viene schedulata all'istante T+DELTA.
  signal a0_itm: STD_LOGIC;
  signal a1_itm: STD_LOGIC;
  signal s_itm: STD_LOGIC;
  signal y_itm: STD_LOGIC ;

begin
  --    uut -> Unit Under Test
  --    uut e' il nome che diamo al componente che istanziamo.
  --    L'istanziazione coincide dunque con un portmap ossia con l'associare dei pins
  uut: mux_2_1 port map ( a0 => a0_itm,
                          a1 => a1_itm,
                          s  => s_itm,
                          y  => y_itm );

  --    Cosa e' un process?
  --    Un process e' un blocco di istruzioni che vengono eseguite in maniera sequenziale.
  --    Un process si attiva quando uno dei segnali in input (sensitivity list) cambiano di valore.
  --    In questo caso non ho alcun segnale in input ma semplicemente esegue una sola volta e poi si pone in attesa eterna.
  --    Il nome di questo process e' stimulus, proprio perche' andiamo a fornire diversi stimoli ai segnali. 
  stimulus: process
  begin
  
    -- Put initialisation code here


    -- Put test bench stimulus code here
    wait for 10 ns; --aspetto 10 ns
        a0_itm<='0'; -- Tutte queste assegnazioni avvengono a T e vengono schedulate per T+delta
        a1_itm<='1';
        s_itm<='0'; 
    wait for 10 ns;
        assert y_itm='0' report " Uscita dovrebbe essere 0" severity failure; -- Come nei linguaggi di alto livello e' possibile usare un assert ossia dire che uscita ci si aspetta
                                                                              -- In questo caso e' possibile definire un messaggio di errore, report ed un provvedimento da prendere(severity).
                                                                              -- Il provvedimento in tal caso coincide con un NOTE,WARNING,ERROR,FAILURE e puo' o meno fermare la simulazione 
                                                                              -- I controlli li faccio dopo e non stesso nel blocco del wait proprio perche' assegnazione del segnale avviene a T+delta
        a0_itm<='0'; -- Tutte queste assegnazioni avvengono a T e vengono schedulate per T+delta
        a1_itm<='1';
        s_itm<='1'; 
       -- assert y_itm='1' report " Uscita dovrebbe essere 1" severity failure; 
        
    wait for 10 ns;
        assert y_itm='1' report " Uscita dovrebbe essere 1" severity failure;
        a0_itm<='1'; -- Tutte queste assegnazioni avvengono a T e vengono schedulate per T+delta
        a1_itm<='0';
        s_itm<='0'; 
       
    wait for 10 ns;
         assert y_itm='1' report " Uscita dovrebbe essere 1" severity failure;
        a0_itm<='1'; -- Tutte queste assegnazioni avvengono a T e vengono schedulate per T+delta
        a1_itm<='0';
        s_itm<='1';  
    wait for 10 ns;
        assert y_itm='0' report " Uscita dovrebbe essere 0" severity failure;
        a0_itm<='1'; -- Tutte queste assegnazioni avvengono a T e vengono schedulate per T+delta
        a1_itm<='1';
        s_itm<='0';
         
    wait for 10 ns;
        assert y_itm='0' report " Uscita dovrebbe essere 0,fatto apposta" severity failure; --Qui dara' errore.
   
    wait;
  end process;


end;