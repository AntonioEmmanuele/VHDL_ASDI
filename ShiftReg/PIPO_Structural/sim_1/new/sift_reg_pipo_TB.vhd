library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity shift_reg_pipo_tb is
end;

architecture bench of shift_reg_pipo_tb is

  component shift_reg_pipo
      generic(
          N_bits:integer:=4;
          M_shift:integer:=2
          );
        port(
          RST: IN std_logic;
          CLK: IN std_logic;
          RIGHT_SHIFT: IN std_logic;
          Y: IN std_logic_vector(0 to M_shift-1);
          X: IN std_logic_vector(0 to N_bits-1);
          PARALLEL_OUT: OUT std_logic_vector(0 to N_bits-1);
          MUX_VALUES: OUT std_logic_vector(0 to N_bits-1)
        );
  end component;
  constant M_shift:integer:=2;
  constant N_bits:integer:=4;
  signal RST: std_logic:='1';
  signal CLK: std_logic;
  signal RIGHT_SHIFT: std_logic:='0';
  signal Y: std_logic_vector(0 to M_shift-1);
  signal X: std_logic_vector(0 to N_bits-1);
  signal PARALLEL_OUT: std_logic_vector(0 to N_bits-1) ;
  signal MUX_VALUES: std_logic_vector(0 to N_bits-1) ;
  constant clock_period: time := 50 ns;
    

begin

  
  uut: shift_reg_pipo generic map ( N_bits            =>N_bits ,
                                    M_shift           =>M_shift  )
                         port map ( RST          => RST,
                                    CLK          => CLK,
                                    RIGHT_SHIFT  => RIGHT_SHIFT,
                                    Y            => Y,
                                    X            => X,
                                    PARALLEL_OUT => PARALLEL_OUT,
                                    MUX_VALUES=>MUX_VALUES );
   -- Genero un clock periodico.
   CLK_process :process
   begin
		CLK <= '0';
		wait for clock_period/2;
		CLK <= '1';
		wait for clock_period/2;
   end process;
 
 
  stimulus: process
    variable not_rev: std_logic_vector(0 to 3);
    variable rev: std_logic_vector(3 downto 0);
    begin

    wait for  clock_period+clock_period/2 ; -- a 25 ns out=0 dopo a 75 il dato diventa F.
            assert PARALLEL_OUT="0000" -- Per i primi 25 ns sara' undefined poi assume il valore di 0
            report " Errore nel reset"
            severity failure;
            RST<='0';   -- Tolgo il reset  
            Y<="00";    -- "00" significa modalita' di memorizzazione    
            X<="1101";
            
    -- TEST 1 BIT SHIFT  DESTRA.
    wait for clock_period+2ns ; 
        assert PARALLEL_OUT="1101" 
        report " Errore nel prendere il valore"
        severity failure;
        RIGHT_SHIFT<='1';   --Destra
        Y<="01";
    
    -- TEST 2 BIT SHIFT  DESTRA.
    wait for clock_period+100ns ; 
        assert PARALLEL_OUT="0001" 
        report " Errore nello shiftare a destra il valore"
        severity failure;
        RIGHT_SHIFT<='1';   --Destra
        Y<="01";
    wait;
    rev:="1011";
    not_rev(3):=rev(3);
    not_rev(2):=rev(2); 
    not_rev(1):=rev(1);
    not_rev(0):=rev(0);    
    assert not_rev="1101"
    severity failure;
    wait;
  end process;



end;
  