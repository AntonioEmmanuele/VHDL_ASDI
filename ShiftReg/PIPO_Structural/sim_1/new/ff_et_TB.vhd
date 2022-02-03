----------------------------------------------------------------------------------
-- Nome Esercizio: Registro a scorrimento Structural.
-- Numero Esercizio:  4.
-- Autori: Antonio Emmanuele, Giuseppe De Rosa.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity ff_et_tb is
end;

architecture bench of ff_et_tb is

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

  signal CK: std_logic;
  signal RST: std_logic:='1';
  signal D: std_logic:='1';
  signal Q: std_logic ;

  constant clock_period: time := 50 ns;

begin

    uut: ff_et 
        generic map ( RISING => '1'  )
        port map (          CK     => CK,
                            RST    => RST,
                            D      => D,
                            Q      => Q 
                 );

    
    -- Genero un clock periodico.
    CLK_process :process
    begin
		CK <= '0';
		wait for clock_period/2;
		CK <= '1';
		wait for clock_period/2;
    end process;
    
    stimulus: process
        begin
            wait for clock_period+clock_period/2;
                assert Q='0'
                report "Errore nel reset"
                severity failure;
                RST<='0';
            wait for clock_period;
                assert Q='1'
                report "Errore nel dato campionato "
                severity failure;
            wait for 10 ns;
                D<='0';
            wait for 10 ns;
                assert Q='1'
                report " Deve cambiare solo sul fronte di salita "
                severity failure;
            wait for clock_period-10ns;
                assert Q='0'
                report "Errore nel dato campionato "
                severity failure;
    
            wait;
    end process;
end;