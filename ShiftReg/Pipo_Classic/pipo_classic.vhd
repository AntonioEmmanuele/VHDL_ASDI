
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipo_classic is
port(
    CLK: in std_logic;
    RST: in std_logic;
    shift: in std_logic;
    Par_in: in std_logic_vector(0 to 3);
    Par_out:out std_logic_vector(0 to 3)
    );
end pipo_classic;

architecture Behavioral of pipo_classic is
    signal mux_outs:std_logic_vector(0 to 3):="0000";
    signal reg_outs:std_logic_vector(0 to 3):="0000";
    component generic_mux
        generic(
            N:integer:=2;
            M:integer:=1
        );
        port(
            input:      IN std_logic_vector(0 to N-1);
            sel:        IN std_logic_vector(0 to M-1);
            out_in:     OUT std_logic
          );
      end component;
    component ff_et
      generic(
          RISING :std_logic:='1'
      );
      port(
          CK:     IN std_logic;
          RST:    IN std_logic;
          D:      IN std_logic;
          Q:      OUT std_logic
      );
    end component;          
begin
      m:generic_mux generic map(
            N=>2,
            M=>1
        )
       port map(
            input(0)=>Par_in(0),
            input(1)=>'0',
            sel(0)=>(shift),
            out_in=>mux_outs(0)
        );
     muxs: for i in 1 to 3 generate
      
      m:generic_mux generic map(
            N=>2,
            M=>1
        )
       port map(
            input(0)=>Par_in(i),
            input(1)=>reg_outs(i-1),
            sel(0)=>(shift),
            out_in=>mux_outs(i)
        );
    end generate;
    registers:for i in 0 to 3 generate
      reg:ff_et 
        generic map ( RISING => '1'  )                        -- Funzionano tutti sul fronte di salita.
        port map (          CK     => CLK,                     -- Clock e reset vanno sempre presi cosi
                            RST    => RST,
                            D      => mux_outs(i),
                            Q      => reg_outs(i)         -- L'iesimo registro fornisce l'iesima uscita parallela.
                 );
    end generate;
    Par_out<=reg_outs;
end Behavioral;
