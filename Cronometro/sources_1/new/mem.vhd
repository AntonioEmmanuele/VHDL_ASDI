
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity Memory is
generic(
    N: integer :=4 ;
    M: integer := 17;
    N_BitNum: integer:=2
);
port(
        input:in std_logic_vector( 0 to M-1);
        enable:in std_logic;
        rst: in std_logic;
        ck: in std_logic;
        mem:in std_logic_vector( 0 to N_BitNum-1 );
        sel: in std_logic_vector(0 to N_BitNum-1);
        output: out std_logic_vector(0 to M-1)
    );
end Memory;

architecture Behavioral of Memory is
    TYPE matrix IS ARRAY ( 0 to N-1) OF std_logic_vector(0 to M-1); -- Non l'ho dichiarato come una matrice ma come un array di std_logic _vector, cosi' posso fare assegnazione di intera riga
    signal mat:matrix:=(others=>(others=>'0'));
    --signal mem_intermediate: std_logic_vector( 0 to N-1):=(others=>'0');
    --signal sel_intermediate:  std_logic_vector(0 to N-1):=(others=>'0');
begin
    
    update:process(ck)
    begin
        if(rising_edge(ck)) then
            if(rst='1') then
                mat<=(others=>(others=>'0'));
            end if;
            if(enable='1') then 
                mat(to_integer(unsigned(mem)) )<=input ;
            end if;
            output<=mat(to_integer(unsigned(sel))) ;
         end if;
    end process;

end Behavioral;
