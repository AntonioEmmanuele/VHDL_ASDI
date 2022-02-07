-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity counter_mod_n_tb is
end;

architecture bench of counter_mod_n_tb is

  component counter_mod_n
      generic(
          N:integer:=16;
          Bit_number : integer := 4
      );
      port(
          enable:         IN std_logic;
          load:           IN std_logic;
          input_value:    IN std_logic_vector(0 to 3);
          ck:             IN std_logic;
          rst:            IN std_logic;
          cnt_done:       OUT std_logic;
          count_value:    OUT std_logic_vector(0 to 3)
      );   
  end component;

  signal enable: std_logic := '1';
  signal load: std_logic;
  signal input_value: std_logic_vector(0 to 3);
  signal ck: std_logic;
  signal rst: std_logic := '1';
  signal cnt_done: std_logic;
  signal count_value: std_logic_vector(0 to 3);

  constant ck_period: time := 10 ns;

begin

  uut: counter_mod_n generic map ( N           => 16,
                                   Bit_number  => 4)
                        port map ( enable      => enable,
                                   load        => load,
                                   input_value => input_value,
                                   ck          => ck,
                                   rst         => rst,
                                   cnt_done    => cnt_done,
                                   count_value => count_value );

  stimulus: process
  begin


    wait for ck_period + ck_period/2;
    
    assert count_value = "0000"
    report "Errore"
    severity failure;
    
    rst <= '0';
    
    wait for 10ns;
    
    for i in 1 to 15 loop
        assert count_value = std_logic_vector (to_unsigned(i, count_value'length))
        report "Error"
        severity failure;
        
        wait for ck_period;
    end loop;
    
    assert count_value = "0000" and cnt_done = '1'
    report "Error count done"
    severity failure;
    
    wait for ck_period + ck_period/2;
    
    load <= '1';
    input_value <= "0011";
    
    wait for ck_period;
    
    load <= '0';
    
    wait for ck_period;
    
    for i in to_integer (unsigned(input_value))+1 to 15 loop
        assert count_value = std_logic_vector (to_unsigned(i, count_value'length))
        report "Error"
        severity failure;
        
        wait for ck_period;
    end loop;

    -- Put test bench stimulus code here

    wait;
  end process;

    CLK_process :process
    begin
        ck <= '0';
        wait for ck_period/2;
        ck <= '1';
        wait for ck_period/2;
    end process;

end;