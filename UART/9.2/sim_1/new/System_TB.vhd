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
          clk, rst : in std_logic;
          oe, pe, fe, rda      : out std_logic
      );
  end component;

constant CLK_FREQUENCY : integer := 100000000;
constant BAUD_RATE     : integer := 9600;
constant CENTERING     : integer := 16;
constant clk_period    : time    := 10ns;
signal write: std_logic := '0';
signal clk, rst: std_logic;
signal oe, pe, fe, rda: std_logic ;

begin

  -- Insert values for generic parameters !!
  uut: System generic map ( CLK_FREQUENCY => CLK_FREQUENCY,
                            BAUD_RATE     => BAUD_RATE,
                            CENTERING     => CENTERING)
                 port map ( 
                            clk           => clk,
                            rst           => rst,
                            oe            => oe,
                            pe            => pe,
                            fe            => fe,
                            rda           => rda );

    stimulus: process
    begin
    
    rst <= '1';
     
    wait for clk_period;
    
    rst <= '0';
    
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