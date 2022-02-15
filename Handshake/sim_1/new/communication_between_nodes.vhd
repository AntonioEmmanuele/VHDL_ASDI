----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.02.2022 17:41:00
-- Design Name: 
-- Module Name: communication_between_nodes - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity communication_between_nodes is

end communication_between_nodes;

architecture Behavioral of communication_between_nodes is
constant N:integer:=4;
constant M:integer:=8;
constant Packet_Bits:integer:=1;
constant Num_Packets:integer:=8;
constant ck_period:time:=20 ns ;

signal clk:std_logic;
signal rst:std_logic:='1';
signal in_ready: std_logic;
signal in_received:std_logic;
signal data_out: std_logic_vector(0 to Packet_Bits-1);

component Node_A is
    -- Riceviamo 4 stringhe da 8 bit
    generic(
        N: integer := 4;
        M: integer := 8;
        Num_Packets:Integer:=8;     --  Numero di pacchetti che formano un messaggio 
        Packet_Bits: Integer:=1     --  Numero di bits in un pacchetto
    );
    port(
        clk,rst:   in std_logic; -- Clock e reset 
        in_ready: out std_logic; -- Segnale di ready dato dal trasmettitore
        in_received: in std_logic;  -- Conferma di avvenuta lettura
        data_out: out std_logic_vector(0 to Packet_Bits-1) -- dati in ingresso messi dal trasmettitore
    );  
end component;

component Node_B is
    -- Riceviamo 4 stringhe da 8 bit
    generic(
        N: integer := 4;    -- numero di Pacchetti
        M: integer := 8;    -- Lunghezza di un numero
        Num_Packets:Integer:=8;     --  Numero di pacchetti che formano un messaggio 
        Packet_Bits: Integer:=1     --  Numero di bits in un pacchetto
    );
    port(
        clk,rst:   in std_logic; -- Clock e reset 
        in_ready: in std_logic; -- Segnale di ready dato dal trasmettitore
        in_received: out std_logic;  -- Conferma di avvenuta lettura
        data_in: in std_logic_vector(0 to Packet_Bits-1) -- dati in ingresso messi dal trasmettitore
    );  
end component;
begin

transmitter: Node_A
    generic map (
        N => N,
        M => M,
        Num_Packets => Num_Packets,
        Packet_Bits => Packet_Bits
    )
    port map (
        clk => clk,
        rst => rst, 
        in_ready => in_ready,
        in_received => in_received, 
        data_out => data_out
    );
receiver: Node_B
    generic map (
        N => N,
        M => M,
        Num_Packets => Num_Packets,
        Packet_Bits => Packet_Bits
    )
    port map (
        clk => clk,
        rst => rst, 
        in_ready => in_ready,
        in_received => in_received, 
        data_in => data_out
    );
 stimulus: process
 begin
   wait for ck_period;
    rst<='0';
    
 end process;
CLK_process :process
    begin
        clk <= '0';
        wait for ck_period/2;
        clk <= '1';
        wait for ck_period/2;
    end process;

end Behavioral;
