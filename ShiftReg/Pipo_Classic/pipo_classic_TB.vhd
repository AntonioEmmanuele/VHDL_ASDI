-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity pipo_classic_tb is
end;

architecture bench of pipo_classic_tb is

  component pipo_classic
  port(
      CLK: in std_logic;
      RST: in std_logic;
      shift: in std_logic;
      Par_in: in std_logic_vector(0 to 3);
      Par_out:out std_logic_vector(0 to 3)
      );
  end component;

  signal CLK: std_logic;
  signal RST: std_logic:='1';
  signal shift: std_logic;
  signal Par_in: std_logic_vector(0 to 3);
  signal Par_out: std_logic_vector(0 to 3) ;
  constant clock_period : time:=50 ns;
begin

  uut: pipo_classic port map ( CLK     => CLK,
                               RST     => RST,
                               shift   => shift,
                               Par_in  => Par_in,
                               Par_out => Par_out );
    
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
            assert Par_out="0000" -- Per i primi 25 ns sara' undefined poi assume il valore di 0
            report " Errore nel reset"
            severity failure;
            RST<='0';   -- Tolgo il reset  
            shift<='0';   
            Par_in<="1101";
            
    -- TEST 1 BIT SHIFT  DESTRA.
    wait for clock_period ; 
        assert Par_out="1101" 
        report " Errore nel prendere il valore"
        severity warning;
        shift<='1';
    wait for clock_period ; 
        assert Par_out="0101" 
        report " Errore nel prendere il valore"
        severity warning;
    wait for clock_period ; 
        assert Par_out="0010" 
        report " Errore nel prendere il valore"
        severity warning;
     wait for clock_period ; 
        assert Par_out="0001" 
        report " Errore nel prendere il valore"
        severity warning;
     wait for clock_period ; 
        assert Par_out="0000" 
        report " Errore nel prendere il valore"
        severity warning;     
        
        

    wait;
  end process;


end;