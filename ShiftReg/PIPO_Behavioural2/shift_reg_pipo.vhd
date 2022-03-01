----------------------------------------------------------------------------------
-- Nome Esercizio: Registro a scorrimento Structural.
-- Numero Esercizio:  4.
-- Autori: Antonio Emmanuele, Giuseppe De Rosa.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;

-- Uno shift register si dice pipo se carica i valori in parallelo e li caccia fuori in parallelo.
-- Scriviamo uno shift register da 4 bit in caricamento parallelo  ed uscita parallela.
-- In questo registro si suppone, qualora si voglia shiftare, ossia ci sia shift enable
-- che e' possibile shiftare in un colpo di clock di piu' posizioni e che il numero di posizioni massimo di cui e' possibile
-- shiftare, a destra o a sinistra, sia di massimo N bits dove N e' il numero di bits dell'input.
-- 1*TCK in scrittura poiche' carica tutti i bit in parallelo.
-- 1*TCK in lettura poiche' li legge tutti in parallelo
-- 1*TCK per shiftare.
-- NB:  In questa versione non ci sono segnali che controllano lo shift e la memorizzazione, la modalita' di funzionamento (memorizzazione shift) e' implicitamente decisa dal valore di shift.
--      Se si ha un registro di 4 bits ed shift="00" allora dobbiamo shiftare di 0 bits, ergo siamo in modalita' di MEMORIZZAZIONE.
--      Si e' presa questa scelta per ridurre la componentistica nella rete di controllo ed il numero di pin di input.
entity shift_reg_pipo  is
generic (
    N_Bits:integer:=4;       -- N_Bits e' il numero di bits in ingresso, quindi questo registro a scorrimento carica in parallelo 4 
    Shift_Bits:integer:=2    -- Shift_Bits e' il numero di bits che compongono il segnale di shift tale che 2^M=N.   
);
port(
    CLK: in std_logic;                                  --      segnale di reset.
    RST: in std_logic;                                  --      segnale di clock
    shift: in std_logic_vector(0 to Shift_Bits-1);      --      Questo segnale vale 1 se si vuole shiftare.
    right_shift:in std_logic;                           --      Questo segnale vale 1 se si vuole shiftare a destra >>, se vale 0 allora si vuole shiftare a sinistra.
    Par_in: in std_logic_vector(0 to N_Bits-1);         --      Parallel Input
    Par_out:out std_logic_vector(0 to N_Bits-1)         --      Parallel Output
    );
end shift_reg_pipo ;

architecture Behavioral of shift_reg_pipo is
begin
  s_r:process(CLK)
        variable h: std_logic_vector(0 to N_Bits-1) := std_logic_vector(to_unsigned(0,N_Bits));
        begin
        if(rising_edge(CLK)) then 
            if(RST='1') then -- Se dobbiamo resettare allora 
                h:=std_logic_vector(to_unsigned(0,N_Bits)); -- resetta il valore iniziale
            else -- altrimenti, se non devo resettare.
                if(shift=std_logic_vector(to_unsigned(0,Shift_Bits))) then  -- Se devo memorizzare 
                    h:=Par_in; 
                    --Altrimenti se devo shiftare
                 else  
                    -- Shift a destra.
                    if(RIGHT_SHIFT='1') then
                    
                        -- Ad esempio si supponga di volere: x(0)  x(1) x(2) x(3) allora i primi tre sarebbero 0 e 'ultimo sarebbe x(0)
                        -- Quindi dovrei come prima cosa mettere x(3) =x(0) e poi i primi tre ad 1
                        -- 0 0 0 X(0)
                        -- Analogamente se shiftassi di 2 avrei: 0 0 X(0) X(1)     

                        -- Nell'esempio precedente X(3)=X(1) ed X(2)=X(1) la formula e' X(Y to N-1) = X(0 to N-1-Y) ossia nell'esempio precedente X( 2 to 3)= X(0 to 1)         
                        h(to_integer(unsigned(shift)) to N_Bits-1) :=h(0 to N_Bits-1-to_integer(unsigned(shift)));
                        -- Rispettando l'esempio precedente allora X(0 to 1) =0 ossia X(0 to Y-1)=0
                        h(0 to to_integer(unsigned(shift))-1  ) :=std_logic_vector(to_unsigned(0,to_integer(unsigned(shift))));
                     
                    --Shift a sinistra e' il complementare.
                    else     
                        
                        if( to_integer(unsigned(shift))>4) then -- stiamo codificando la selezione su 2^(m+1) bits, se sforiamo 4 allora mettiamo tutto a 0
                            h:=std_logic_vector(to_unsigned(0,N_Bits));
                        else
                            h(0 to N_Bits-1-to_integer(unsigned(shift))):= h(to_integer(unsigned(shift)) to N_Bits-1) ;
                            -- Questo secondo punto indica la posizione giusta da cui iniziare a mettere zeri ossia N-1-(Y-1).    
                            h( (N_Bits-1)-(to_integer(unsigned(shift))-1) to N_Bits-1):=std_logic_vector(to_unsigned(0,to_integer(unsigned(shift))));
                        end if;  -- controllo dimensione shift.
                        
                end if;-- controllo right shift
            end if; -- controllo mem enable   
        end if; -- controllo rst    
        Par_out<=h;      
     end if; --controllo ck
    end process s_r;

end Behavioral;
