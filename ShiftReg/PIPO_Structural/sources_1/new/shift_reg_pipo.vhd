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
    shift: in std_logic_vector(0 to Shift_Bits-1)  ;    --      Questo segnale vale 1 se vogliamo shiftare a destra >>, se vale 0 allora dobbiamo shiftare a sinistra.
    right_shift:in std_logic;                           --      Questo segnale vale 1 se si vuole shiftare a destra >>, se vale 0 allora si vuole shiftare a sinistra.
    Par_in: in std_logic_vector(0 to N_Bits-1);         --      Parallel Input
    Par_out:out std_logic_vector(0 to N_Bits-1)         --      Parallel Output
    );
end shift_reg_pipo ;

architecture Structural of shift_reg_pipo  is
    --  Questa architettura e' composta principalmente da flip flop e da mux.
    --  All'ingresso di ogni registro vi e' un mux 2:1 che stabilisce se si vuole shiftare a destra o a sinistra
    --  Agli ingressi dei mux 2:1 invece vi sono due mux che tramite una formula parametrica gestiscono le connessioni in maniera tale che
    --  in base all'input dell'utente (Y) si shifti di quel numero preciso di bit.
    --  Esempio
    --  Se si realizza il componente per 4 bits allora si hanno 4 muxs 2:1 che regolano l'ingresso dei due mux.
    --  In ingresso ad ogni mux 2:1 vi sono due mux 4:1, uno per lo shift di destra, uno per quello di sinistra.
    signal right_mux_outs:std_logic_vector(0 to N_Bits-1):=std_logic_vector(to_unsigned(0,N_Bits)); -- Uscite dei mux che regolano lo shift a destra
    signal left_mux_outs:std_logic_vector(0 to N_Bits-1):=std_logic_vector(to_unsigned(0,N_Bits));  -- Uscite dei mux che regolano lo shift a sinistra
    signal reg_outs:std_logic_vector(0 to N_Bits-1):=std_logic_vector(to_unsigned(0,N_Bits));       -- Uscite dei flip flop
    signal reversed_outs:std_logic_vector(0 to N_Bits-1):=std_logic_vector(to_unsigned(0,N_Bits));  -- Uscite dei flip flop invertite, utili per cablare i mux per shift di destra
    signal reg_inputs:std_logic_vector(0 to N_Bits-1):=std_logic_vector(to_unsigned(0,N_Bits));     -- Ingressi da dare ai registri
    
    
    component generic_mux
        generic(
            N:integer:=N_Bits;
            M:integer:=Shift_Bits
        );
        port(
            input:      IN std_logic_vector(0 to N-1);
            sel:        IN std_logic_vector(0 to M-1);
            out_in:     OUT std_logic
          );
    end component;
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
      
