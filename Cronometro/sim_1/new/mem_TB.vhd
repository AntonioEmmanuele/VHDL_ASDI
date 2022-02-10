
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity ROM_tb is
end;

architecture bench of ROM_tb is

  component ROM
  generic(
      N: integer :=4 ;
      M: integer := 17;
      CK_Period:time :=10ns
  );
  port(
          input:in std_logic_vector( 0 to M-1);
          enable:in std_logic;
          rst: in std_logic;
          ck: in std_logic;
          mem:in std_logic_vector( 0 to N-1 );
          sel: in std_logic_vector(0 to N-1);
          output: out std_logic_vector(0 to M-1)
      );
  end component;
  constant N:integer:=4;
  constant M:integer:=17;
  signal input: std_logic_vector( 0 to M-1);
  signal enable: std_logic:='1';
  signal rst: std_logic:='1';
  signal ck: std_logic;
  signal mem: std_logic_vector( 0 to N-1 );
  signal sel: std_logic_vector(0 to N-1);
  signal output: std_logic_vector(0 to M-1) ;

  constant clock_period: time := 10 ns;
  TYPE matrix IS ARRAY ( 0 to N-1) OF std_logic_vector(0 to M-1);
  signal to_memorize:matrix:=(std_logic_vector(to_unsigned(10,M)),
                              std_logic_vector(to_unsigned(12,M)),
                              std_logic_vector(to_unsigned(128,M)),
                              std_logic_vector(to_unsigned(512,M)));
begin
  
  -- Insert values for generic parameters !!
  uut: ROM generic map ( N         => N,
                         M         => M,
                         CK_Period => clock_period )
              port map ( input     => input,
                         enable    => enable,
                         rst       => rst,
                         ck        => ck,
                         mem       => mem,
                         sel       => sel,
                         output    => output );

  stimulus: process
  begin
    wait for clock_period;  
    rst<='0';
    wait for clock_period+clock_period/2;
    for i in  0 to N-1 loop     
        mem<=std_logic_vector(to_unsigned(i,N));
        input<=to_memorize(i);
        wait for clock_period; -- prima lo faccio cambiare e poi cambio cio' che voglio selezionare .
        sel<=std_logic_vector(to_unsigned(i,N));   
        wait for clock_period;
    end loop;
    wait;
  end process;


    CLK_process :process
    begin
        ck <= '0';
        wait for clock_period/2;
        ck <= '1';
        wait for clock_period/2;
    end process;


end;
  
