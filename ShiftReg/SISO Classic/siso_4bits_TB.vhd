library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity siso_4bits_tb is
end;

architecture bench of siso_4bits_tb is

  component siso_4bits
  port (
      CLK: in std_logic;
      RST: in std_logic;
      sig_in: in std_logic;
      sig_out: out std_logic
      );
  end component;

  signal CLK: std_logic;
  signal RST: std_logic:='1';
  signal sig_in: std_logic;
  signal sig_out: std_logic ;
  constant clock_period : time:=50 ns;
begin
  
  uut: siso_4bits port map ( CLK     => CLK,
                             RST     => RST,
                             sig_in  => sig_in,
                             sig_out => sig_out );
    

     -- Genero un clock periodico.
   CLK_process :process
   begin
		CLK <= '0';
		wait for clock_period/2;
		CLK <= '1';
		wait for clock_period/2;
   end process;
  stimulus: process
  begin
    wait for clock_period+ clock_period/2;
    --assert sig_out='0'
    --severity failure;
    RST<='0';
    sig_in<='1';
    wait for 20 ns;
    sig_in<='0';   
    
    wait;
  end process;


end;