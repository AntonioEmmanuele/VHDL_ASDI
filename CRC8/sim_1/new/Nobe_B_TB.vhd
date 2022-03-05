library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Node_B_tb is
end;

architecture bench of Node_B_tb is

  component Node_B
      generic (
        CLK_FREQUENCY : integer := 100000000;
          BAUD_RATE     : integer := 9600;
          CENTERING     : integer := 16
      );
      port (
          clk, rst, rxd        : in std_logic;
          data_out             : out std_logic_vector (15 downto 0);
          crc_ok               : out std_logic;
          new_data             : out std_logic:='0';
          oe, pe, fe, rda      : out std_logic
      );
  end component;

  signal clk, rst, rxd: std_logic;
  signal data_out: std_logic_vector (15 downto 0);
  signal crc_ok: std_logic;
  signal new_data: std_logic:='0';
  signal oe, pe, fe, rda: std_logic ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  -- Insert values for generic parameters !!
  uut: Node_B generic map ( CLK_FREQUENCY => 100000000,
                            BAUD_RATE     => 9600,
                            CENTERING     => 16 )
                 port map ( clk           => clk,
                            rst           => rst,
                            rxd           => rxd,
                            data_out      => data_out,
                            crc_ok        => crc_ok,
                            new_data      => new_data,
                            oe            => oe,
                            pe            => pe,
                            fe            => fe,
                            rda           => rda );

  stimulus: process
  begin


    wait;
  end process;

  clocking: process
  begin
    clk <= '1';
    wait for clock_period;
    clk <= '0'; 
    wait for clock_period;
    wait;
  end process;

end;