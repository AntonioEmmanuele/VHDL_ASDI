----------------------------------------------------------------------------------
-- Nome Esercizio: Registro a scorrimento Structural.
-- Numero Esercizio:  4.
-- Autori: Antonio Emmanuele, Giuseppe De Rosa.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uno shift register si dice pipo se carica i valori in parallelo e li caccia fuori in parallelo.
-- Scriviamo uno shift register da 4 bit in caricamento parallelo  ed uscita parallela.
-- In questo registro si suppone, qualora si voglia shiftare, ossia ci sia shift enable
-- che e' possibile shiftare in un colpo di clock di piu' posizioni e che il numero di posizioni massimo di cui e' possibile
-- shiftare, a destra o a sinistra, sia di massimo N bits dove N e' il numero di bits dell'input.
-- 1*TCK in scrittura poiche' carica tutti i bit in parallelo.
-- 1*TCK in lettura poiche' li legge tutti in parallelo
-- 1*TCK per shiftare.
-- NB:  In questa versione non ci sono segnali che controllano lo shift e la memorizzazione, la modalita' di funzionamento (memorizzazione shift) e' implicitamente decisa dal valore di Y.
--      Se si ha un registro di 4 bits ed Y="00" allora dobbiamo shiftare di 0 bits, ergo siamo in modalita' di MEMORIZZAZIONE.
--      Si e' presa questa scelta per ridurre la componentistica nella rete di controllo ed il numero di pin di input.
entity shift_reg_pipo is
    generic(
        N_bits:integer:=4;    --      N e' il numero di bits in ingresso, quindi questo registro a scorrimento carica in parallelo 4 
        M_shift:integer:=2    --      M e' il numero di bits che compongono il segnale di shift tale che 2^M=N.
                              --      In questa maniera e' possibile shiftare di un numero di bits compreso tra  [0..2^M-1].
                              --      Sarebbbe possibile anche aumentare il numero di valori di shift, ossia ad esempio fare shiftare un registro di 4 bits anche 4,5,6... posizioni.
                              --      Cio' pero' comporterebbe l'uso di multiplexer ad un maggior numero di ingressi (molti dei quali inutilizzati)      
        );
      port(
        RST: IN std_logic;                                       --      segnale di reset.
        CLK: IN std_logic;                                       --      segnale di clock
        RIGHT_SHIFT: IN std_logic;                               --      Questo segnale vale 1 se vogliamo shiftare a destra >>, se vale 0 allora dobbiamo shiftare a sinistra.
        Y: IN std_logic_vector(0 to M_shift-1);                  --      Questo segnale fornisce il numero di bits da shiftare scelto dato in input dall'utente.
        X: IN std_logic_vector(0 to N_bits-1);                   --      Questo e' l'input fornito dall'utente.
        PARALLEL_OUT: OUT std_logic_vector(0 to N_bits-1);        --      Questo e' l'output fornito dal registro. 
        MUX_VALUES: OUT std_logic_vector(0 to N_bits-1)

      );
end shift_reg_pipo;

architecture Structural of shift_reg_pipo is
    --  Questa architettura e' composta principalmente da flip flop e da mux.
    --  All'ingresso di ogni mux vi e' un mux 2:1 che stabilisce se si vuole shiftare a destra o a sinistra
    --  Nei due ingressi invece vi sono due mux che tramite una formula parametrica gestiscono le connessioni in maniera tale che
    --  In base all'input dell'utente (Y) si shifti di quel numero preciso di bit
    
    -- registro.
    component ff_et
      generic(
          RISING :std_logic:='1'
      );
      port(
          CK:     IN std_logic;
          RST:    IN std_logic;
          D:      IN std_logic;
          Q:      OUT std_logic
      );
    end component;
    --mux
    component generic_mux
      generic(
          N:integer:=2;
          M:integer:=1
      );
      port(
          input:      IN std_logic_vector(0 to N-1);
          sel:        IN std_logic_vector(0 to M-1);
          out_in:     OUT std_logic
      );
    end component;
    
    signal right_shift_mux_out:std_logic_vector( 0 to N_bits-1 );    --  Segnale usato per prendere le N uscite dei mux per lo shift a destra.
    signal h:std_logic_vector( 0 to N_bits-1):="0000";                                                                   
                                                                        
    --signal left_shift_mux_out:std_logic_vector(0 to N_bits-1);  -- Segnale usato per prendere le N uscite dei mux a sinistra
    function vector_reverser_utility ( input: in std_logic_vector ; start_pos:in integer ;end_pos: in integer) -- In vhdl non e' possibile indicizzare un vettore  0 to x come x downto 0
    return std_logic_vector is
        variable result: std_logic_vector(end_pos- start_pos downto 0); -- se voglio ad esempio invertire una slice da 3 a 5 mi dichiaro un appoggio che va da 5-3-1 a 0.
    begin
        for j in 0 to end_pos-start_pos loop -- Nell'esempio precedente abbiamo ad esempio, result(0)=input(5),result(1)=input(5-1),result(2)=input(5-2)
            result(j) := input(end_pos-j);
        end loop;
    return result;
    end; 
    
