library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity div_nr is
   Port (
    --  Dividendo su 5 bits
    dividend:       in  std_logic_vector(0 to 3);
    --  Divisore su 4 bits
    divisor:        in  std_logic_vector(0 to 3);
    --  dai il via al calcolo
    enable:         in  std_logic;
    --  Strobe di calcolo finito
    result_ready:   out std_logic;
    --  Conferma di aver preso il dato
    data_taken:     in std_logic;
    --  Quoziente il quoziente in genere lo si esprime come
    --  bit dividendo- bit divisore+1.
    --  Con il minimo divisore si ha massimo Q, ossia con bit pari ad 1.
    --  bit dividendo-1+1= bit dividendo.
    quozient:       out std_logic_vector(0 to 3);
    --  Resto puo' al piu' essere pari ad V-1, quindi viene espresso 
    --  su bit divisore.
    remainder:      out std_logic_vector(0 to 3);
    clk,rst:        in  std_logic
   );
end div_nr;

architecture Structural of div_nr is
--  i componenti di cui si ha bisogno sono shift registers, contatori
--  registro singolo ed infine parallel adder.

-- Registro a scorrimento
component n_shift_reg_pipo  is
generic (
    N_Bits:integer:=8;
    Shift_Bits:integer:=3
);
port(
    CLK: in std_logic;
    RST: in std_logic;
    shift: in std_logic_vector(0 to Shift_Bits-1)  ;
    right_shift:in std_logic;
    Par_in: in std_logic_vector(0 to N_Bits-1);
    Par_out:out std_logic_vector(0 to N_Bits-1);
    mem_enable: in std_logic
    );
end component ;
--  Nel sistema ci sono di fatto 3 registri: 
--      A
--      Q
--      D.
--  A ed Q possono essere accorpati in un unico registro a 8 bits.
--  Invece D, siccome contiene il divisore, potrebbe essere semplicemente 
--  implementato come un segnale che viene riempito dall'automa.
--  Cio' rappresenta una perdita di simmetria ma ci risparmia l'uso di molti 
--  segnali di controllo.

--  Valore del segnale di shift, ricorda che puoi shiftare al piu' di 7 posizioni.
signal aq_reg_shift: std_logic_vector(0 to 2);
--  Segnale di controllo della memorizzazione
signal aq_reg_mem: std_logic;
--  Devo shiftare sempre a sinistra
signal aq_reg_right_shift: std_logic:='0'; 
--  Uscita del registro
signal aq_reg_out:  std_logic_vector(0 to 8);
-- Input del registro
signal aq_reg_in : std_logic_vector (0 to 8);
--  Alias dei valori di uscita.
--  il resto sono i quattro bit piu' significativi
ALIAS remain : std_logic_vector(0 to 3) is aq_reg_out(1 to 4);
--  Il quoziente e' invece rappresentato dai 5 bits meno significativi
ALIAS quoz : std_logic_vector(0 to 3) is aq_reg_out(5 to 8);
-- Input X addizionatore
ALIAS A : std_logic_vector( 4 downto 0) is aq_reg_out(0 to 4);
component counter_mod_n is
    generic(
        -- Sarà pari a 4
        N           : integer :=16;  
        -- Sarà pari a 2                         
        Bit_number  : integer := 4;                       
        CLK_period  : time := 1000ms                               
    );
    port(
        ck:             IN std_logic;                             
        rst:            IN std_logic;                            
        enable:         IN std_logic;                              
        cnt_done:       OUT std_logic;                            
        count_value:    OUT std_logic_vector(0 to Bit_number-1)  
    );  
end component;

-- Count enable
signal cnt_en : std_logic := '0';
-- Count done
signal cnt_dn : std_logic := '0';
-- Count value
signal cnt_vl : std_logic_vector (0 to 1);
-- Reset
signal cnt_rst : std_logic := '0';

component cla_adder 
    port (
        X : in std_logic_vector (4 downto 0);
        Y : in std_logic_vector (4 downto 0);
        Cin : in std_logic;
        Cout : out std_logic; 
        S : out std_logic_vector (4 downto 0)
    );
end component;

-- Segnale che ci permette di fare il complemento a 2 in caso di sottrazione
signal complement : std_logic_vector (4 downto 0) := "00000";
-- CLA primo operando, uscente dal registro M
signal cla_y : std_logic_vector (4 downto 0);
-- CLA riporto, uscente dalla CU
signal cla_cin : std_logic := '0';
-- CLA riporto in uscita
signal cla_cout : std_logic;
-- CLA somma
signal cla_s : std_logic_vector (4 downto 0); 

-- Bit di negatività dell'ultima operazione
signal S : std_logic;

-- Appoggio divisore
signal M : std_logic_vector (0 to 4) := "00000"; 

-- Stati automa control unit
type control_unit_state is (Q0, Q1, Q2, Q3, Q4, Wait_0,Wait_0_Correction);
signal actual_state : control_unit_state := Q0;
signal stato_prossimo : control_unit_state;

