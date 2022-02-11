
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Memory_tb is
end;

architecture bench of Memory_tb is

  component Memory
  generic(
      N: integer :=4 ;
      N_BitNum: integer:=2;
      M: integer := 17
  );
  port(
          input:in std_logic_vector( 0 to M-1);
          enable:in std_logic;
          rst: in std_logic;
          ck: in std_logic;
          mem:in std_logic_vector( 0 to N_BitNum-1 );
          sel: in std_logic_vector(0 to N_BitNum-1);
          output: out std_logic_vector(0 to M-1)
      );
  end component;
  component counter_mod_n
    generic(
    N:integer:=4;
    Bit_number : integer := 2
    );
    port(
    enable:         IN std_logic;
    load:           IN std_logic;
    input_value:    IN std_logic_vector(0 to Bit_number-1);
    ck:             IN std_logic;
    rst:            IN std_logic;
    cnt_done:       OUT std_logic;
    count_value:    OUT std_logic_vector(0 to Bit_number-1)
    );   
   end component;
  -- Valori per la rom
  constant N:integer:=4;
  constant N_BitNum:integer:=2;
  constant M:integer:=17;
  signal input: std_logic_vector( 0 to M-1);
  signal enable: std_logic:='1';
  signal rst: std_logic:='1';
  signal ck: std_logic;
  signal mem: std_logic_vector( 0 to N_BitNum-1 );
  signal sel: std_logic_vector(0 to N_BitNum-1);
  signal output: std_logic_vector(0 to M-1) ;
  -- Valori per il contatore
  signal enable_counter:std_logic:='1';
  signal load_counter:std_logic:='0';   
  signal rst_counter:std_logic:='1';
  signal count_done: std_logic;
  signal count_value:std_logic_vector(0 to 1);
    signal input_value_counter:std_logic_vector(0 to 1);
  constant clock_period: time := 10 ns;

  TYPE matrix IS ARRAY ( 0 to N-1) OF std_logic_vector(0 to M-1);
  signal to_memorize:matrix:=(std_logic_vector(to_unsigned(10,M)),
                              std_logic_vector(to_unsigned(12,M)),
                              std_logic_vector(to_unsigned(128,M)),
                              std_logic_vector(to_unsigned(512,M)));
begin
  
  -- Insert values for generic parameters !!
  uut: Memory generic map ( N         => N,
                            M         => M,
                            N_BitNum  =>N_BitNum )
              port map ( input     => input,
                         enable    => enable,
                         rst       => rst,
                         ck        => ck,
                         mem       => mem,
                         sel       => sel,
                         output    => output );
  uut2: counter_mod_n generic map ( N           => N,
                                   Bit_number  => 2)
                        port map ( enable      => enable,
                                   load        => load_counter,
                                   input_value => input_value_counter,
                                   ck          => ck,
                                   rst         => rst_counter,
                                   cnt_done    => count_done,
                                   count_value => count_value );
  stimulus: process
  begin
    -- Test della singola rom
    wait for clock_period;  
    rst<='0';
    wait for clock_period+clock_period/2;
    for i in  0 to N-1 loop     
        mem<=std_logic_vector(to_unsigned(i,N_BitNum));
        input<=to_memorize(i);
        wait for clock_period; -- prima lo faccio cambiare e poi cambio cio' che voglio selezionare .
        sel<=std_logic_vector(to_unsigned(i,N_BitNum));   
        wait for clock_period;
    end loop;
    -- DECOMMENTARE LE RIGHE SUCCESSIVE QUALORA SI VOGLIA TESTARE IL COMPONENTE SENZA IL CONTATORE PER L'AGGIORNAMENTO
    --rst<='1';
    --wait for clock_period;
    --rst<='0';
    --rst_counter<='0';
    --wait;
    --wait for clock_period+clock_period/2;
        --for i in  0 to N-1 loop     
 --           mem<=count_value;
 --           input<=to_memorize(to_integer(unsigned(count_value)));
 --           wait for clock_period; -- prima lo faccio cambiare e poi cambio cio' che voglio selezionare .
 --           sel<=count_value;   
 --           wait for clock_period;
        --end loop; 

  end process;


    CLK_process :process
    begin
        ck <= '0';
        wait for clock_period/2;
        ck <= '1';
        wait for clock_period/2;
    end process;


end;
