

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity siso_4bits is
port (
    CLK: in std_logic;
    RST: in std_logic;
    sig_in: in std_logic;
    sig_out: out std_logic
    );
end siso_4bits;

architecture Structural of siso_4bits is
    signal reg_out: std_logic_vector(0 to 3);
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
    reg_first:ff_et 
        generic map ( RISING => '1'  )                        -- Funzionano tutti sul fronte di salita.
        port map (          CK     => CLK ,                     -- Clock e reset vanno sempre presi cosi
                            RST    => RST,
                            D      => sig_in,
                            Q      => reg_out(0)         -- L'iesimo registro fornisce l'iesima uscita parallela.
                 );

    registers:for i in 1 to 3 generate
      --delayed_clocks(i)
      reg:ff_et 
        generic map ( RISING => '1'  )                        -- Funzionano tutti sul fronte di salita.
        port map (          CK     => CLK ,                     -- Clock e reset vanno sempre presi cosi
                            RST    => RST,
                            D      => reg_out(i-1),
                            Q      =>reg_out(i)         -- L'iesimo registro fornisce l'iesima uscita parallela.
                 );
    end generate;
    sig_out<=reg_out(3);
    
end Structural;
