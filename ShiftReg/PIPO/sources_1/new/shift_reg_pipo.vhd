----------------------------------------------------------------------------------
-- Company:  Esame Architettura Dei 
-- Engineer: 
-- 
-- Create Date: 02.02.2022 11:58:19
-- Design Name: 
-- Module Name: shift_reg_pipo - Behavioral
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
        N:positive:=4; -- N e' il numero di bits in ingresso, quindi questo registro a scorrimento carica in parallelo 4 
        M:positive:=4   -- M e' il numero di shift massimo che possiamo effettuare, abbiamo per l'appunto shift.
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
       -- signal h: std_logic_vector(N-1 downto 0) := std_logic_vector(to_unsigned(0,N)); 
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
                                 
                    -- Nell'esempio precedente X(3)=X(1) ed X(0)=X(1) la formula e' X(i)=X(i-Y) per i [Y, N-1]                
                    for i in to_integer(unsigned(Y)) to N-1 loop 
                        h(i):=h(i-to_integer(unsigned(Y)));
                    end loop;
                    -- X(0),X(1) =0 , X(i)=0 per i [0,Y-1]
                    for i in 0 to to_integer(unsigned(Y))-1  loop 
                        h(i):='0';
                    end loop;   
                --Shift a sinistra e' il complementare.
                else       
                      -- X(i)=X(Y+i) per i compreso tra 0 ed N-Y-1, ad esempio se si vuole shiftare di 2 1111 allora X(0)=X(2) ed X(1)=X(3)
                      for i in N-1-to_integer(unsigned(Y)) downto 0  loop 
                        h(i):=h(to_integer(unsigned(Y))+i);
                      end loop;                               
                      -- X(i) =0 per i [N-Y,N] , nell'esempio precedente questo si traduce come 1100
                      for i in  N-to_integer(unsigned(Y)) to N-1 loop 
                        h(i):='0';
                      end loop;                
                end if;-- controllo right shift
            end if; -- controllo mem enable   
        end if; -- controllo rst    
        PARALLEL_OUT<=h;      
     end if; --controllo ck
    end process s_r;
    
end Behavioral;