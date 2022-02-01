-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity mux_4_1_tb is
end;

architecture bench of mux_4_1_tb is

  component mux_4_1
      port(
          inputs: in STD_LOGIC_VECTOR(0 to 3);
          sel:    in STD_LOGIC_VECTOR(0 to 1);
          y_out:    out STD_LOGIC
      );
  end component;

  signal inputs: STD_LOGIC_VECTOR(0 to 3);
  signal sel: STD_LOGIC_VECTOR(0 to 1);
  signal y_out: STD_LOGIC ;

begin

  uut: mux_4_1 port map ( inputs => inputs,
                          sel    => sel,
                          y_out  => y_out );

  stimulus: process
  begin
    wait for 10 ns;
        inputs <= "1000";
        sel <=  "00";
    wait for 10 ns;
        assert y_out='1' report " Error" severity failure; -- La failure blocca la simulazione quasi come ci fosse un breakpoint
        sel<="10";
    wait for 10 ns;
        assert y_out='0' report " Error" severity failure; -- La failure blocca la simulazione quasi come ci fosse un breakpoint
        inputs<="0001";
        sel<="11";
    wait for 10 ns;
        assert y_out='1' report " Error" severity failure; -- La failure blocca la simulazione quasi come ci fosse un breakpoint
        inputs<="0010";
        sel<="10";
      wait for 10 ns;
        assert y_out='1' report " Error" severity failure; -- La failure blocca la simulazione quasi come ci fosse un breakpoint
    wait;
  end process;


end;
  