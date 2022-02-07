library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;
entity counter_mod_n is
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
end counter_mod_n;

architecture Behavioral of counter_mod_n is
    begin
    update: process(ck)
        variable count : std_logic_vector (0 to Bit_number-1);
        begin
        if (ck'event and ck='0') then
            if (rst = '1') then 
                count := (others=>'0');
                cnt_done<='0';
            elsif (enable = '1') then
                if (load='1' ) then -- Se dobbiamo caricare prendi il valore
                    count := input_value;
                    cnt_done<='0';
                elsif(to_integer(unsigned(count)) = N-1) then 
                    count := (others=>'0');
                    cnt_done<='1';
                else
                    count := std_logic_vector(unsigned(count)+1);
                    cnt_done<='0';
                end if;-- if del load
            end if; -- if del reset
            count_value <= count;
        end if;-- if del clock
    end process update;



end Behavioral;