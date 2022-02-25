library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity System_tb is
end;

architecture bench of System_tb is

  component System
  port(
      ck,rst: in  std_logic;
      read: in std_logic;
      data_out:out std_logic_vector( 0 to 2)
      );
  end component;

  signal clk:std_logic;
  signal rst: std_logic:='1';
  signal read: std_logic;
  signal data_out: std_logic_vector( 0 to 2) ;
  -- Clock period definitions
  constant clk_period : time := 10 ns;

begin

  uut: System port map ( ck       => clk,
                         rst      => rst,
                         read     => read,
                         data_out => data_out );
  

  stimulus: process
  begin

	wait for clk_period;
	rst <= '0';
	wait for clk_period;
	for i in 0 to 15 loop
		read <= '1';
		wait for clk_period;
		read <= '0';
		wait for 3*clk_period;
	end loop;	



    wait;
  end process;

   CLK_process :process
   begin
		clk <= '0';
		wait for CLK_period/2;
		clk <= '1';
		wait for CLK_period/2;
   end process;

end;