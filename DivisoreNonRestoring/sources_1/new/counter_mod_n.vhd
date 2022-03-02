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
        ck:             IN std_logic;                              --  Clock
        rst:            IN std_logic;                              --  Reset  
        enable:         IN std_logic;                              --  Segnale di enable
        cnt_done:       OUT std_logic;                             --  Conteggio finito
        count_value:    OUT std_logic_vector(0 to Bit_number-1)    --  Valore di conteggio
    );   
end counter_mod_n;

architecture Behavioral of counter_mod_n is
    signal count : std_logic_vector (0 to Bit_number-1):=(others=>'0');
    begin
    
    update: process(ck)
       -- variable enable:std_logic:='1';
        begin
        if (ck'event and ck='0') then
            if (rst = '1') then 
                count <= (others=>'0');
                cnt_done<='0';    
               -- enable:='1';
            elsif (rst='0') then
                if (enable = '1') then
                    if(to_integer(unsigned(count)) >= N-1) then 
                        count <= (others=>'0');
                        cnt_done<='1';    
                        --enable:='0';                
                    else
                        count <= std_logic_vector(unsigned(count)+1);
                        cnt_done<='0';                 
                  end if; -- fine controllo contatore
                end if;  -- fine controllo enable
            end if; -- fine controllo contatore
        end if; -- fine controllo ck
    end process update;
 
    count_value <= count;

end Behavioral;