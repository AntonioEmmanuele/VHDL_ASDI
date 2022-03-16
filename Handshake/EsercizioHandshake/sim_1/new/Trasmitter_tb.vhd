library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Trasmitter_tb is
end;

architecture bench of Trasmitter_tb is

  component Transmitter
      generic(
          Num_Packets:Integer:=8;
          Packet_Bits: Integer:=1
      );
      port(
          ck,rst:   in std_logic;
          send:     in std_logic;
          send_ok:  out std_logic;
          in_ready: out std_logic;
          in_received: in std_logic;
          data_buff: in std_logic_vector(0 to Num_Packets*Packet_Bits-1);
          data_out: out std_logic_vector(0 to Packet_Bits-1);
          data_ready: out std_logic -- Enable logico del contatore del nodo A
      );
  end component;
  constant Num_Packets:integer:=4;
  constant Packet_Bits:integer:=1;
  constant ck_period: time := 10 ns;
  signal ck: std_logic;  
  signal rst: std_logic:='1';
  signal send: std_logic;
  signal send_ok: std_logic;
  signal ready_to_send: std_logic;
  signal in_ready: std_logic;
  signal in_received: std_logic:='0';
  signal data_buff: std_logic_vector(0 to Num_Packets*Packet_Bits-1);
  signal data_out: std_logic_vector(0 to Packet_Bits-1) ;
  signal received:std_logic_vector(0 to Num_Packets*Packet_Bits-1):=(others=>'0');
begin

  -- Insert values for generic parameters !!
  uut: Transmitter generic map ( Num_Packets => Num_Packets,
                                 Packet_Bits => Packet_Bits)
                     port map ( ck          => ck,
                                rst         => rst,
                                send        => send,
                                send_ok     => send_ok,
                                in_ready    => in_ready,
                                in_received => in_received,
                                data_buff   => data_buff,
                                data_out    => data_out,
                                data_ready  => ready_to_send );

    stimulus: process
    begin
    
    wait for ck_period;
    rst<='0';
    send<='1';
    data_buff<="1010";
    wait for ck_period;
     if(send_ok='1') then
       send<='0';
    end if;
    for i in 0 to Num_Packets-1 loop
        while in_ready='0' loop
            wait for ck_period;
        end loop;
        received(i*Packet_Bits to i*Packet_Bits+Packet_Bits-1)<=data_out;
        in_received<='1';
        wait for ck_period;
        while in_ready='1' loop
            wait for ck_period;
        end loop;
        in_received<='0';
    end loop;
    wait; 
    end process;

    CLK_process :process
    begin
        ck <= '0';
        wait for ck_period/2;
        ck <= '1';
        wait for ck_period/2;
    end process;
end;