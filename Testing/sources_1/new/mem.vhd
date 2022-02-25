library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity MEM is
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
end MEM;
-- creo una ROM di 8 elementi da 32 bit ciascuno
architecture behavioral of MEM is 
type mem_type is array (0 to N-1) of std_logic_vector(0 to M-1);
signal MEM: mem_type:=(others=>(others=>'0'));
attribute rom_style : string;
attribute rom_style of MEM : signal is "block";     -- block dice al tool di sintesi di inferire blocchi di RAMB, 
                                                    -- distributed di usare le LUT
begin

process(CLK)
  begin
    if rising_edge(CLK) then
        if (RST = '1') then
            MEM<=(others=>(others=>'0'));
            DATA_OUT<=(others=>'0');
            --DATA_OUT<=MEM();
        elsif (WRITE = '1' and READ='0') then
            MEM(conv_integer(ADDR)) <= DATA_IN;
           -- DATA_OUT<=DATA_IN(conv_integer(ADDR);
        elsif (WRITE='0' and READ='1') then 
             DATA_OUT<=MEM(conv_integer(ADDR));
        end if;
    end if;
end process;
end behavioral;