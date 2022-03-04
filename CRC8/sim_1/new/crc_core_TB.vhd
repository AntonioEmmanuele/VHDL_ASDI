library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity crc_core_tb is
end;

architecture bench of crc_core_tb is

  component crc_core
      port(
          clk,rst:    in std_logic;
          data_in :   in std_logic;
          new_input    :   in std_logic;
          result  :   out std_logic_vector(7 downto 0);
          result_ready: out std_logic
      );
  end component;

  signal clk: std_logic;
  signal rst: std_logic:='0';
  signal data_in: std_logic;
  signal new_input: std_logic;
  signal result: std_logic_vector(7 downto 0);
  signal result_ready: std_logic ;
  constant clock_period: time := 10 ns;
  -- 0xA475
  signal data_to_send:std_logic_vector(15 downto 0):="1010010001110101";
begin

  uut: crc_core port map ( clk          => clk,
                           rst          => rst,
                           data_in      => data_in,
                           new_input    => new_input,
                           result       => result,
                           result_ready => result_ready );

  stimulus: process
  begin
    for  i in 15 downto 8 loop 
       data_in<=data_to_send(i);
       new_input<='1';
       wait for clock_period;
    end loop;
    new_input<='0';
    wait until result_ready='1';
    
    -- CRC = 0x75
    assert result = "01110101"
    severity failure;
    
    rst <= '1';   
    wait for 2*clock_period;
    rst <= '0';
    wait for 2*clock_period;
    
    for  i in 15 downto 0 loop 
        data_in<=data_to_send(i);
        new_input<='1';
        wait for clock_period;
    end loop;
    new_input<='0';
    wait until result_ready='1';
    
    -- Viene zero poiché dato + CRC 
    -- fanno 0 
    assert result = "00000000"
    severity failure;
    
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
