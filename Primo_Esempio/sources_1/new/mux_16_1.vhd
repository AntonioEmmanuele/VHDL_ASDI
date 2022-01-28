library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_16_1 is
    Port ( INPUT 			  : in  STD_LOGIC_VECTOR (0 to 15);
			  SELECTION 	  : in STD_LOGIC_VECTOR(0 to 3);
			  output 	  	  : out  STD_LOGIC
			  );	
end mux_16_1;

architecture Structural of mux_16_1 is
	signal mid_output : STD_LOGIC_VECTOR (0 to 3) := (others => 'U');
	
	component mux_4_1
		    Port ( 
			  IN0 : in  STD_LOGIC;
              IN1 : in  STD_LOGIC;
              IN2 : in  STD_LOGIC;
              IN3 : in  STD_LOGIC;
			  S : in STD_LOGIC_VECTOR(0 to 1); -- S(0) = S0, S(1) = S1
			  Y : out  STD_LOGIC
			  );	
	end component;
	
begin
    --  Per un approccio strutturale abbiamo bisogno che ognuno dei primi 4 mux si prenda 4 input.
    --  Il primo mux prende INPUT(0:3), il secondo INPUT(4:7), il terzo INPUT(8:11), il quarto INPUT(12:15).
    --  Usando un for istanziare tutti i mux, da 0 a 3 allora gli input che l'iesimo mux prende sono:
    --      (i*4,i*4+1,i*4+2,i*4+3)
    --  Ogni mux mettera' la sua uscita nell'iseimo segnale intermedio
    --  Sono inoltre gli ultimi due bit del segnale di selezione a decidere quale input i mux prendono.
    --  Un mux 16:1 e' vedibile come un insieme di 16 porte tristate i cui 16 segnali di abilitazione sono dati dall'uscita
    --  di un decoder che prende in ingresso i segnali di selezione.
    --  Se ad esempio avessimo 0010 allora dovremmo prendere in uscita il terzo bit (INPUT(2))
    --  Se lo si vede come un insieme di porte tristate l'uscita del decoder e' proprio :  0010 0000 0000 0000 ossia abiliterebbe solo il bit 3 (INPUT(2))
    --  Questo prova che i due bit S2 ed S3 devono dare la selezione dell'input da ognuno dei 4 mux mentre S0 ed S1 devono scegliere quale mux andare a prendere.
    --  Un ulteriore esempio e' dato da 1101 ossia il 14-esimo bit INPUT(13)
    --  Questo sarebbe in uscita da un decoder: 1101 => 0000 0000 0000 0100 ossia abiliterebbe solo INPUT(13).
    --  Cio' coincide con lo scegliere l'ultimo mux (11) e prenderne il secondo valore (10). 
    mux0to3 : for i in 0 to 3 generate
        mux : mux_4_1
        port map (
            IN0 => INPUT(4*i),
			IN1 => INPUT(4*i + 1),
			IN2 => INPUT(4*i + 2),
			IN3 => INPUT(4*i + 3),
			S(0)=> SELECTION(2),
			S(1)=> SELECTION(3),
			Y => mid_output(i)
		);
	end generate;
	
	mux4 : mux_4_1
			Port map (
			IN0 => mid_output(0),
			IN1 => mid_output(1),
			IN2 => mid_output(2),
			IN3 => mid_output(3),
			S(0)=> SELECTION(0),
			S(1)=> SELECTION(1),
			Y => output
		);

end Structural;