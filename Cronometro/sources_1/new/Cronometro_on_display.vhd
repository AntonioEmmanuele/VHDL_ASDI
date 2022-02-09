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

entity Cronometro_on_display is
        port (
        clk, rst, set           : in std_logic;
        selection               : in std_logic_vector (0 to 1);             -- Sel for rete_input
        input                   : in std_logic_vector (0 to 5);             -- Input for rete_input
        out_anodes              : out std_logic_vector (7 downto 0);
        out_cathodes            : out std_logic_vector (7 downto 0)
        );
end Cronometro_on_display;

architecture Structural of Cronometro_on_display is

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

signal clock_on_Cronometro  : std_logic;
signal enable_cronometro    : std_logic := '1';

signal Y : std_logic_vector (0 to 16);
ALIAS seconds : std_logic_vector (0 to 5) is Y (0 to 5);
ALIAS minutes : std_logic_vector (0 to 5) is Y (6 to 11);
ALIAS hours : std_logic_vector (0 to 4) is Y (12 to 16);

signal value_temp : std_logic_vector (31 downto 0) := (others => '0');
--signal k:std_logic_vector(0 to 5):="001111";
--signal digit_0:std_logic_vector(0 to 3) := std_logic_vector(to_unsigned(to_integer(unsigned(k)) mod 10,4));
--signal digit_1:std_logic_vector(0 to 3) := std_logic_vector(to_unsigned(to_integer(unsigned(k)/10) mod 10,4));
signal enable_digits    : std_logic_vector (7 downto 0) := "00111111";
signal enable_dots      : std_logic_vector (7 downto 0) := "00010100";

signal input_value      : std_logic_vector (0 to 16)    := (others => '0');
ALIAS seconds_input : std_logic_vector (0 to 5) is input_value (0 to 5);
ALIAS minutes_input : std_logic_vector (0 to 5) is input_value (6 to 11);
ALIAS hours_input : std_logic_vector (0 to 4) is input_value (12 to 16);

signal rst_default      : std_logic := '0';

begin

--seconds_input <= std_logic_vector(to_unsigned(40, 6));
--minutes_input <= std_logic_vector(to_unsigned(10, 6));
--hours_input <= std_logic_vector(to_unsigned(1, 5));

value_temp (3 downto 0) <= std_logic_vector(to_unsigned(to_integer(unsigned(seconds)) mod 10,4));
value_temp (7 downto 4) <= std_logic_vector(to_unsigned(to_integer(unsigned(seconds)/10) mod 10,4));
value_temp (11 downto 8) <= std_logic_vector(to_unsigned(to_integer(unsigned(minutes)) mod 10,4));
value_temp (15 downto 12) <= std_logic_vector(to_unsigned(to_integer(unsigned(minutes)/10) mod 10,4));
value_temp (19 downto 16) <= std_logic_vector(to_unsigned(to_integer(unsigned(hours)) mod 10,4));
value_temp (23 downto 20) <= std_logic_vector(to_unsigned(to_integer(unsigned(hours)/10) mod 10,4));

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

display_7_segments : display_seven_segments
	Generic map( 
            CLKIN_freq => 100000000, 
            CLKOUT_freq => 500
            )
    Port map( 
            CLK => clk,
            RST => rst_default,
            VALUE => value_temp,
            ENABLE => enable_digits, -- decide quali cifre abilitare
            DOTS => enable_dots,-- decide quali punti visualizzare
            ANODES => out_anodes,
            CATHODES => out_cathodes
        );

end Structural;
