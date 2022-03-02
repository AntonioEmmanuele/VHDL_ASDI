library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity cla_adder_tb is
end;

architecture bench of cla_adder_tb is

  component cla_adder
      port (
          X : in std_logic_vector (4 downto 0);
          Y : in std_logic_vector (4 downto 0);
          Cin : in std_logic;
          Cout : out std_logic; 
          S : out std_logic_vector (4 downto 0)
      );
  end component;

  signal X: std_logic_vector (4 downto 0);
  signal Y: std_logic_vector (4 downto 0);
  signal Cin: std_logic;
  signal Cout: std_logic;
  signal S: std_logic_vector (4 downto 0) ;

begin

  uut: cla_adder port map ( X    => X,
                            Y    => Y,
                            Cin  => Cin,
                            Cout => Cout,
                            S    => S );

  stimulus: process
  begin
  
    Cin <= '0';
    X <= "00001";
    Y <= "00010";
    
    wait for 10ns;
    
    assert S="00011" AND Cout = '0'
    severity failure;
    
    Cin <= '0';
    X <= "01101";
    Y <= "00010";
    
    wait for 10ns;
    
    assert S="01111" AND Cout = '0'
    severity failure;
    
    Cin <= '0';
    X <= "01101";
    Y <= "01100";

    wait for 10ns;
    
    assert S="11001" AND Cout = '0'
    severity failure;
    
    Cin <= '1';
    X <= "00001";
    Y <= "00011" XOR "11111";
    
    wait for 10ns;
    
    assert S="11110" AND Cout = '0'
    severity failure;
     Cin <= '0';
    X <= "01101";
    Y <= "01100";

    wait for 10ns;
    
    assert S="11001" AND Cout = '0'
    severity failure;
    
    Cin <= '0';
    X <= "11111";
    Y <= "00001" ;
    
    wait for 10ns;
    
    assert S="00000" AND Cout = '1'
    severity failure;
    wait;
  end process;


end;
