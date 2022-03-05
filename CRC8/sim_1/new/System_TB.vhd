
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity System_tb is
end;

architecture bench of System_tb is

  component System
      generic (
          CLK_FREQUENCY : integer := 100000000;
  		BAUD_RATE     : integer := 9600;
  		CENTERING     : integer := 16
      );
      port (
          input : in std_logic_vector (0 to 7);
          write : in std_logic;
          data_trasmitted: out std_logic;
          clk, rst : in std_logic;
          data_out             : out std_logic_vector (15 downto 0);
          crc_ok               : out std_logic;
          new_data             : out std_logic:='0';
          oe, pe, fe, rda      : out std_logic
      );
  end component;

  signal input: std_logic_vector (0 to 7);
  signal write: std_logic;
  signal data_trasmitted: std_logic;
  signal clk:std_logic;
  signal rst: std_logic:='0';
  signal data_out: std_logic_vector (15 downto 0);
  signal crc_ok: std_logic;
  signal new_data: std_logic:='0';
  signal oe, pe, fe, rda: std_logic ;
  constant CLK_FREQUENCY : integer := 100000000;
  constant BAUD_RATE     : integer := 9600;
  constant CENTERING     : integer := 16;
  constant clk_period  : time    := 10 ns;
begin

  -- Insert values for generic parameters !!
  uut: System generic map ( CLK_FREQUENCY   => CLK_FREQUENCY,
                            BAUD_RATE       => BAUD_RATE,
                            CENTERING       => CENTERING )
                 port map ( input           => input,
                            write           => write,
                            data_trasmitted => data_trasmitted,
                            clk             => clk,
                            rst             => rst,
                            data_out        => data_out,
                            crc_ok          => crc_ok,
                            new_data        => new_data,
                            oe              => oe,
                            pe              => pe,
                            fe              => fe,
                            rda             => rda );


    stimulus: process
    begin
    
    input <= "10100100";
    wait for clk_period;
    write <= '1';
    
    wait;
    end process;
    
    CLK_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

end;