begin

cla_y <= complement XOR M;

control_unit : process (actual_state, enable) 
    begin
        --if (rising_edge(clk)) then
            --if (rst = '1') then
                
            --elsif (rst = '0') then
        case actual_state is 
            when Q0 =>  
                result_ready <= '0';                
                if (enable = '0') then
                    stato_prossimo <= Q0;
                    M <= "00000";
                    -- Control signal shift reg
                    aq_reg_in <= (others => '0');
                    aq_reg_mem <= '0';
                    aq_reg_shift <= "000";
                    -- Non dobbiamo sottrarre
                    complement <= "00000";
                    cla_cin <= '0';
                    -- Counter control signal
                    cnt_en <= '0';
                    S <= '0';
                    cnt_rst <= '0';
                elsif (enable = '1') then
                    stato_prossimo <= Q1;
                    M <= '0'& divisor;
                    -- Control signal shift reg
                    aq_reg_in <= "00000" & dividend ;
                    aq_reg_mem <= '1';
                    aq_reg_shift <= "000";
                    -- Non dobbiamo sottrarre
                    complement <= "00000";
                    cla_cin <= '0';
                    -- Counter control signal
                    cnt_en <= '0';
                    S <= '0';
                    cnt_rst <= '1';
                end if;
            when Q1 => 
                --result_ready <= '0';
                stato_prossimo <= Q2;
                aq_reg_mem <= '0';
                aq_reg_shift <= "001";
                complement <= "00000";
                cla_cin <= '0';
                cnt_en <= '0';
                cnt_rst <= '0';
            when Q2 => 
                --result_ready <= '0';
                stato_prossimo <= Q3;
                aq_reg_mem <= '0';
                aq_reg_shift <= "000";
                cnt_rst <= '0';
                if (S = '0') then 
                    complement <= "11111";
                    cla_cin <= '1';
                elsif (S = '1') then
                    complement <= "00000";
                    cla_cin <= '0';
                end if;
            when Q3 => 
                --result_ready <= '0';
                stato_prossimo <= Q4;
                S <=  cla_s(4);
                aq_reg_mem <= '1';
                aq_reg_shift <= "000";
                --  A sara' pari all'uscita del sommatore.
                --  Q invece sara' lo stesso valore pero' come LSB 
                --  avra' il nuovo bit calcolato
                aq_reg_in <= cla_s & ((quoz and "1110") or ("000" & NOT cla_s(4))) ;
                cnt_en <= '1';
                cnt_rst <= '0';
            when Q4 => 
                --result_ready <= '0';
                cnt_en <= '0';
                cnt_rst <= '0';
                aq_reg_mem <= '0';
                aq_reg_shift <= "000";
                if (cnt_dn = '1') then
                    -- Passo di correzione
                    if (S = '1') then
                        complement <= "00000";
                        cla_cin <= '0';
                        stato_prossimo <= Wait_0_Correction;
                    elsif (S='0') then
                        stato_prossimo <= Wait_0;
                    end if;
                elsif (cnt_dn = '0') then
                    stato_prossimo <= Q1;
                end if;
            when Wait_0_Correction =>
                --result_ready <= '0';
                aq_reg_mem <= '1';
                aq_reg_shift <= "000";
                aq_reg_in <= cla_s & quoz;
                cnt_en <= '0';
                stato_prossimo<=Wait_0;
            when Wait_0 => 
                aq_reg_mem <= '0';
                aq_reg_shift <= "000";
                result_ready<='1';
                quozient <= quoz;
                remainder <= remain;
                cnt_rst<='0';
                if (enable='0' and data_taken='1') then 
                   stato_prossimo<=q0;
                end if;
        end case;
            --end if;
        --end if;
end process;

update : process (clk)
    begin
        if( CLK'event and CLK = '1' ) then
            if( RST = '1') then
               actual_state <= Q0;
            else
               actual_state <= stato_prossimo;
            end if;
       end if;
end process update;

shift_reg: n_shift_reg_pipo 
    generic map (
        -- A 5 bits, Q 4 bits
        -- si shifta sempre di 1 quindi non 
        -- si ha bisogno di tutti gli shift bits
        N_Bits => 9,
        Shift_Bits => 3
    )
port map (
    CLK => clk,
    RST => rst,
    shift => aq_reg_shift,
    right_shift => aq_reg_right_shift,
    Par_in => aq_reg_in,
    Par_out => aq_reg_out,
    mem_enable => aq_reg_mem
    );

counter: counter_mod_n 
    generic map (
        N => 4,                    
        Bit_number => 2,                   
        CLK_period => 10ns                        
    )
    port map(
        ck => clk,                         
        rst => cnt_rst,                        
        enable => cnt_en,                          
        cnt_done=> cnt_dn,                       
        count_value => cnt_vl
    );  
    
adder: cla_adder 
    port map (
        X => A,
        Y => cla_y,
        Cin => cla_cin,
        Cout => cla_cout,
        S => cla_s
    );
    
end Structural;