-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity System_tb is
end;

architecture bench of System_tb is

  component System
    Port (
      ck,rst: in std_logic;
      data_in: in std_logic_vector(0 to 7);
      send:   in std_logic;
      ready_to_send: out std_logic;
      data_out: out std_logic_vector(0 to 7);
      data_ready: out std_logic;
      data_read:  in std_logic
     );
  end component;

  signal ck: std_logic;
  signal rst: std_logic:='1';
  signal data_in: std_logic_vector(0 to 7);
  signal send: std_logic;
  signal ready_to_send: std_logic;
  signal data_out: std_logic_vector(0 to 7);
  signal data_ready: std_logic;
  signal data_read: std_logic ;
  constant ck_period:time:=10ns;
 
begin
    
  uut: System port map ( ck            => ck,
                         rst           => rst,
                         data_in       => data_in,
                         send          => send,
                         ready_to_send => ready_to_send,
                         data_out      => data_out,
                         data_ready    => data_ready,
                         data_read     => data_read );

  stimulus: process
  begin
  
    data_in<="11110001";
    wait for ck_period;
    rst<='0';
    wait for ck_period;
    --wait until ready_to_send='1';
  --  wait for ck_period;
    send<='1';
    wait until data_ready='1';
    assert data_out ="11110001"
    severity failure;
    data_read<='1';
    wait until data_ready='0';
    data_read<='0';
    send<='0';
    -- Put test bench stimulus code here
    data_in<="01010101";
    wait for 2*ck_period;
    --wait until ready_to_send='1';
    send<='1';
    wait until data_ready='1';
    assert data_out ="01010101"
    severity failure;
    data_read<='1';
    wait until data_ready='0';
    data_read<='0';
    send<='0';
    wait;
  end process;
  clocking :process
  begin
    ck<='1';
    wait for ck_period/2;
    ck<='0';
    wait for ck_period/2;
  end process;
end;