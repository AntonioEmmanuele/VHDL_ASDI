library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Cronometro_tb is
end;

architecture bench of Cronometro_tb is

  component Cronometro
      generic (
                CLK_general_period  : time := 1000ms                               -- Periodo clock, supposto 1s 
            );
      port (
          clk, rst, set, enable           : in std_logic;
          input_value                     : in std_logic_vector (0 to 16);
          Y                               : out std_logic_vector (0 to 16)                                           
      );
  end component;

  signal clk, set, enable: std_logic;
  signal rst : std_logic := '1';
  signal input_value: std_logic_vector (0 to 16);
  signal Y: std_logic_vector (0 to 16) ;
  
ALIAS seconds_input : std_logic_vector (0 to 5) is input_value (0 to 5);
ALIAS minutes_input : std_logic_vector (0 to 5) is input_value (6 to 11);
ALIAS hours_input : std_logic_vector (0 to 4) is input_value (12 to 16);
  
  constant clk_period: time := 100 ns;
  signal seconds, minutes : std_logic_vector (0 to 5);
  signal hours : std_logic_vector (0 to 4); 

begin

  uut: Cronometro 
  generic map (
                CLK_general_period => clk_period
            )
  port map ( clk         => clk,
                             rst         => rst,
                             set         => set,
                             enable      => enable,
                             input_value => input_value,
                             Y           => Y );

    stimulus: process
      begin
      
        enable <= '1';

        wait for clk_period + clk_period/2;
        
        rst <= '0';
        
        set <= '1';
        seconds_input <= std_logic_vector(to_unsigned(40, 6));
        minutes_input <= std_logic_vector(to_unsigned(10, 6));
        hours_input <= std_logic_vector(to_unsigned(1, 5));
        wait for clk_period;
        
        set <= '0';

        wait;
      end process;
      
    seconds <= Y (0 to 5);
    minutes <= Y(6 to 11);
    hours <= Y (12 to 16);
      
    CLK_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

end;