----------------------------------------------------------------------------------
-- Nome Esercizio: Registro a scorrimento Structural.
-- Numero Esercizio:  4.
-- Autori: Antonio Emmanuele, Giuseppe De Rosa.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.ALL;

entity generic_mux is
    generic(
        N:integer:=2;      --Numero di bit di input.
        M:integer:=1       --Numero di bit del segnale di selezione,deve essere tale che 2^M=N.
    );
    port(
        input:      IN std_logic_vector(0 to N-1);     --  N bits in ingresso
        sel:        IN std_logic_vector(0 to M-1);  --  M bits di selezione
        out_in:     OUT std_logic                   --  Segnale di uscita
    );
end generic_mux;

-- Implementazione puramente behavioural, fatta velocemente per testare lo sr
architecture Behavioral of generic_mux is
begin
    change:process(input,sel)
        begin
            out_in<= input(to_integer(unsigned(sel))); -- Uso direttamente la codifica in intero per indirizzare l'uscita.
     end process change;
end Behavioral;
