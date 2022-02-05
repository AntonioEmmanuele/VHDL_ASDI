library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity shift_reg_pipo_tb is
end;

architecture bench of shift_reg_pipo_tb is

  component shift_reg_pipo 
  generic (
    N_Bits:integer:=4;
    Shift_Bits:integer:=2
  );
  port(
      CLK: in std_logic;
      RST: in std_logic;
      shift: in std_logic_vector(0 to Shift_Bits-1);
      right_shift:in std_logic;
      Par_in: in std_logic_vector(0 to N_Bits-1);
      Par_out:out std_logic_vector(0 to N_Bits-1)
      );
  end component;

  signal CLK: std_logic;
  signal right_shift: std_logic:='0';
  signal RST: std_logic:='1';
  signal shift: std_logic_vector(0 to 1);
  signal Par_in: std_logic_vector(0 to 3):="1011";
  signal Par_out: std_logic_vector(0 to 3) ;
  constant clock_period : time:=25 ns;
  
begin

  uut: shift_reg_pipo generic map(N_Bits=>4,Shift_Bits=>2)
                    port map ( CLK     => CLK,
                               RST     => RST,
                               shift   => shift,
                               right_shift=> right_shift,
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
            shift<="00";   
--  TEST A SINISTRA          
--  TEST 1 BIT SHIFT  .
    wait for clock_period ; 
        assert Par_out="1011" 
        report " Errore nel prendere il valore"
        severity failure;
        shift<="01";
    wait for clock_period+clock_period/2 ; 
        assert Par_out="0110" 
        report " Errore nello shiftare  il valore di 1 a sinistra"
        severity failure;
    wait for clock_period ; 
        assert Par_out="1100" 
        report " Errore nello shiftare  il valore di 1 a sinistra"
        severity failure;
     wait for clock_period ; 
        assert Par_out="1000" 
        report " Errore nello shiftare  il valore di 1 a sinistra"
        severity warning;
     wait for clock_period ; 
        assert Par_out="0000" 
        report " Errore nello shiftare  il valore di 1 a sinstra"
        severity warning;     
        shift<="00";
        Par_in<="1111";
        
     -- Test shift di 2 bits
     wait for clock_period +clock_period/2; 
        assert Par_out="1111" 
        report  " Errore nel prendere il valore"
        severity failure;     
        shift<="10";
    wait for clock_period+clock_period/2;
        assert Par_out="1100" 
        report  " Errore nello shiftare  il valore di 2 a sinistra"
        severity failure;     
    wait for clock_period;
        assert Par_out="0000" 
        report  " Errore nello shiftare  il valore di 2 a sinistra"
        severity failure;   
        Par_in<="1101";  
        shift<="00"  ;  
    wait for clock_period +clock_period/2; 
        assert Par_out="1101" 
        report  " Errore nel prendere il valore"
        severity failure;       
        shift<="10";
     wait for clock_period+clock_period/2 ; 
        assert Par_out="0100" 
        report  " Errore nello shiftare  il valore di 2 a sinistra"
        severity failure;     
     wait for clock_period ; 
        assert Par_out="0000" 
        report  " Errore nello shiftare  il valore di 2 a sinistra"
        severity failure;     
        shift<="00";
        Par_in<="1111";
   -- Test shift 3 bits.
     wait for clock_period+clock_period/2 ; 
        assert Par_out="1111" 
        report  " Errore nel prendere il valore"
        severity failure;   
        shift<="11";                 
     wait for clock_period+clock_period/2 ; 
        assert Par_out="1000" 
        report  " Errore nello shiftare  il valore di 3 a sinitra"
        severity failure;          
     wait for clock_period+clock_period/2 ; 
        assert Par_out="0000" 
        report  " Errore nello shiftare  il valore di 3 a sinitra"
        severity failure;
        right_shift<='1';
        Par_in<="1101";
        shift<="00";            
    -- TEST A DESTRA        
    -- TEST 1 BIT SHIFT  
    wait for clock_period ; 
        assert Par_out="1101" 
        report " Errore nel prendere il valore"
        severity warning;
        shift<="01";
    wait for clock_period ; 
        assert Par_out="0101" 
        report " Errore nello shiftare  il valore di 1 a destra"
        severity warning;
    wait for clock_period ; 
        assert Par_out="0010" 
        report " Errore nello shiftare  il valore di 1 a destra"
        severity warning;
     wait for clock_period ; 
        assert Par_out="0001" 
        report " Errore nello shiftare  il valore di 1 a destra"
        severity warning;
     wait for clock_period ; 
        assert Par_out="0000" 
        report " Errore nello shiftare  il valore di 1 a destra"
        severity warning;     
        shift<="00";
        Par_in<="1111";
        
     -- Test shift di 2 bits
     wait for clock_period +clock_period/2; 
        assert Par_out="1111" 
        report  " Errore nel prendere il valore"
        severity failure;     
        shift<="10";
    wait for clock_period;
        assert Par_out="0011" 
        report  " Errore nello shiftare  il valore di 2 a destra"
        severity failure;     
    wait for clock_period;
        assert Par_out="0000" 
        report  " Errore nello shiftare  il valore di 2 a destra"
        severity failure;   
        Par_in<="1011";  
        shift<="00"  ;  
    wait for clock_period +clock_period/2; 
        assert Par_out="1011" 
        report  " Errore nel prendere il valore"
        severity failure;       
        shift<="10";
     wait for clock_period+clock_period/2 ; 
        assert Par_out="0010" 
        report  " Errore nello shiftare  il valore di 2 a destra"
        severity failure;     
     wait for clock_period ; 
        assert Par_out="0000" 
        report  " Errore nello shiftare  il valore di 2 a destra"
        severity failure;     
        shift<="00";
        Par_in<="1111";
   -- Test shift 3 bits.
     wait for clock_period+clock_period/2 ; 
        assert Par_out="1111" 
        report  " Errore nel prendere il valore"
        severity failure;   
        shift<="11";                 
     wait for clock_period+clock_period/2 ; 
        assert Par_out="0001" 
        report  " Errore nello shiftare  il valore di 3 a destra"
        severity failure;          
     wait for clock_period+clock_period/2 ; 
        assert Par_out="0000" 
        report  " Errore nello shiftare  il valore di 3 a destra"
        severity failure;
   wait;
  end process;


end;
