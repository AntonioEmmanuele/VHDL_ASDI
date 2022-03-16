library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity System is
  Port (
    ck,rst: in std_logic;
    data_in: in std_logic_vector(0 to 7);
    send:   in std_logic;
    ready_to_send: out std_logic;
    data_out: out std_logic_vector(0 to 7);
    data_ready: out std_logic;
    data_read:  in std_logic
   );
end System;

architecture Structural of System is
component Receiver is
    generic( 
        Num_Packets:Integer:= 8;    
        Packet_Bits: Integer:= 1     
    );
    port(
        ck,rst:   in std_logic;  
        in_ready: in std_logic; 
        in_received: out std_logic; 
        in_ack : out std_logic;
        data_out: out std_logic_vector(0 to Num_Packets*Packet_Bits-1);
        data_in: in std_logic_vector(0 to Packet_Bits-1);
        data_ready: out std_logic;
        data_read:  in std_logic
    ); 
end component;

component Transmitter is
    generic(
        Num_Packets:Integer:= 8;  
        Packet_Bits: Integer:= 1     
    );
    port(
        ck,rst:   in std_logic;  
        send:     in std_logic; 
        in_ready: out std_logic;
        in_received: in std_logic; 
        in_ack : in std_logic;
        data_buff: in std_logic_vector(0 to Num_Packets*Packet_Bits-1);
        data_out: out std_logic_vector(0 to Packet_Bits-1);
        ready_to_send: out std_logic 
    );
end component;
signal in_ready, in_received,in_ack:std_logic;
signal data_out_in :std_logic_vector(0 to 1-1);
begin
    rcv: Receiver generic map (
        Num_Packets=>8,  
        Packet_Bits=>1    
    )
    port map(
      ck=>ck,
      rst=>rst,
      in_ready=>in_ready,
      in_ack=>in_ack,
      in_received=>in_received,
      data_out=>data_out,
      data_ready=>data_ready,
      data_read=> data_read,
      data_in=> data_out_in
    );
    
    tsmt: Transmitter generic map (
        Num_Packets=>8,  
        Packet_Bits=>1    
    )
    port map(
      ck=>ck,
      rst=>rst,
      in_ready=>in_ready,
      in_ack=>in_ack,
      in_received=>in_received,
      data_buff=>data_in,
      data_out=>data_out_in,
      ready_to_send=>ready_to_send,
      send=>send
      );
    
end Structural;
