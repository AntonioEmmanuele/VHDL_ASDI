library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity generic_mux_tb is
end;

architecture bench of generic_mux_tb is
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
    --  Valori 2:1
    constant N_0:integer:=2;
    constant M_0:integer:=1;
    signal input_0: std_logic_vector(0 to N_0-1);
    signal sel_0: std_logic_vector(0 to M_0-1);
    signal out_in_0: std_logic ;
    --  Valori 4:1
    constant N_1:integer:=4;
    constant M_1:integer:=2;
    signal input_1: std_logic_vector(0 to N_1-1);
    signal sel_1: std_logic_vector(0 to M_1-1);
    signal out_in_1: std_logic ;


begin

  uut1: generic_mux generic map (   N      => N_0,
                                    M      =>  M_0)
                      port map (    input  => input_0,
                                    sel    => sel_0,
                                    out_in => out_in_0 );
  uut2: generic_mux generic map (   N      => N_1,
                                    M      =>  M_1)
                      port map (    input  => input_1,
                                    sel    => sel_1,
                                    out_in => out_in_1 );


  stimulus: process
  begin
    -- Test 2:1
    wait for 10 ns;
        input_0<="10";
        sel_0<="0";
    wait for 10 ns;
        assert out_in_0='1'
        report "Errore nell'uscita"
        severity failure;
        sel_0<="1";
    wait for 10 ns;
        assert out_in_0='0'
        report "Errore nell'uscita"
        severity failure;
        input_0<="01";
    wait for 10 ns;
        assert out_in_0='1'
        report "Errore nell'uscita"
        severity failure;
        sel_0<="0";
    wait for 10 ns;
        assert out_in_0='0'
        report "Errore nell'uscita"
        severity failure;
        
    -- Test 4:1
    wait for 10 ns;
        input_1<="1010";
        sel_1<="00";
    wait for 10 ns;
        assert out_in_1='1'
        report "Errore nell'uscita"
        severity failure;
        sel_1<="01";
    wait for 10 ns;
        assert out_in_1='0'
        report "Errore nell'uscita"
        severity failure;
        sel_1<="10";
    wait for 10 ns;
        assert out_in_1='1'
        report "Errore nell'uscita"
        severity failure;
        sel_1<="11";
    wait for 10 ns;
        assert out_in_1='0'
        report "Errore nell'uscita"
        severity failure;

    wait;
  end process;


end;
  
