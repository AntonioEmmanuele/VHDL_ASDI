----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2022 17:56:07
-- Design Name: 
-- Module Name: Nodo_A_TB - Behavioral
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

entity Nodo_A_TB is
--  Port ( );
end Nodo_A_TB;

architecture Behavioral of Nodo_A_TB is

component Nodo_A
    generic (
        N: integer := 4;
        M: integer := 8;
        Num_Packets:Integer:=8;     --  Numero di pacchetti che formano un messaggio 
        Packet_Bits: Integer:=1     --  Numero di bits in un pacchetto
        );
    port (
        clk, rst : in std_logic;
        in_ready: out std_logic;-- Dice al trasmettitore che puo' prendersi il dato
        in_received: in std_logic; -- trasmettitore mi dice che ha preso il dato.
        data_out : out std_logic_vector (0 to Packet_Bits-1)
        );
end component;

constant N:integer:=4;
constant M:integer:=8;
constant Num_Packets:integer:=8;
constant Packet_Bits:integer:=1;
constant ck_period: time := 10 ns;
signal ck: std_logic;  
signal rst: std_logic:='1';
signal in_ready: std_logic;
signal in_received: std_logic:='0';
signal data_out: std_logic_vector(0 to Packet_Bits-1);
signal received:std_logic_vector(0 to Num_Packets*Packet_Bits-1):=(others=>'0');

begin

uut: Nodo_A
    generic map (
        N => N,
        M => M,
        Num_Packets => Num_Packets,
        Packet_Bits => Packet_Bits
    )
    port map (
        clk => ck,
        rst => rst, 
        in_ready => in_ready,
        in_received => in_received, 
        data_out => data_out
    );
    
stimulus: process
begin
    wait for ck_period;
    rst<='0';
    
    wait for ck_period;
    for j in 0 to N-1 loop
        for i in 0 to Num_Packets-1 loop
            while in_ready='0' loop
                wait for ck_period;
            end loop;
            received(i*Packet_Bits to i*Packet_Bits+Packet_Bits-1) <= data_out;
            in_received<='1';
            while in_ready='1' loop
                wait for ck_period;
            end loop;
            in_received<='0';
        end loop;
    end loop;
--wait; Se metto questo wait la simulazione per assurdo non funziona.
end process;
    
CLK_process :process
begin
    ck <= '0';
    wait for ck_period/2;
    ck <= '1';
    wait for ck_period/2;
end process;

end Behavioral;
