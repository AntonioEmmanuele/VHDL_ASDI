library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Reveiver_tb is
end;

architecture bench of Reveiver_tb is

  component Receiver
      generic(
          Num_Packets:Integer:=8;
          Packet_Bits: Integer:=1
      );
      port(
          ck,rst:   in std_logic;
          in_ready: in std_logic;
          in_received: out std_logic;
          data_in: in std_logic_vector(0 to Packet_Bits-1);
          data_out: out std_logic_vector( 0 to Num_Packets*Packet_Bits-1);
          data_ready: out std_logic; -- Il data_out ha valore, e' possibile prenderlo.
          data_taken:in std_logic    -- Segnale in input che ci dice che il dato e' stato preso
      );  
  end component;
  constant Num_Packets:integer:=4;
  constant Packet_Bits:integer:=1;
  constant ck_period: time := 10 ns;
  signal ck: std_logic;
  signal rst :std_logic:='1';
  signal in_ready: std_logic:='0';
  signal in_received: std_logic;
  signal data_in: std_logic_vector(0 to Packet_Bits-1);
  signal data_out: std_logic_vector( 0 to Num_Packets*Packet_Bits-1) ;
  signal to_snd: std_logic_vector( 0 to Num_Packets*Packet_Bits-1):="1010";
  signal data_ready: std_logic;
  signal data_taken: std_logic;
begin


  uut: Receiver generic map ( Num_Packets => Num_Packets,
                              Packet_Bits => Packet_Bits )
                   port map ( ck          => ck,
                              rst         => rst,
                              in_ready    => in_ready,
                              in_received => in_received,
                              data_in     => data_in,
                              data_out    => data_out ,
                              data_ready    => data_ready ,
                              data_taken    => data_taken );

    stimulus: process
    
    begin
        wait for ck_period;
        -- Incominciamo
        rst<='0';
        wait for ck_period;
        for i in 0 to 3 loop
            data_in<=to_snd(i*Packet_Bits to i*Packet_Bits+Packet_Bits-1);
            in_ready<='1';
            while in_received='0'loop -- finche' non ho una conferma di lettura allora non posso fare nulla
                wait for ck_period;
             end loop;
             wait for ck_period;
             in_ready<='0';
             while in_received='1'loop -- aspetto che riabbassi in received
                wait for ck_period;
             end loop;
        end loop;
        wait for ck_period;
        if(data_ready='1') then
            data_taken<='1';
        end if;
        wait for ck_period;
        if(data_ready='0') then
            data_taken<='0';
        end if;

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
  
