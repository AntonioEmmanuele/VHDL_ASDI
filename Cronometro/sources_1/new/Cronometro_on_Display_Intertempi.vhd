----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.02.2022 18:15:17
-- Design Name: 
-- Module Name: Cronometro_on_display - Structural
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
use IEEE.NUMERIC_STD.ALL;

entity Cronometro_on_display_intertempi is
        generic(
            Num_Intertempi:integer:=4;                                      -- Numero di intertempi che possiamo memorizzare
            Bit_Intertempi:integer:=2                                       -- Numero di bit su cui sono rappresentati gli intertempi.
        );
        port (
        clk, rst, set           : in std_logic;                             -- Set serve per abilitare il caricamento del dato
        selection               : in std_logic_vector (0 to 1);             -- Sel for rete_input , 00 per i secondi, 01 per i minuti , 10 per le ore. 
        input                   : in std_logic_vector (0 to 5);             -- Input for rete_input
        out_anodes              : out std_logic_vector (7 downto 0);        -- anodi
        out_cathodes            : out std_logic_vector (7 downto 0);        -- catodi
        stop                    : in std_logic;                             -- Segnale di stop se messo ad 1 allora andiamo a prendere l'intertempo
        visualize               : in std_logic                              -- Se 1 allora viene mandato in uscita un intertempo
        );
end Cronometro_on_display_intertempi;

architecture Structural of Cronometro_on_display_intertempi is

component Rete_input
    port(
      signal input:     in std_logic_vector(0 to 5);    --  switch in input
      signal sel:       in std_logic_vector(0 to 1);    --  segnale di decisione
      signal output:    out std_logic_vector(0 to 16)   --  Valore del registro in uscita
      ); 
end component;

component Divisore_freq
    generic (
            CLK_in : integer := 100000000; -- 100 MHz
            CLK_out : integer := 500
            );
    Port (
            clock_in : in std_logic;
            reset : in std_logic;
            clock_out : out std_logic -- Sono visti come degli impulsi
        );
end component;

component Debouncer is
    generic (
        CLK_period : integer := 10;
        btn_noise_time : integer := 6500000
        );
    port (
        RST : in std_logic;
        CLK : in std_logic;
        BTN : in std_logic;
        CLEARED_BTN : out std_logic
        );
end component;

