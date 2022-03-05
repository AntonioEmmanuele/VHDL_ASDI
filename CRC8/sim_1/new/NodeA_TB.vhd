library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Node_A_tb is
end;

architecture bench of Node_A_tb is

  component Node_A
      generic (
          CLK_FREQUENCY : integer := 100000000;
          BAUD_RATE     : integer := 9600;
          CENTERING     : integer := 16
      );
      port (
          input : in std_logic_vector (0 to 7);
          write : in std_logic;
          clk, rst : in std_logic;
          txd : out std_logic;
          data_trasmitted: out std_logic
      );
  end component;
  -- 0xA4
  signal input: std_logic_vector (0 to 7):="10100100";
  signal write: std_logic;
  signal clk:std_logic;
  signal rst: std_logic:='0';
  signal txd: std_logic ;
   signal data_trasmitted:std_logic ;
  constant clock_period: time := 10 ns;

begin

  uut: Node_A generic map ( CLK_FREQUENCY => 100000000,
                            BAUD_RATE     => 9600,
                            CENTERING     => 16 )
                 port map ( input         => input,
                            write         => write,
                            clk           => clk,
                            rst           => rst,
                            data_trasmitted=> data_trasmitted,
                            txd           => txd );

  stimulus: process
  begin
    -- trasmette prima A4 e poi 75
    write<='1';
    wait until data_trasmitted='1';
    write<='0';

    wait;
  end process;

  clocking: process
  begin
    clk<='0';
    wait for clock_period/2;
    clk<='1';
    wait for clock_period/2;
  end process;

end;