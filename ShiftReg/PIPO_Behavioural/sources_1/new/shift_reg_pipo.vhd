----------------------------------------------------------------------------------
-- Nome Esercizio: Registro a scorrimento Behavioural.
-- Numero Esercizio:  4.
-- Autori: Antonio Emmanuele, Giuseppe De Rosa.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 

-- Uno shift register si dice pipo se carica i valori in parallelo e li caccia fuori in parallelo.
-- Scriviamo uno shift register da 4 bit in caricamento parallelo  ed uscita parallela.
-- In questo registro si suppone, qualora si voglia shiftare, ossia ci sia shift enable
-- che e' possibile shiftare in un colpo di clock di piu' posizioni e che il numero di posizioni massimo di cui e' possibile
-- shiftare, a destra o a sinistra, sia di massimo N bits dove N e' il numero di bits dell'input.
-- 1*TCK in scrittura poiche' carica tutti i bit in parallelo.
-- 1*TCK in lettura poiche' li legge tutti in parallelo
-- 1*TCK per shiftare.
entity shift_reg_pipo is
    generic(
        N:positive:=4;  --      N e' il numero di bits in ingresso, quindi questo registro a scorrimento carica in parallelo 4 
        M:positive:=3   --      M e' il numero bits che il segnale di shift deve avere. Il segnale di shift e' codificato, quindi se stiamo con 4 bits memorizzati allora dovremmo avere 2^2 valori ossia 2 bits.
                        --      in realta' abbiamo un problema dato dal fatto che il numero possibile di shift inizia da 0, ossia io posso shiftare di 0 posizioni fino ad arrivare a 4.
                        --      Se stiamo dunque memorizzando n= 2^m bits allora il segnale di shift deve avere m+1 bits, in questo caso specifico 3.
        );
      port(
        RST: IN std_logic;                                  --      segnale di reset.
        CLK: IN std_logic;                                  --      segnale di clock
        MEM_ENABLE: IN std_logic;                           --      Questo segnale abilita la memorizzazione . quindi quando questo segnale e' alto viene memorizzato il dato.
        SHIFT_ENABLE: IN std_logic;                         --      Questo segnale abilita la modalita' di shift, quindi quando questo segnale e' alto lo SR va a shiftare di y bits.
        RIGHT_SHIFT: IN std_logic;                          --      Questo segnale vale 1 se vogliamo shiftare a destra >>, se vale 0 allora dobbiamo shiftare a sinistra.
        Y: IN std_logic_vector(0 to M-1);                   --      Questo segnale fornisce il numero di bits da shiftare scelto dato in input dall'utente.
        X: IN std_logic_vector(0 to N-1);                   --      Questo e' l'input fornito dall'utente.
        PARALLEL_OUT: OUT std_logic_vector(0 to N-1)        --      Questo e' l'output fornito dal registro. 
      );
end shift_reg_pipo;

architecture Behavioral of shift_reg_pipo is
        --  Ci dichiariamo una segnale di appoggio  su cui andare ad operare (memorizzare e shiftare)
        --  Si noti che il caricamento parallelo viene fatto mettendo reg(0):=x(0) reg(1):=x(1) ecc
        --  signal h: std_logic_vector(N-1 downto 0) := std_logic_vector(to_unsigned(0,N)); 
begin
    s_r:process(CLK)
        variable h: std_logic_vector(0 to N-1) := std_logic_vector(to_unsigned(0,N));
        begin
        if(rising_edge(CLK)) then 
            if(RST='1') then -- Se dobbiamo resettare allora 
                h:=std_logic_vector(to_unsigned(0,N)); -- resetta il valore iniziale
            else -- altrimenti, se non devo resettare.
                if(MEM_ENABLE='1') then  -- Se devo memorizzare 
                    h:=X; 
                elsif( MEM_ENABLE='0' and SHIFT_ENABLE='1' ) then --  POSSO SHIFTARE SOLO QUANDO NON DEVO MEMORIZZARE E GLI FORNISCO IL COMANDO DI SHIFT.
                    -- Ora posso shiftare sia a sinistra, sia a destra, i due casi in ogni caso sono tra loro simmetrici.
                    -- Shift a destra.
                    if(RIGHT_SHIFT='1') then
                    
                        -- Ad esempio si supponga di volere: x(0)  x(1) x(2) x(3) allora i primi tre sarebbero 0 e 'ultimo sarebbe x(0)
                        -- Quindi dovrei come prima cosa mettere x(3) =x(0) e poi i primi tre ad 1
                        -- 0 0 0 X(0)
                        -- Analogamente se shiftassi di 2 avrei: 0 0 X(0) X(1)     
                        if( to_integer(unsigned(Y))>4) then -- stiamo codificando la selezione su 2^(m+1) bits, se sforiamo 4 allora mettiamo tutto a 0
                            h:=std_logic_vector(to_unsigned(0,N));
                        else
                            -- Nell'esempio precedente X(3)=X(1) ed X(2)=X(1) la formula e' X(Y to N-1) = X(0 to N-1-Y) ossia nell'esempio precedente X( 2 to 3)= X(0 to 1)         
                            h(to_integer(unsigned(Y)) to N-1) :=h(0 to N-1-to_integer(unsigned(Y)));
                            -- Rispettando l'esempio precedente allora X(0 to 1) =0 ossia X(0 to Y-1)=0
                            h(0 to to_integer(unsigned(Y))-1  ) :=std_logic_vector(to_unsigned(0,to_integer(unsigned(Y))));
                        end if;    
                        
                    --Shift a sinistra e' il complementare.
                    else     
                        
                        if( to_integer(unsigned(Y))>4) then -- stiamo codificando la selezione su 2^(m+1) bits, se sforiamo 4 allora mettiamo tutto a 0
                            h:=std_logic_vector(to_unsigned(0,N));
                        else
                            h(0 to N-1-to_integer(unsigned(Y))):= h(to_integer(unsigned(Y)) to N-1) ;
                            -- Questo secondo punto indica la posizione giusta da cui iniziare a mettere zeri ossia N-1-(Y-1).    
                            h( (N-1)-(to_integer(unsigned(Y))-1) to N-1):=std_logic_vector(to_unsigned(0,to_integer(unsigned(Y))));
                        end if;  -- controllo dimensione shift.
                        
                end if;-- controllo right shift
            end if; -- controllo mem enable   
        end if; -- controllo rst    
        PARALLEL_OUT<=h;      
     end if; --controllo ck
    end process s_r;
    
end Behavioral;
