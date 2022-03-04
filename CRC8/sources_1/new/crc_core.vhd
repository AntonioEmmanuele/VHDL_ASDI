----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.03.2022 12:27:21
-- Design Name: 
-- Module Name: crc_core - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity crc_core is
    port(
        -- Clock e reset
        clk,rst:    in std_logic;
        -- Data in input
        data_in :   in std_logic;
        -- Segnale che segnala l'inizio di un nuovo input.
        new_input    :   in std_logic;
        -- Risultato del crc
        result  :   out std_logic_vector(7 downto 0);
        -- risultato pronto
        result_ready: out std_logic
    );
end crc_core;

architecture Behavioral of crc_core is

-- Shift register 
signal reg:std_logic_vector(7 downto 0):=(others=>'0');
-- Valore del contatore
signal cnt_value: std_logic_vector(2 downto 0):=(others=>'0');
-- Conteggio finito
signal cnt_done:std_logic:='0';
-- Strobe di conteggio
signal cnt_strobe: std_logic:='0';

--  q0, si attende l'inizio di un nuovo input
--  q1, si inserisce il nuovo input
--  q2, si aspettano gli 8 colpi di ck finali per l'inserimento degli 0.   
type stati_automa is (q0,q1,q2);

signal stato_attuale: stati_automa:=q0;
begin
counter:process(clk)
begin
    if(clk'event and clk='0') then 
        if(rst='1') then
            cnt_value<= (others=>'0');
            cnt_done<='0';
        elsif(rst='0') then 
            if (cnt_strobe = '1') then
                if(to_integer(unsigned(cnt_value)) >= 7) then 
                        cnt_value <= (others=>'0');
                        cnt_done<='1';                
                    else
                        cnt_value <= std_logic_vector(unsigned(cnt_value)+1);
                        cnt_done<='0';                 
                  end if; -- fine controllo contatore
            end if;  -- fine controllo strobe
        end if; -- fine if rst
    end if;-- fine if ck
end process;

-- Process di calcolo
calc: process(clk)
begin
    if (rising_edge(clk)) then
        if (rst = '1') then
            stato_attuale <= q0;
            reg <= (others=>'0');
        elsif (rst = '0') then 
            case stato_attuale is
                when q0=>
                    cnt_strobe<='0';
                    if new_input='0' then
                        stato_attuale<=q0;
                    elsif new_input='1' then
                        stato_attuale<=q1;
                        
                        -- Inizia un nuovo calcolo, dunque il vecchio dato sarà
                        -- presto invalidato e result_ready aggiornato
                        result_ready <= '0';
                        
                        -- Inizia lo shift
                        -- Il polinomio e' x^8+x^2+x+1
                        -- Gli ingressi del registro 0,1,2 saranno quindi 
                        -- messi in xor con x(8). 
                        reg(0) <= Data_in xor reg(7);
                        reg(1) <= reg(0) xor reg(7);
                        reg(2) <= reg(1) xor reg(7);
                        reg(7 downto 3) <= reg(6 downto 2);
                    end if;
                when q1=>
                    cnt_strobe<='0';
                    if new_input='1' then
                        stato_attuale<=q1;
                        
                        reg(0) <= Data_in xor reg(7);
                        reg(1) <= reg(0) xor reg(7);
                        reg(2) <= reg(1) xor reg(7);
                        reg(7 downto 3) <= reg(6 downto 2);
                     elsif new_input='0' then
                       stato_attuale<=q2;
                     end if; 
                when q2=>
                    if(cnt_done='0') then
                        cnt_strobe<='1';
                        stato_attuale<=q2;
                        reg(0) <= '0' xor reg(7);
                        reg(1) <= reg(0) xor reg(7);
                        reg(2) <= reg(1) xor reg(7);
                        reg(7 downto 3) <= reg(6 downto 2);
                     elsif( cnt_done='1') then
                        cnt_strobe<='0';
                        stato_attuale<=q0;
                        result_ready<='1';
                        result<=reg;
                     end if;
            end case;
        end if;
    end if;
end process;
end Behavioral;