component Memory
    generic(
      N: integer :=4 ;
      N_BitNum: integer:=2;
      M: integer := 17;
      CK_Period:time :=10ns
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
end component;
component counter_mod_n
    generic(
    N:integer:=4;
    Bit_number : integer := 2
    );
    port(
    enable:         IN std_logic;
    load:           IN std_logic;
    input_value:    IN std_logic_vector(0 to Bit_number-1);
    ck:             IN std_logic;
    rst:            IN std_logic;
    cnt_done:       OUT std_logic;
    count_value:    OUT std_logic_vector(0 to Bit_number-1)
    );   
end component;
component Cronometro is
    generic (
                CLK_general_period  : time := 1000ms                               -- Periodo clock, supposto 1s 
            );
    port (
        clk, rst, set, enable           : in std_logic;
        input_value                     : in std_logic_vector (0 to 16);
        Y                               : out std_logic_vector (0 to 16)                                           
    );
end component;

component display_seven_segments is
	Generic( 
            CLKIN_freq : integer := 100000000; 
            CLKOUT_freq : integer := 500
            );
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           VALUE : in  STD_LOGIC_VECTOR (31 downto 0);
           ENABLE : in  STD_LOGIC_VECTOR (7 downto 0); -- decide quali cifre abilitare
           DOTS : in  STD_LOGIC_VECTOR (7 downto 0); -- decide quali punti visualizzare
           ANODES : out  STD_LOGIC_VECTOR (7 downto 0);
           CATHODES : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

 -- Segnali cronometro
signal clock_on_Cronometro  : std_logic;            -- Clock in input al cronometro
signal enable_cronometro    : std_logic := '1';     -- Abilitazione cronometro
signal Y : std_logic_vector (0 to 16);              -- Uscita cronometro

-- Segnali display 

--signal k:std_logic_vector(0 to 5):="001111";
--signal digit_0:std_logic_vector(0 to 3) := std_logic_vector(to_unsigned(to_integer(unsigned(k)) mod 10,4));
--signal digit_1:std_logic_vector(0 to 3) := std_logic_vector(to_unsigned(to_integer(unsigned(k)/10) mod 10,4));
signal enable_digits    : std_logic_vector (7 downto 0) := "00111111";          
signal enable_dots      : std_logic_vector (7 downto 0) := "00010100";
signal value_temp : std_logic_vector (31 downto 0) := (others => '0');          -- Ingresso del display quando si prende l'uscita dal cronometro

-- Segnali rete intermedia
signal input_value      : std_logic_vector (0 to 16)    := (others => '0');     -- Uscita della rete di selezione
signal rst_default      : std_logic := '0';                                     -- Valore di default per il reset

-- Segnali per memorizzazione e visualizzazione

signal memorize_strobe    : std_logic := '0';                                   -- strobe per il contatore ed il buffer di memorizzazione.
signal counter_load : std_logic := '0';                                         -- Segnale di load di appoggio per i contatori, inutilizzato
signal count_done_h :std_logic;                                                 -- Appoggi per i count done, inutilizzati
signal count_done_h2l: std_logic;
signal input_h: std_logic_vector(0 to Bit_Intertempi-1):=(others=>'0');          -- Appoggio per i counter input, inutilizzati
signal memorize_address: std_logic_vector(0 to Bit_Intertempi-1):=(others=>'0'); -- indirizzi in cui andare a memorizzare i valori  

signal visualize_strobe    : std_logic := '0';                                    -- strobe per il contatore ed il buffer di visualizzazione.
signal visualize_address: std_logic_vector(0 to Bit_Intertempi-1):=(others=>'0'); -- indirizzo da visualizzare
signal out_mem : std_logic_vector(0 to 16):=(others=>'0');                        -- output in uscita dalla memoria
signal value_temp_mem:std_logic_vector (31 downto 0) := (others => '0');           -- Input per il display in uscita dalla memoria

-- Alias
ALIAS seconds_input : std_logic_vector (0 to 5) is input_value (0 to 5);
ALIAS minutes_input : std_logic_vector (0 to 5) is input_value (6 to 11);
ALIAS hours_input : std_logic_vector (0 to 4) is input_value (12 to 16);

ALIAS seconds_mem : std_logic_vector (0 to 5) is out_mem (0 to 5);
ALIAS minutes_mem : std_logic_vector (0 to 5) is out_mem (6 to 11);
ALIAS hours_mem : std_logic_vector (0 to 4) is out_mem (12 to 16);

ALIAS seconds : std_logic_vector (0 to 5) is Y (0 to 5);
ALIAS minutes : std_logic_vector (0 to 5) is Y (6 to 11);
ALIAS hours : std_logic_vector (0 to 4) is Y (12 to 16);


begin

value_temp (3 downto 0) <= std_logic_vector(to_unsigned(to_integer(unsigned(seconds)) mod 10,4));
value_temp (7 downto 4) <= std_logic_vector(to_unsigned(to_integer(unsigned(seconds)/10) mod 10,4));
value_temp (11 downto 8) <= std_logic_vector(to_unsigned(to_integer(unsigned(minutes)) mod 10,4));
value_temp (15 downto 12) <= std_logic_vector(to_unsigned(to_integer(unsigned(minutes)/10) mod 10,4));
value_temp (19 downto 16) <= std_logic_vector(to_unsigned(to_integer(unsigned(hours)) mod 10,4));
value_temp (23 downto 20) <= std_logic_vector(to_unsigned(to_integer(unsigned(hours)/10) mod 10,4));

value_temp_mem (3 downto 0) <= std_logic_vector(to_unsigned(to_integer(unsigned(seconds_mem)) mod 10,4));
value_temp_mem (7 downto 4) <= std_logic_vector(to_unsigned(to_integer(unsigned(seconds_mem)/10) mod 10,4));
value_temp_mem (11 downto 8) <= std_logic_vector(to_unsigned(to_integer(unsigned(minutes_mem)) mod 10,4));
value_temp_mem (15 downto 12) <= std_logic_vector(to_unsigned(to_integer(unsigned(minutes_mem)/10) mod 10,4));
value_temp_mem (19 downto 16) <= std_logic_vector(to_unsigned(to_integer(unsigned(hours_mem)) mod 10,4));
value_temp_mem (23 downto 20) <= std_logic_vector(to_unsigned(to_integer(unsigned(hours_mem)/10) mod 10,4));

rete: Rete_input
    port map(
      input => input,    
      sel => selection,    
      output => input_value
      ); 

divisore: Divisore_freq
    generic map (
        CLK_in => 100000000,
        CLK_out => 1
        )
    port map (
        clock_in => clk,
        reset => rst_default,
        clock_out => clock_on_Cronometro
        );
        
cronomtr: Cronometro
    generic map (
              CLK_general_period => 1000ms 
            )
    port map (
        clk => clock_on_Cronometro,
        rst => rst,
        set => set, 
        enable => enable_cronometro, 
        input_value => input_value,
        Y => Y
        );

-- Rete di memorizzazione
debouncer_mem_btn: Debouncer    generic map(
                                    CLK_period => 10,   -- questo e' 1/100 Mhz, ossia 10 ns
                                    btn_noise_time => 500000000 -- 500 ms
                                )
                                port map (
                                    RST => rst_default,
                                    CLK =>clk,
                                    BTN =>stop,
                                    CLEARED_BTN => memorize_strobe
                                );
counter_mem: counter_mod_n      generic map ( 
                                            N           => Num_Intertempi,
                                            Bit_number  => Bit_Intertempi)
                                port map ( enable      => memorize_strobe,
                                           load        => counter_load,
                                           input_value => input_h,
                                           ck          => clk,
                                           rst         => rst_default,
                                           cnt_done    => count_done_h,
                                           count_value => memorize_address );
    
debouncer_visual_btn: Debouncer    generic map(
                                    CLK_period => 10,   -- questo e' 1/100 Mhz, ossia 10 ns
                                    btn_noise_time => 500000000--6500000
                                    )
                                    port map (
                                        RST => rst_default,
                                        CLK =>clk,
                                        BTN =>visualize,
                                        CLEARED_BTN => visualize_strobe
                                    );
counter_visualizw: counter_mod_n generic map (
                                         N           => Num_Intertempi,
                                         Bit_number  => Bit_Intertempi)
                                port map ( enable      => visualize_strobe,
                                           load        => counter_load,
                                           input_value => input_h,
                                           ck          => clk,
                                           rst         => rst_default,
                                           cnt_done    => count_done_h,
                                           count_value => visualize_address );
                                       

buff:   Memory generic map (    N         => Num_Intertempi,
                                M         => 17,
                                N_BitNum  =>Bit_Intertempi )
              port map ( input     => Y,                -- L'input sono i 17 bits in uscita dal cronometro
                         enable    => memorize_strobe,  -- strobe di memorizzazione
                         rst       => rst_default,             
                         ck        => clk,
                         mem       => memorize_address,     -- Indirizzo di memorizzazione, dato in uscita dal contatore che si prende lo strobe dal bit di stop
                         sel       => visualize_address,    -- Indirizzo di visualizzazione, dato in uscita dal contatore che si prende in ingresso lo strobe dal bit di visualize
                         output    => out_mem );
display_7_segments : display_seven_segments
	Generic map( 
            CLKIN_freq => 100000000, 
            CLKOUT_freq => 500
            )
    Port map( 
            CLK => clk,
            RST => rst_default,
            VALUE => value_temp_mem,
            ENABLE => enable_digits, -- decide quali cifre abilitare
            DOTS => enable_dots,-- decide quali punti visualizzare
            ANODES => out_anodes,
            CATHODES => out_cathodes
        );

end Structural;
