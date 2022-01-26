library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--  Andiamo adesso a comporre un mux_4_1 mediante una rappresentazione strutturale 
entity mux_4_1 is
    port(
        inputs: in STD_LOGIC_VECTOR(0 to 3);    -- 4 segnali di input,un vettore include tutti gli estremi, sia il sinistro sia il destro
        sel:    in STD_LOGIC_VECTOR(0 to 1);    -- 2 segnali di selezione
        y_out:    out STD_LOGIC                 -- Segnale in uscita
    );
end mux_4_1;

architecture Structural of mux_4_1 is
    --  Mi dichiaro il componente mux_2_1
    component mux_2_1
    port (
          a0: in STD_LOGIC;
          a1: in STD_LOGIC;
          s:  in STD_LOGIC;
          y:  out STD_LOGIC
    );
    end component;
    signal out_1: STD_LOGIC;    -- Output del primo mux
    signal out_2: STD_LOGIC;    -- Output del secondo mux    
begin
    --  Adesso vado a smistare i pin di input ai vari mux.
    --  Il primo si prende i primi due input ed il secondo gli ultimi due.
    --  Il secondo bit del segnale di selezione decide quale dei due input ogni mux deve prendere
    --  Gli output vengono smistati nei segnali intermedi.
    mux0: mux_2_1 port map(
        a0=> inputs(0),
        a1=> inputs(1),
        s=>sel(1),
        y=> out_1
    );
    mux1: mux_2_1 port map(
        a0=> inputs(2),
        a1=> inputs(3),
        s=>sel(1),
        y=> out_2
    );
    --Infine il terzo mux, tramite il secondo bit del segnale di selezione decide dove andare a prendere i valori.
    mux2: mux_2_1 port map(
        a0=> out_1,
        a1=> out_2,
        s=>sel(0),
        y=> y_out -- Infine l'uscita di questo mux coincide con l'uscita che il mux 4 1 deve avere 
    );
    --  Perche' il secondo bit del segnale di decisione?
    --  Dentro il mux e' come se uno avesse un decodificatore che caccia 4 pin che abilitano le porte tristate.
    --  Quindi se il mux e' 01 in uscita ho:  0100 perche' devo abilitare il secondo segnale.
    --  Quindi traducendo cosi' ad esempio quello che deve uscire e' il secondo input del primo dei due mux di input.
    --  S1 deve dunque pilotare l'input dei mux ed S0 quale dei due mux.
    -- Se si avesse ad esempio, come nell'ultimo test case : 10 allora cio' significa che stiamo abilitando il primo ingresso del secondo mux, 0010 dal decodificatore.
end Structural;
