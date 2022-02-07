library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
entity Cronometro is
    port (
        clk, rst, set, enable           : in std_logic;
        input_value                     : in std_logic_vector (0 to 16);
        Y                               : out std_logic_vector (0 to 16)                                           
    );
end Cronometro;

architecture Structural of Cronometro is

ALIAS seconds_input : std_logic_vector (0 to 5) is input_value (0 to 5);
ALIAS minutes_input : std_logic_vector (0 to 5) is input_value (6 to 11);
ALIAS hours_input : std_logic_vector (0 to 4) is input_value (12 to 16);

ALIAS seconds : std_logic_vector (0 to 5) is Y (0 to 5);
ALIAS minutes : std_logic_vector (0 to 5) is Y (6 to 11);
ALIAS hours : std_logic_vector (0 to 4) is Y (12 to 16);

component Counter_mod_N 
    generic(
        N           : integer :=16;                                -- Max value
        Bit_number  : integer := 4                                 -- 2^Bit_number al pi? = N
    );
    port(
        enable:         IN std_logic;                              --  Abilita il contatore
        load:           IN std_logic;                              --  Dobbiamo caricare un valore nel contatore.
        input_value:    IN std_logic_vector(0 to Bit_number-1);    --  Valore da caricare, considerato solo se load=1
        ck:             IN std_logic;                              --  Clock
        rst:            IN std_logic;                              --  Reset  
        cnt_done:       OUT std_logic;                             --  Conteggio finito
        count_value:    OUT std_logic_vector(0 to Bit_number-1)    --  Valore di conteggio
    ); 
end component;

signal strobe_seconds, strobe_minutes, strobe_hours : std_logic := 'U';
signal day_finished                                 : std_logic;

begin

strobe_hours <= strobe_minutes and strobe_seconds;

cnt_seconds: Counter_mod_n 
    generic map (   N => 60,
                    Bit_number  => 6)
    port map (      enable      => enable,
                    load        => set,
                    input_value => seconds_input,
                    ck          => clk,
                    rst         => rst,
                    cnt_done    => strobe_seconds,
                    count_value => seconds );
                    
cnt_minutes: Counter_mod_n 
    generic map (   N => 60,
                    Bit_number  => 6)
    port map (      enable      => strobe_seconds,
                    load        => set,
                    input_value => minutes_input,
                    ck          => clk,
                    rst         => rst,
                    cnt_done    => strobe_minutes,
                    count_value => minutes );
                    
cnt_hours: Counter_mod_n 
    generic map (   N => 24,
                    Bit_number  => 5)
    port map (      enable      => strobe_hours,
                    load        => set,
                    input_value => hours_input,
                    ck          => clk,
                    rst         => rst,
                    cnt_done    => day_finished,
                    count_value => hours );
                    


end Structural;
