library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ROM is
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
end ROM;
-- creo una ROM di 8 elementi da 32 bit ciascuno
architecture behavioral of ROM is 
type rom_type is array (0 to N-1) of std_logic_vector(0 to M-1);
constant  ROM : rom_type := (
    "0000",  -- Uscita: 0 0 0/ 0
    "0001",  -- Uscita: 0 0 0/ 0
    "0010",  -- Uscita: 0 0 0/ 0
    "0011",  -- Uscita: 0 0 0/ 0
	"0100",  -- Uscita: 0 0 0/ 0
    "0101",  -- Uscita: 0 0 0/ 0
    "0110",  -- Uscita: 0 0 0/ 0
    "0111",  -- Uscita: 0 1 0/ 2
    "1000",  -- Uscita: 0 0 0/ 0
    "1001",  -- Uscita: 0 0 0/ 0
    "1010",  -- Uscita: 0 0 0/ 0
    "1011",  -- Uscita: 0 0 1/ 1
    "1100",  -- Uscita: 0 0 0/ 0
    "1101",  -- Uscita: 0 0 0 /0
    "1110",  -- Uscita: 1 0 0 /4
    "1111"   -- Uscita: 1 1 1 /
	); 

attribute rom_style : string;
attribute rom_style of ROM : constant is "block";   -- block dice al tool di sintesi di inferire blocchi di RAMB, 
                                                    -- distributed di usare le LUT
begin

process(CLK)
  begin
    if rising_edge(CLK) then
        if (RST = '1') then
            DATA <= ROM(conv_integer("0000"));
        elsif (READ = '1') then
            DATA <= ROM(conv_integer(ADDR));
        end if;
    end if;
end process;
end behavioral;