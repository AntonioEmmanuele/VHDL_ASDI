library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity Memory is
-- 4 stringhe da 8 bit
generic (
    N: integer := 4;
    M: integer := 8;
    N_BitNum : integer := 2
);
port(
    CLK : in std_logic; -- clock della board
    RST : in std_logic;
    ADDR : in std_logic_vector(N_BitNum-1 downto 0); --2 bit di indirizzo per accedere agli elementi della ROM,
    DATA : out std_logic_vector(M-1 downto 0) -- dato su 8 bit letto dalla ROM
    );
end Memory;

-- creo una ROM di 4 elementi da 8 bit ciascuno
architecture behavioral of Memory is 
    type rom_type is array (N-1 downto 0) of std_logic_vector(M-1 downto 0);
    signal ROM : rom_type := (
    X"50",  -- 80 in decimale
    X"24",  -- 36
    X"47",  -- 71
    X"7E"); -- 126
    
    signal default_value : std_logic_vector (N-1 downto 0) := (others => '0');
    attribute rom_style : string;
    attribute rom_style of ROM : signal is "block";-- block dice al tool di sintesi di inferire blocchi di RAMB, 
                                                   -- distributed di usare le LUT
    begin
    
    process(CLK)
      begin
        if falling_edge(CLK) then
            if (RST = '1') then
                DATA <= ROM(conv_integer(default_value)); 
            else
                DATA <= ROM(conv_integer(ADDR));
            end if;
        end if;
    end process;
end behavioral;