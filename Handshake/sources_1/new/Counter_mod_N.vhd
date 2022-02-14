library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;

entity counter_mod_n is
    generic(
        N           : integer :=16;                                -- Max value
        Bit_number  : integer := 4;                                -- 2^Bit_number al più = N
        CLK_period  : time := 1000ms                               -- Periodo clock, supposto 1s
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
end counter_mod_n;

architecture Behavioral of counter_mod_n is
signal count : std_logic_vector (0 to Bit_number-1);
    begin
    
    update: process(ck)
        begin
        if (ck'event and ck='0') then
            if (rst = '1') then 
                count <= (others=>'0');
            elsif (load = '1') then
                count <= input_value;
            elsif (enable = '1') then
                if(to_integer(unsigned(count)) >= N-1) then 
                    count <= (others=>'0');                    
                else
                    count <= std_logic_vector(unsigned(count)+1);                   
                end if;-- if del load
            end if; -- if del reset
        end if;-- if del clock
    end process update;
    
    strobe: process (count)
        begin
            if(to_integer(unsigned(count)) = N-1) then
                cnt_done<='1';
            else
                cnt_done<='0';
            end if;
    end process strobe;
    
    
    
    count_value <= count;

end Behavioral;