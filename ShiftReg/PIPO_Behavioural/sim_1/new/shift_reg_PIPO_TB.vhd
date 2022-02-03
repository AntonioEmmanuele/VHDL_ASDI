library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity shift_reg_pipo_tb is
end;

architecture bench of shift_reg_pipo_tb is

  component shift_reg_pipo
      generic(
          N:positive:=4;
          M:positive:=3
          );
        port(
          RST: IN std_logic;
          CLK: IN std_logic;
          MEM_ENABLE: IN std_logic;
          SHIFT_ENABLE: IN std_logic;
          RIGHT_SHIFT: IN std_logic;
          Y: IN std_logic_vector(0 to M-1);
          X: IN std_logic_vector(0 to N-1);
          PARALLEL_OUT: OUT std_logic_vector(0 to N-1)
        );
  end component;

  signal RST: std_logic:='1';
  signal CLK: std_logic;
  signal MEM_ENABLE: std_logic:='0';
  signal SHIFT_ENABLE: std_logic:='0';
  signal RIGHT_SHIFT: std_logic:='0';
  signal Y: std_logic_vector(0 to 2);
  signal X: std_logic_vector(0 to 3);
  signal PARALLEL_OUT: std_logic_vector(0 to 3) ;

  constant clock_period: time := 30 ns;
    

