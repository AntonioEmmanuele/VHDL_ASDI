----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.02.2022 09:51:40
-- Design Name: 
-- Module Name: switch - Behavioral
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
entity switch is
    generic (
        -- Parallelismo della comunicazione
        M:integer:=2;
        -- Numero di bits su cui e' rappresentata la
        -- destinazione
        N_Addr: integer:=2
    );
    port(
        -- Input della prima macchina
        in0_input: in std_logic_vector(0 to M-1);
        -- Input della seconda macchina
        in1_input: in std_logic_vector(0 to M-1);
        -- Input della terza macchina
        in2_input: in std_logic_vector(0 to M-1);
        -- Input della quarta macchina
        in3_input: in std_logic_vector(0 to M-1);
        -- Ingressi di enable, se uno di loro e' 1 
        -- vale 1 tutta l'uscita
        in0_enable: in std_logic;
        in1_enable: in std_logic;
        in2_enable: in std_logic;
        in3_enable: in std_logic;
        -- Indirizzo della destinazione
        dest: in std_logic_vector(0 to N_Addr-1);
        -- Destinazioni
        out0_output: out std_logic_vector(0 to M-1);
        out1_output: out std_logic_vector(0 to M-1);
        out2_output: out std_logic_vector(0 to M-1);
        out3_output: out std_logic_vector(0 to M-1)
    );
end switch;

architecture Structural of switch is
component node is
    generic (
        -- Parallelismo della comunicazione
        M: integer:= 2
    );
    port(
        -- Segnale di dati per il primo ingresso
        in0_data: std_logic_vector( 0 to M-1);
        in0_enable: std_logic;
        in1_data: std_logic_vector( 0 to M-1);
        in1_enable: std_logic;
        output_0: out std_logic_vector(0 to M-1);
        output_1: out std_logic_vector(0 to M-1);
        sel: std_logic 
    );
end component;
--outputSTADIO_NumeroOutput
signal output0_0:std_logic_vector(0 to M-1);
signal output0_1:std_logic_vector(0 to M-1);
signal output0_2:std_logic_vector(0 to M-1);
signal output0_3:std_logic_vector(0 to M-1);
signal output1_0:std_logic_vector(0 to M-1);
signal output1_1:std_logic_vector(0 to M-1);
signal output1_2:std_logic_vector(0 to M-1);
signal output1_3:std_logic_vector(0 to M-1);
signal enable_shuffling:std_logic_vector(0 to 3);
begin

 -- N1_0 ha il primo ingresso valido se le macchine 0 o 1 parlano   
 enable_shuffling(0)<=in0_enable or in1_enable;
 -- Il secondo ingresso di n1_0 e' valido se stanno parlando 2 o 3
 enable_shuffling(1)<=in2_enable or in3_enable;
 -- il primo ingresso di n1_1 e' valido se sta parlando
 -- la prima macchina o la seconda
 enable_shuffling(2)<=in0_enable or in1_enable;
 -- Il secondo ingresso di n1_1 e' valido se stanno parlando 2 o 3
 enable_shuffling(3)<=in2_enable or in3_enable;
 -- First stage
 n0_0: node
 generic map(
    M=>2
 )
 port map(
    in0_data=>in0_input,
    in0_enable=>in0_enable,
    in1_data=>in1_input,
    in1_enable=>in1_enable,
    sel=>dest(0),
    output_0=>output0_0,
    output_1=>output0_1
 );
 n0_1: node
 generic map(
    M=>2
 )
 port map(
    in0_data=>in2_input,
    in0_enable=>in2_enable,
    in1_data=>in3_input,
    in1_enable=>in3_enable,
    sel=>dest(0),
    output_0=>output0_2,
    output_1=>output0_3
 );
 -- Second stage
 n1_0: node
 generic map(
    M=>2
 )
 port map(
    in0_data=>output0_0,
    in0_enable=>enable_shuffling(0),
    in1_data=>output0_2,
    in1_enable=>enable_shuffling(1),
    sel=>dest(1),
    output_0=>output1_0,
    output_1=>output1_1
 );
 n1_1: node
 generic map(
    M=>2
 )
 port map(
    in0_data=>output0_1,
    in0_enable=>enable_shuffling(2),
    in1_data=>output0_3,
    in1_enable=>enable_shuffling(3),
    sel=>dest(1),
    output_0=>output1_2,
    output_1=>output1_3
 );
 out0_output<=output1_0;
 out1_output<=output1_1;
 out2_output<=output1_2;
 out3_output<=output1_3;
end Structural;
