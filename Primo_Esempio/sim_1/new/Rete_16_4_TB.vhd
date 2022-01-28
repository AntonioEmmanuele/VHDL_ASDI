-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;
  USE STD.textio.ALL;

  ENTITY testbench IS
  END testbench;

  ARCHITECTURE behavior OF testbench IS 

  -- Component Declaration
          COMPONENT Rete_16_4
          PORT(
                  INPUT 			  		: in  STD_LOGIC_VECTOR (0 to 15);
					  SELECTION_DEST 	  	: in STD_LOGIC_VECTOR (1 downto 0); -- SELECTION DEMUX
					  SELECTION_SRC		: in STD_LOGIC_VECTOR (0 to 3);		-- SELECTION MUX
					  output 	  	  		: out  STD_LOGIC_VECTOR (0 to 3)
					  );
          END COMPONENT;

			signal inputs: std_logic_vector(0 to 15) := (others => '0');
			signal control_dest : std_logic_vector(0 to 1) := (others => '0');
			signal control_src : std_logic_vector(0 to 3) := (others => '0');
			
			--Outputs
			signal y : STD_LOGIC_VECTOR (0 to 3);      
			
          function to_string(value : std_logic_vector)  return string is  
          variable l : line;
            begin
            write(l, to_bitVector(value), right, 0);
            return l.all;
            end to_string;  

  BEGIN

  -- Component Instantiation
          uut: Rete_16_4 PORT MAP(
                  INPUT => inputs,
                  SELECTION_DEST => control_dest,
						SELECTION_SRC => control_src,
						output => y 
          );


  --  Test Bench Statements
     tb : PROCESS
     BEGIN

        wait for 100 ns; -- wait until global set/reset completes
		  inputs <= "1001001011000110";
		  
		  for i in 0 to 15 loop
				control_src <= std_logic_vector(to_unsigned(i, control_src'length));
				
				for j in 0 to 3 loop
					control_dest <= std_logic_vector (to_unsigned(j, control_dest'length)); 
					wait for 10 ns;
					assert y(j) = inputs (i)
					report "errore"
                    severity failure;
					
				end loop;
				
			end loop;
					
        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;
