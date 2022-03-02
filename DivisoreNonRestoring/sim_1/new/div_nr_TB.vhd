library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity div_nr_tb is
end;

architecture bench of div_nr_tb is

  component div_nr
     Port (
      dividend:       in  std_logic_vector(0 to 3);
      divisor:        in  std_logic_vector(0 to 3);
      enable:         in  std_logic;
      data_taken:     in  std_logic;
      result_ready:   out std_logic;
      quozient:       out std_logic_vector(0 to 3);
      remainder:      out std_logic_vector(0 to 3);
      clk,rst:        in  std_logic
     );
  end component;

  signal dividend: std_logic_vector(0 to 3);
  signal divisor: std_logic_vector(0 to 3);
  signal enable: std_logic := '0';
  signal result_ready: std_logic;
  signal data_taken:   std_logic:='0';
  signal quozient: std_logic_vector(0 to 3);
  signal remainder: std_logic_vector(0 to 3);
  signal clk,rst: std_logic ;
  constant ck_period:time:=10 ns;
begin

  uut: div_nr port map ( dividend     => dividend,
                         divisor      => divisor,
                         enable       => enable,
                         result_ready => result_ready,
                         data_taken   => data_taken,
                         quozient     => quozient,
                         remainder    => remainder,
                         clk          => clk,
                         rst          => rst );

  stimulus: process
  variable result:integer;
  variable remain:integer;
  begin
  
    -- Primo test
    dividend <="1101";
    divisor <="0010";
    enable<='1';
    wait until result_ready='1';
    -- Quoziente 6 e resto 1
    assert quozient = "0110" 
    severity failure;
    assert remainder = "0001" 
    severity failure;
    enable<='0';
    data_taken<='1';
    dividend<="1100";
    wait for ck_period;
    for i in 1 to 15 loop
        divisor<= std_logic_vector(to_unsigned(i,4));
        result:=to_integer(unsigned(dividend))/i;
        remain:=to_integer(unsigned(dividend)) mod i;
        enable<='1';
        data_taken<='0';
        wait until result_ready='1';
        assert quozient = std_logic_vector(to_unsigned(result,4)) 
        severity failure;
        assert remainder = std_logic_vector(to_unsigned(remain,4))
        severity failure;
        enable<='0';
        data_taken<='1';
        wait for ck_period;
    end loop;
    wait ;

  end process;

  clocking: process
    begin
    clk<='0';
    wait for ck_period/2;
    clk<='1';
    wait for ck_period/2;
    end process;

end;