begin
    -- Utilty che effettua il reverse delle uscite dei registri.
    reverser:process(reg_outs)
    begin
        for i in 0 to N_Bits-1 loop
            reversed_outs(i)<=reg_outs((N_Bits-1)-i);
        end loop;
    end process reverser;
    
    --  Come prima cosa bisogna collegare i mux per gli shift.
    --  Dovendo decidere gli ingressi per N_Bits registri per lo shift a destra ed essendo lo shift a sinistra considerato un altro caso allora
    --  abbiamo bisogno di 2*N_Bits mux da N_Bits ingressi ed M_shift bits per effettuare la selezione.
    
    -- Iniziamo con quelli per lo shift a destra.

    -- Facciamo il caso di 4 registri, SI ASSUMA X = Par_in
    -- Colonne rappresentano i registri(j) mentre le righe il numero di bits di shift(i).
    -- Il generico elemento della matrice rappresenta l'input del j-esimo registro(colonna). 
    --                Reg0        Reg1        Reg2        Reg3
    -- 0shift         X(0)        X(1)        X(2)        X(3)   
    -- 1shift         0           Reg0Out     Reg1Out     Reg2Out    
    -- 2shift         0           0           Reg0Out     Reg1Out
    -- 3shift         0           0           0           Reg0Out
    -- Traendone una equazione generale allora:
    --    input(0)=X(i), ossia il primo e' sempre il dato
    --    input(1 to i)= RegOut(i-1 downto 0)
    --    input(i+1 to N_bits-1)=0.
    --  Reg0: input(0)=X(0), input(1 to 0) ossia nessuno,input(1 to 3)=(0,0,0)(dimensione=4-1-0), quindi gli diamo 0
    --  Reg1: input(0)=X(1)  input (1 to 1)=reg1out   input(2 to 3)=(0,0) (dimensione 4-1-1=2)
    --  Reg2: input(0)=X(2)  input(1 to 2)=(reg1out,reg0out) input(3,3)=(0)(dimensione 4-2-1=1)
    --  Reg3: input(0)=X(2)  input(1 to 3)=(reg2out,reg1out,reg0out) input(4,3)=(0)non succede nulla
    --  Vedendo la seconda equazione e' facile intuire perche' si necessita del vettore capovolto dell'output dei registri.
    --  Cio' e' anche dovuto al fatto che il VHDL non consente di indicizzare in maniera inversa ( 0 to x non puo' essere poi indicizzato come x downto 0)
    
    -- Si inizia dal primo
    r_m_1:generic_mux generic map(
        N=>N_Bits,
            M=>Shift_Bits
    )
    port map(
        input(0)=>Par_in(0),
        input(1 to (N_Bits-1))=>std_logic_vector(to_unsigned(0,(N_Bits-1))),
        sel=>(shift),
        out_in=>right_mux_outs(0)
    );
    -- E poi gli altri.
    r_muxs : for i in 1 to N_Bits-1 generate
        r_m_gen:generic_mux generic map(
            N=>N_Bits,
            M=>Shift_Bits
        )
       port map(
            input(0)=>Par_in(i),
            input(1 to i) => reversed_outs((N_Bits-1)-i+1 to (N_Bits-1)), -- Collegati cosi' perche' il vettore e' capovolto
            input(i+1 to (N_Bits-1))=> std_logic_vector(to_unsigned(0,(N_Bits-1)-i)),
            sel=>(shift),
            out_in=>right_mux_outs(i)
        );
    end generate;

    -- Qualora si voglia un registro che shifta a sinistra basta " capovolgere ".
    -- Si assuma X=Par_in ed RegOut=reg_outs
    --                Reg0        Reg1        Reg2        Reg3
    -- 0shift         X(0)        X(1)        X(2)        X(3)   
    -- 1shift         Reg1Out     Reg2Out     Reg3Out      0    
    -- 2shift         Reg2Out     Reg3Out        0         0
    -- 3shift         Reg3Out        0           0         0
    -- Le equazioni sono:
    --    input(0)=X(i), ossia il primo e' sempre il dato
    --    input(1 to (N_Bits-1)-i)= RegOut(i+1 to 3)
    --    input((N_bits-1)-i+1 to N_bits-1)=0. (i volte 0)
    -- Per i=2 ad esempio :
    --  input(0)=X(2),input(1 to 1)=RegOut(3 to 3),input(3-2+1 to 3)=0, ossia l'input desiderato dalla matrice.

    -- Simmetrico al caso di destra, il primo assegnato regola l'ingresso del terzo registro.
    l_m_last:generic_mux generic map(
        N=>N_Bits,
        M=>Shift_Bits
    )
    port map(
        input(0)=>Par_in(0),
        input(1 to (N_Bits-1))=>std_logic_vector(to_unsigned(0,(N_Bits-1))),
        sel=>(shift),
        out_in=>left_mux_outs(N_Bits-1)
    );
    l_muxs : for i in 0 to (N_Bits-1)-1 generate
        l_m_gen:generic_mux generic map(
            N=>N_Bits,
            M=>Shift_Bits
        )
        port map(
            input(0)=>Par_in(i),
            input(1 to (N_Bits-1)-i) => reg_outs(i+1 to (N_Bits-1)),
            input((N_Bits-1)-i+1 to (N_Bits-1))=> std_logic_vector(to_unsigned(0,i)),
            sel=>(shift),
            out_in=>left_mux_outs(i)
        );
    end generate;
    
    --mux di selezione tipo di shift.
    reg_inputs_muxs: for i in 0 to N_Bits-1 generate
        shift_selection_muxs:generic_mux generic map(
            N=>2,
            M=>1
        )
       port map(
            input(1)=>right_mux_outs(i),    -- Se valgo 1 allora si shifta a destra
            input(0)=>left_mux_outs(i),     -- altrimenti si shifta a sinistra.
            sel(0)=>right_shift,
            out_in=>reg_inputs(i)
        );
    end generate;
    registers:for i in 0 to N_Bits-1 generate
      reg:ff_et 
        generic map ( RISING => '1'  )                          -- Funzionano tutti sul fronte di salita.
        port map (          CK     => CLK,                      -- Clock e reset vanno sempre presi cosi
                            RST    => RST,
                            D      => reg_inputs(i),            -- Se devo shiftare a sinistra allora prendo l'uscita dei mux che operano per lo shift a sinsitra, altrimenti prendi quelli per la destra 
                            Q      => reg_outs(i)               -- L'iesimo registro fornisce l'iesima uscita parallela.
                 );
    end generate;
    Par_out<=reg_outs; --   Prendo le uscite in parallelo
    
end Structural;
