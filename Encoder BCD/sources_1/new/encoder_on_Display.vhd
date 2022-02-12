----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Antonio Emmanuele, Giuseppe De Rosa
-- 
-- Create Date: 12.02.2022 09:03:17
-- Design Name: 
-- Module Name: encoder_on_Display - Behavioral
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
use IEEE.Numeric_Std.ALL;
entity encoder_on_Display is
port(
    CLK                     : in std_logic;                             -- Input clock per il display                     
    INPUT_SIGNAL            : in std_logic_vector(9 downto 0);          -- Segnale in ingresso
    out_anodes              : out std_logic_vector (7 downto 0);        -- anodi
    out_cathodes            : out std_logic_vector (7 downto 0)         -- catodi
    );
end encoder_on_Display;

architecture Behavioral of encoder_on_Display is

-- Encoder
component encoderBCD is
    Port ( X : in STD_LOGIC_VECTOR (9 downto 0);
           Y : out STD_LOGIC_VECTOR (3 downto 0);
           Z : out STD_LOGIC);
end component;
-- Display 7 segmenti
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
-- Segnali di appoggio encoder
signal flag_z: std_logic;                               --  Segnale di appoggio per il flag di non validita'
signal output_encoded: std_logic_vector(3 downto 0);    --  Output codificato
-- Segnali di appoggio display
signal rst_default:std_logic :='0';                                     --  Valore di default per il reset
signal digit_mask: std_logic_vector (7 downto 0):="00000011";           --  Maschera per le cifre
signal dots_mask: std_logic_vector (7 downto 0):=(others=>'0');         --  Maschera per i punti
signal value_on_display: std_logic_vector(31 downto 0):=(others=>'0');  --  Segnale in Output
begin
-- Prime due cifre rappresentate ciascuna su 4 bits
--value_on_display (3 downto 0) <= std_logic_vector(to_unsigned(to_integer(unsigned(output_encoded)) mod 10,4));
value_on_display (3 downto 0) <= output_encoded;
--value_on_display (7 downto 4) <= std_logic_vector(to_unsigned(to_integer(unsigned(output_encoded)/10) mod 10,4));
-- Assegnazione del flag
flag: process(flag_z)
 begin 
    if(flag_z='1') then
        value_on_display (7 downto 4) <= std_logic_vector(to_unsigned(1,4));
    else
        value_on_display (7 downto 4) <= std_logic_vector(to_unsigned(0,4));
    end if;
 end process;
encoder: encoderBCD PORT MAP(
      X => INPUT_SIGNAL,
      Y => output_encoded,
      Z => flag_z 
);
display_7_segments : display_seven_segments
	Generic map( 
            CLKIN_freq => 100000000, 
            CLKOUT_freq => 500
            )
    Port map( 
            CLK => clk,
            RST => rst_default,
            VALUE => value_on_display,
            ENABLE => digit_mask,    -- decide quali cifre abilitare
            DOTS => dots_mask,        -- decide quali punti visualizzare
            ANODES => out_anodes,
            CATHODES => out_cathodes
        );

end Behavioral;
