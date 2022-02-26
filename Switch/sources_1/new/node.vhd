----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.02.2022 09:20:49
-- Design Name: 
-- Module Name: node - Behavioral
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
entity node is
    generic (
        -- Parallelismo della comunicazione
        M: integer:= 2
    );
    port(
        -- Segnale di dati per il primo ingresso
        in0_data: std_logic_vector( 0 to M-1);
        -- Quando il primo ingresso invia mette questo bit alto
        in0_enable: std_logic;
        -- Segnale di dati per il secondo ingresso
        in1_data: std_logic_vector( 0 to M-1);
        -- Quando il secondo ingresso invia mette questo bit alto
        in1_enable: std_logic;
        -- Ho due possibili destinazioni
        output_0: out std_logic_vector(0 to M-1);
        output_1: out std_logic_vector(0 to M-1);
        sel: std_logic 
    );
end node;

architecture mxd of node is
-- Il nodo e' rappresentabile mediante la composizione di due macchine combinatorie
-- Una prima macchina combinatoria seleziona in1_data ed in2_data con uno schema a prio
-- fissa, selezionando il numero con indirizzo piu' basso, ossia sempre quello piu' 
-- in alto in_1
signal front_data: std_logic_vector(0 to M-1);
begin
-- Rete che gestisce l'input
assign1:process(in0_data,in1_data,in0_enable,in1_enable)
begin
    for i in 0 to M-1 loop
        -- Ossia, se parla in0 allora vince sempre lui, in1
        -- vince se in0 non parla e se in1 sta alto, ossia se sta parlando
        front_data(i)<=( in0_data(i) and in0_enable ) or
                 (in1_data(i) and( not(in0_enable) and in1_enable));
    end loop;
end process;
-- Rete che gestisce l'output
assign2: process( front_data,sel)
begin
    -- Sel compie di fatto una operazione di demultiplexing
    -- output_0= front_data and not(sel)
    -- output_1= front_data and sel
    -- si traduce di fatto in questo if/else
    if(sel='0') then
        output_0<=front_data;
        output_1<=(others=>'0');
    elsif(sel='1') then
        output_1<=front_data;
        output_0<=(others=>'0');
    end if;
end process;
end mxd;
