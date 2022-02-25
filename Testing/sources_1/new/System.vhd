----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.02.2022 17:20:25
-- Design Name: 
-- Module Name: System - Structural
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


entity System is
port(
    ck,rst: in  std_logic;
    read: in std_logic;
    data_out:out std_logic_vector( 0 to 2)
    );
end System;

architecture Structural of System is
-- Per realizzare il tutto serve una rom, una memoria ed un contatore.
component ROM is
    generic (
        N: integer := 16;
        N_Bits: integer:=4;
        M: integer:=4
        );
    port(
        CLK : in std_logic; 
        RST : in std_logic;
        READ : in std_logic; 
        ADDR : in std_logic_vector(0 to N_Bits-1);                                         
        DATA : out std_logic_vector(0 to M-1) 
        );
end component;
component MEM is
    generic (
        N: integer := 16;
        N_Bits: integer:=4;
        M: integer:=3
        );
    port(
        CLK : in std_logic; 
        RST : in std_logic;
        WRITE : in std_logic; 
        READ:   in std_logic;
        ADDR : in std_logic_vector(0 to N_Bits-1);  
        DATA_IN : in std_logic_vector(0 to M-1);                                     
        DATA_OUT : out std_logic_vector(0 to M-1) 
        );
end component;
component counter_mod_n is
    generic(
        N           : integer :=16;                                -- Max value
        Bit_number  : integer := 4;                                -- 2^Bit_number al più = N
        CLK_period  : time := 1000ms                               -- Periodo clock, supposto 1s
    );
    port(
        --  Clock
        ck:             IN std_logic;                            
        --  Reset    
        rst:            IN std_logic;                
        -- Segnale di enable            
        enable:         IN std_logic;                              
        --  Conteggio finito
        cnt_done:       OUT std_logic;                             
        --  Valore di conteggio
        count_value:    OUT std_logic_vector(0 to Bit_number-1)    
    );   

end component;
-- Infine la macchina da testare
component M_Machine is
    port(
        x: in std_logic_vector(0 to 3);
        y: out std_logic_vector(0 to 2)
    );
end component;
signal cnt_done_h : std_logic;
 -- indirizzo rom ed memoria
signal addr: std_logic_vector( 0 to 3);    
 -- input macchina combinatoria
signal data_in: std_logic_vector( 0 to 3); 
-- uscita della macchina
signal data_mem:std_logic_vector(0 to 2);   
 -- strobe della rom
signal rom_strobe: std_logic;              
 -- strobe della rom in scrittura 
signal mem_strobe_write:std_logic;               
-- Strobe della memoria in lettura
signal mem_strobe_read: std_logic;
-- strobe del contatore
signal cnt_strobe: std_logic;               
          
type state is (q0,q1,q2,waitFor0);
signal stato_corrente :state:=q0;

begin
  automa: process(ck)
  begin
    if(rising_edge(ck)) then
        if(rst='1')then
            stato_corrente<=q0;
            rom_strobe<='0';
            mem_strobe_write<='0';
            mem_strobe_read<='0';
            cnt_strobe<='0';
        elsif (rst='0') then
            case stato_corrente is
                when q0=>
                    if(read='1') then 
                        stato_corrente<=q1;
                        rom_strobe<='1';
                        mem_strobe_write<='0';
                        mem_strobe_read<='0';
                        cnt_strobe<='0';
                    elsif (read='0') then
                        stato_corrente<=q0;
                        rom_strobe<='0';
                        mem_strobe_write<='0';
                        mem_strobe_read<='0';                              
                        cnt_strobe<='0';
                    end if;
                when q1=>
                        stato_corrente<=q2;
                        rom_strobe<='0';
                        mem_strobe_write<='1';
                        mem_strobe_read<='0';
                        cnt_strobe<='0';
                when q2=>
                        stato_corrente<=waitFor0;
                        rom_strobe<='0';
                        mem_strobe_write<='0';
                        mem_strobe_read<='1';
                        cnt_strobe<='0';
                when waitFor0=>
                    if(read='0') then 
                        stato_corrente<=q0;
                        rom_strobe<='0';
                        mem_strobe_write<='0';
                        mem_strobe_read<='0';
                        cnt_strobe<='1';
                    elsif (read='1') then
                        stato_corrente<=waitFor0;
                        rom_strobe<='0';
                        mem_strobe_write<='0';
                        mem_strobe_read<='0';
                        cnt_strobe<='0';
                    end if;
            end case;
       end if; -- fine if rst
    end if;-- fine if ck
  end process;
  counter:counter_mod_n
    generic map (
            N   =>  16,                               
            Bit_number => 4 ,                             
            CLK_period  => 1000ms                             
    )
    port map (
        ck=>ck,
        rst=>rst,
        enable=>cnt_strobe,
        cnt_done=>cnt_done_h,
        count_value=>addr  
    );
	mem_rom: ROM 
    generic map(
        N=> 16,
        N_Bits=>4,
        M=>4
     )
    port map(
        CLK =>ck ,
        RST =>rst,
        READ =>rom_strobe, 
        ADDR => addr,                                        
        DATA =>data_in
    );
    to_test: M_Machine 
    port map(
        x=>data_in,
        y=>data_mem
    );

    outputs_mem: MEM 
    generic map(
        N=> 16,
        N_Bits=>4,
        M=>3
     )
    port map(
        CLK =>ck ,
        RST =>rst,
        WRITE =>mem_strobe_write, 
        READ=> mem_strobe_read,
        ADDR => addr,                                        
        DATA_IN =>data_mem,
        DATA_OUT=> data_out
    );


end Structural;
