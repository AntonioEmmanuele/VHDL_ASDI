library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity shift_reg_pipo_tb is
end;

architecture bench of shift_reg_pipo_tb is

  component shift_reg_pipo
      generic(
          N:positive:=4;
          M:positive:=4
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
  signal Y: std_logic_vector(0 to 3);
  signal X: std_logic_vector(0 to 3);
  signal PARALLEL_OUT: std_logic_vector(0 to 3) ;

  constant clock_period: time := 50 ns;
    

begin

  
  uut: shift_reg_pipo generic map ( N            =>4 ,
                                    M            =>4  )
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
 
  --
  stimulus: process
-------------------
  begin   
    
       
    wait for  clock_period+clock_period/2 ; -- a 25 ns out=0 dopo a 75 il dato diventa F.
        assert PARALLEL_OUT="0000" -- Per i primi 25 ns sara' undefined poi assume il valore di 0
        report " Errore nel reset"
        severity failure;
        RST<='0'; -- Tolgo il reset
        MEM_ENABLE<='1'; -- Abilito la memorizzazione.
        SHIFT_ENABLE<='0';
        X<="1111";
    wait for clock_period ; 
        assert PARALLEL_OUT="1111" 
        report " Errore nel prendere il valore"
        severity failure;
        MEM_ENABLE<='0'; -- Disattivo la memorizzazione
        RIGHT_SHIFT<='1';--Shifto a destra
        Y<=std_logic_vector(to_unsigned(2,4));-- Shifto di un bit
        SHIFT_ENABLE<='1';-- Voglio shiftare 
    wait for clock_period ; 
        assert PARALLEL_OUT="0011" 
        report " Errore nello shift"
        severity failure;
        --Andiamo a shiftare di 2 posizioni
        SHIFT_ENABLE<='0';  -- Lo abbasso per evitare conflitti
        RIGHT_SHIFT<='0';   -- LO voglio a sinistra 
        Y<=std_logic_vector(to_unsigned(3,4));-- 3 posizioni, in modo che io abbia 1000
        SHIFT_ENABLE<='1';  -- Lo riabilito
    wait for clock_period;
        assert PARALLEL_OUT="1000" 
        report " Errore nello shift"
        severity failure;

  end process;



end;
  