begin
   -- reverse_helper:process(CLK,right_shift_mux_out)
   -- begin
    --if(rising_edge(CLK)) then
    --    for i in 0 downto N_bits-1 loop
    --        reversed_right_shift_mux_out(i)<=right_shift_mux_out(N_bits-1-i);   
    --    end loop;
    --end if;
    --end process reverse_helper;
    
    -- Incominciamo i collegamenti.
 
    --  Come prima cosa bisogna collegare i mux per gli shift.
    --  Dovendo decidere gli ingressi per N_Bits registri per lo shift a destra ed essendo lo shift a sinistra considerato un altro caso allora
    --  abbiamo bisogno di 2*N_Bits mux da N_Bits ingressi ed M_shift bits per effettuare la selezione.
    
    -- Iniziamo con quelli per lo shift a destra.
    right_shift_muxs: for i in 0 to N_bits-1 generate
      
      -- Facciamo il caso di 4 registri
      --                Reg0        Reg1        Reg2        Reg3
      -- 0shift         X(0)        X(1)        X(2)        X(3)   
      -- 1shift         0           Reg0Out     Reg1Out     Reg2Out    
      -- 2shift         0           0           Reg0Out     Reg1Out
      -- 3shift         0           0           0           Reg0Out
      -- Traendone una equazione generale allora:
      --    input(0)=X(i), ossia il primo e' sempre il dato
      --    input(1 to i)= RegOut(0 to i-1)
      --    input(i+1 to N_bits-1)=0.
      --  Reg0: input(0)=X(0), input(1 to 0) ossia nessuno,input(1 to 3)=(0,0,0)(dimensione=4-1-0), quindi gli diamo 0
      --  Reg1: input(0)=X(1)  input (1 to 1)=reg1out   input(2 to 3)=(0,0) (dimensione 4-1-1=2)
      --  Reg2: input(0)=X(2)  input(1 to 2)=(reg1out,reg0out) input(3,3)=(0)(dimensione 4-2-1=1)
      --  Reg3: input(0)=X(2)  input(1 to 3)=(reg2out,reg1out,reg0out) input(4,3)=(0)non succede nulla
      
      m:generic_mux generic map(
            N=>N_bits,
            M=>M_shift
        )
       port map(
            input(0)=>X(i),
            input( 1 to i)=>right_shift_mux_out(0 to i-1),
            input(i+1 to N_bits-1)=>h(0 to N_bits-i-2),
            sel=>Y,
            out_in=>right_shift_mux_out(N_bits-1-i) --Sono capovolti
        );
    end generate;
   
    --Generiamo i registri
    --right_shift_mux_out<=X;
    registers:for i in 0 to N_bits-1 generate
      reg:ff_et 
        generic map ( RISING => '1'  )                        -- Funzionano tutti sul fronte di salita.
        port map (          CK     => CLK,                     -- Clock e reset vanno sempre presi cosi
                            RST    => RST,
                            D      => right_shift_mux_out(N_bits-i-1),
                            Q      => PARALLEL_OUT(i)         -- L'iesimo registro fornisce l'iesima uscita parallela.
                 );
    end generate;
    MUX_VALUES<=right_shift_mux_out;
end Structural;