begin

  
  uut: shift_reg_pipo generic map ( N            =>4 ,
                                    M            =>3  )
                         port map ( RST          => RST,
                                    CLK          => CLK,
                                    MEM_ENABLE   => MEM_ENABLE,
                                    SHIFT_ENABLE => SHIFT_ENABLE,
                                    RIGHT_SHIFT  => RIGHT_SHIFT,
                                    Y            => Y,
                                    X            => X,
                                    PARALLEL_OUT => PARALLEL_OUT );
   -- Genero un clock periodico.
   CLK_process :process
   begin
		CLK <= '0';
		wait for clock_period/2;
		CLK <= '1';
		wait for clock_period/2;
   end process;
 
 
  stimulus: process
    begin
    wait for  clock_period+clock_period/2 ; -- a 25 ns out=0 dopo a 75 il dato diventa F.
            assert PARALLEL_OUT="0000" -- Per i primi 25 ns sara' undefined poi assume il valore di 0
            report " Errore nel reset"
            severity failure;
            RST<='0'; -- Tolgo il reset
            MEM_ENABLE<='1'; -- Abilito la memorizzazione.
            SHIFT_ENABLE<='0';
            X<="1011";
            
    -- TEST 1 BIT SHIFT SINISTRA E DESTRA.
    wait for clock_period ; 
        assert PARALLEL_OUT="1011" 
        report " Errore nel prendere il valore"
        severity failure;
        MEM_ENABLE<='0';
        SHIFT_ENABLE <='1';
        RIGHT_SHIFT<='1';   --Destra
        Y<=std_logic_vector(to_unsigned(1,3));
    wait for clock_period ; 
        assert PARALLEL_OUT="0101" 
        report " Errore nello shift di destra"
        severity failure;
        MEM_ENABLE<='0';
        RIGHT_SHIFT<='0';   --Sinistra
        --Y<=std_logic_vector(to_unsigned(1,4));
    wait for clock_period ; 
        assert PARALLEL_OUT="1010" 
        report " Errore nello shift di sinistra"
        severity failure;
        RST<='1';
        
    -- TEST SHIFT DI 2 bits.
    wait for clock_period;
        assert PARALLEL_OUT="0000" 
        report " Errore nel reset"
        severity failure;
        RST<='0'; -- Tolgo il reset
        MEM_ENABLE<='1'; -- Abilito la memorizzazione.
        SHIFT_ENABLE<='0';
        X<="1100";
    wait for clock_period ; 
        assert PARALLEL_OUT="1100" 
        report " Errore nel prendere il valore"
        severity failure;
        MEM_ENABLE<='0';
        SHIFT_ENABLE <='1';
        RIGHT_SHIFT<='1';   --Destra
        Y<=std_logic_vector(to_unsigned(2,3));
    wait for clock_period ; 
        assert PARALLEL_OUT="0011" 
        report " Errore nello shift di destra"
        severity failure;
        MEM_ENABLE<='0';
        RIGHT_SHIFT<='0';   --Sinistra
    wait for clock_period ; 
        assert PARALLEL_OUT="1100" 
        report " Errore nello shift di sinistra"
        severity failure;
        RST<='1';

    -- TEST SHIFT DI 3 BITS.
    wait for clock_period;
        assert PARALLEL_OUT="0000" 
        report " Errore nel reset"
        severity failure;
        RST<='0'; -- Tolgo il reset
        MEM_ENABLE<='1'; -- Abilito la memorizzazione.
        SHIFT_ENABLE<='0';
        X<="1110";
    wait for clock_period ; 
        assert PARALLEL_OUT="1110" 
        report " Errore nel prendere il valore"
        severity failure;
        MEM_ENABLE<='0';
        SHIFT_ENABLE <='1';
        RIGHT_SHIFT<='1';   --Destra
        Y<=std_logic_vector(to_unsigned(3,3));
    wait for clock_period ; 
        assert PARALLEL_OUT="0001" 
        report " Errore nello shift di destra"
        severity failure;
        MEM_ENABLE<='0';
        RIGHT_SHIFT<='0';   --Sinistra
    wait for clock_period ; 
        assert PARALLEL_OUT="1000" 
        report " Errore nello shift di sinistra"
        severity failure;
        RST<='1';
    -- TEST SHIFT 3 BITS 2
    wait for clock_period;
        assert PARALLEL_OUT="0000" 
        report " Errore nel reset"
        severity failure;
        RST<='0'; -- Tolgo il reset
        MEM_ENABLE<='1'; -- Abilito la memorizzazione.
        SHIFT_ENABLE<='0';
        X<="0111";
    wait for clock_period ; 
        assert PARALLEL_OUT="0111" 
        report " Errore nel prendere il valore"
        severity failure;
        MEM_ENABLE<='0';
        SHIFT_ENABLE <='1';
        RIGHT_SHIFT<='0';   --Sinistra
        Y<=std_logic_vector(to_unsigned(3,3));
    wait for clock_period ; 
        assert PARALLEL_OUT="1000" 
        report " Errore nello shift di sinistra"
        severity failure;
        MEM_ENABLE<='0';
        RIGHT_SHIFT<='1';   --Destra
        Y<=std_logic_vector(to_unsigned(2,3)); -- LO VOGLIO FARE DI 2
    wait for clock_period ; 
        assert PARALLEL_OUT="0010" 
        report " Errore nello shift di destra" 
        severity failure;
        RST<='1';    
  
  -- TEST CASI LIMITE
  
  -- SHIFT A SINISTRA E DESTRA DI 0
    wait for clock_period;
        assert PARALLEL_OUT="0000" 
        report " Errore nel reset"
        severity failure;
        RST<='0'; -- Tolgo il reset
        MEM_ENABLE<='1'; -- Abilito la memorizzazione.
        SHIFT_ENABLE<='0';
        X<="1011";
    wait for clock_period ; 
        assert PARALLEL_OUT="1011" 
        report " Errore nel prendere il valore"
        severity failure;
        MEM_ENABLE<='0';
        SHIFT_ENABLE <='1';
        RIGHT_SHIFT<='1';   --Destra
        Y<=std_logic_vector(to_unsigned(0,3));
    wait for clock_period ; 
        assert PARALLEL_OUT="1011" 
        report " Errore nello shift di destra per 0"
        severity failure;
        MEM_ENABLE<='0';
        RIGHT_SHIFT<='0';   --Sinistra
        Y<=std_logic_vector(to_unsigned(0,3)); 
    wait for clock_period ; 
        assert PARALLEL_OUT="1011" 
        report " Errore nello shift di sinistra per 0" 
        severity failure;
        RST<='1';
    
    -- TEST SHIFT 4 BITS

    -- DESTRA
    wait for clock_period;
        assert PARALLEL_OUT="0000" 
        report " Errore nel reset"
        severity failure;
        RST<='0'; -- Tolgo il reset
        MEM_ENABLE<='1'; -- Abilito la memorizzazione.
        SHIFT_ENABLE<='0';
        X<="1011";
    wait for clock_period ; 
        assert PARALLEL_OUT="1011" 
        report " Errore nel prendere il valore"
        severity failure;
        MEM_ENABLE<='0';
        SHIFT_ENABLE <='1';
        RIGHT_SHIFT<='1';   --Destra
        Y<=std_logic_vector(to_unsigned(4,3));
    wait for clock_period ; 
        assert PARALLEL_OUT="0000" 
        report " Errore nello shift di destra per 4"
        severity failure;
        RST<='1';
    
    --SINISTRA
    wait for clock_period;
        assert PARALLEL_OUT="0000" 
        report " Errore nel reset"
        severity failure;
        RST<='0'; -- Tolgo il reset
        MEM_ENABLE<='1'; -- Abilito la memorizzazione.
        SHIFT_ENABLE<='0';
        X<="1011";
    wait for clock_period ; 
        assert PARALLEL_OUT="1011" 
        report " Errore nel prendere il valore"
        severity failure;
        MEM_ENABLE<='0';
        SHIFT_ENABLE <='1';
        RIGHT_SHIFT<='0';   --SINISTRA
        Y<=std_logic_vector(to_unsigned(4,3));
    wait for clock_period ; 
        assert PARALLEL_OUT="0000" 
        report " Errore nello shift di sinistra per 4"
        severity failure;
        RST<='1'; 
       
    -- VALORE DI SHIFT MAGGIORE DI 4 (COMPORTAMENTALE)
   
    --SINISTRA
    wait for clock_period;
        assert PARALLEL_OUT="0000" 
        report " Errore nel reset"
        severity failure;
        RST<='0'; -- Tolgo il reset
        MEM_ENABLE<='1'; -- Abilito la memorizzazione.
        SHIFT_ENABLE<='0';
        X<="1011";
    wait for clock_period ; 
        assert PARALLEL_OUT="1011" 
        report " Errore nel prendere il valore"
        severity failure;
        MEM_ENABLE<='0';
        SHIFT_ENABLE <='1';
        RIGHT_SHIFT<='0';   --SINISTRA
        Y<=std_logic_vector(to_unsigned(6,3));
    wait for clock_period ; 
        assert PARALLEL_OUT="0000" 
        report " Errore nello shift di sinistra per 4"
        severity failure;
        RST<='1'; 


    -- DESTRA
    wait for clock_period;
        assert PARALLEL_OUT="0000" 
        report " Errore nel reset"
        severity failure;
        RST<='0'; -- Tolgo il reset
        MEM_ENABLE<='1'; -- Abilito la memorizzazione.
        SHIFT_ENABLE<='0';
        X<="1011";
    wait for clock_period ; 
        assert PARALLEL_OUT="1011" 
        report " Errore nel prendere il valore"
        severity failure;
        MEM_ENABLE<='0';
        SHIFT_ENABLE <='1';
        RIGHT_SHIFT<='1';   --Destra
        Y<=std_logic_vector(to_unsigned(5,3));
    wait for clock_period ; 
        assert PARALLEL_OUT="0000" 
        report " Errore nello shift di destra per 4"
        severity failure;
        RST<='1';
    
    wait;
  end process;



end;
  