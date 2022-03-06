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

-- Valore del contatore
signal cnt_value: std_logic_vector(2 downto 0):=(others=>'0');
-- Conteggio finito
signal cnt_done:std_logic:='0';
-- Strobe di conteggio
signal cnt_strobe: std_logic:='0';
--  Reset del contatore
signal cnt_rst: std_logic:='0';
-- Abilita lo shift
signal shift_enable:std_logic:='0';
-- Dato in input
signal shift_reg_data_in: std_logic:='0';
-- Rst del registro
signal shift_reg_rst: std_logic:='0';
-- Shift register 
signal reg:std_logic_vector(7 downto 0):=(others=>'0');

--  q0, si attende l'inizio di un nuovo input
--  q1, si inserisce il nuovo input
--  q2, si aspettano gli 8 colpi di ck finali per l'inserimento degli 0.   
type stati_automa is (q0,q1,q2);

signal stato_attuale: stati_automa:=q0;
signal stato_prossimo: stati_automa:=q0;

begin
shift_reg_rst<=rst;
cnt_rst<=rst;
-- automa che implementa un contatore
counter:process(clk)
begin
    if(clk'event and clk='0') then 
        if(cnt_rst='1') then
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
 --shift_reg_data_in<=data_in;
-- automa che implementa uno shift register con le xor
shift_reg: process(clk)
begin
    if (clk'event and clk='1') then
        if(shift_reg_rst='1') then
            reg<=(others=>'0');
         elsif (shift_reg_rst='0') then
            -- Il polinomio e' x^8+x^2+x+1
            -- Gli ingressi del registro 0,1,2 saranno quindi 
            -- messi in xor con x(8). 
            if(shift_enable='1') then
                reg(0) <= shift_reg_data_in xor reg(7);
                reg(1) <= reg(0) xor reg(7);
                reg(2) <= reg(1) xor reg(7);
                reg(7 downto 3) <= reg(6 downto 2);
             end if;
         end if;
    end if;
end process;


    
-- Process di calcolo
calc: process(stato_attuale,new_input,cnt_done,data_in)
begin
    case stato_attuale is
        when q0=>
            cnt_strobe<='0';
            --cnt_rst<='0';
            --shift_reg_rst<='0';
            if new_input='0' then
                stato_prossimo<=q0;
            elsif new_input='1' then
                stato_prossimo<=q1;
                -- Inizia un nuovo calcolo, dunque il vecchio dato sarà
                -- presto invalidato e result_ready aggiornato
                result_ready <= '0';
                -- Abilita lo shift
                shift_enable<='1';
                -- Cio' che si deve shiftare e' il valore delle xor.
                shift_reg_data_in<=data_in;       
          end if;
          when q1=>
            cnt_strobe<='0';
           -- cnt_rst<='0';
           -- shift_reg_rst<='0';
            result_ready <= '0';
            shift_enable<='1';
            shift_reg_data_in<=data_in;  
            if  new_input='0' then
                stato_prossimo<=q2;
                shift_enable<='1';
                -- devo iniziare a cambiare il segnale qui
                shift_reg_data_in<='0';
            end if;
           when q2=>
            if(cnt_done='0') then
                cnt_strobe<='1';
                stato_prossimo<=q2;
                shift_enable<='1';
                -- Shifto di 0
                shift_reg_data_in<='0';               
            elsif( cnt_done='1') then
                --cnt_strobe<='0';
                shift_enable<='0';
                stato_prossimo<=q0;
                result_ready<='1';
                result<=reg;
                --shift_reg_rst<='0';
            end if;
    end case;
end process;
--Process di aggiornamento automa
update: process (clk)
begin
    if(clk'event and clk='1') then
        if rst='1' then
            stato_attuale<=q0;
            --cnt_rst<='1';
            --shift_reg_rst<='1';
        elsif rst='0' then
            stato_attuale<=stato_prossimo;
        end if;
    end if;
end process;
end Behavioral;
