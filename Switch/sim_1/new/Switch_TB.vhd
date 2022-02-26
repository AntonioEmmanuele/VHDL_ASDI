library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity switch_tb is
end;

architecture bench of switch_tb is

  component switch
      generic (
          M:integer:=2;
          N_Addr: integer:=2
      );
      port(
          in0_input: in std_logic_vector(0 to M-1);
          in1_input: in std_logic_vector(0 to M-1);
          in2_input: in std_logic_vector(0 to M-1);
          in3_input: in std_logic_vector(0 to M-1);
          in0_enable: in std_logic;
          in1_enable: in std_logic;
          in2_enable: in std_logic;
          in3_enable: in std_logic;
          dest: in std_logic_vector(0 to N_Addr-1);
          out0_output: out std_logic_vector(0 to M-1);
          out1_output: out std_logic_vector(0 to M-1);
          out2_output: out std_logic_vector(0 to M-1);
          out3_output: out std_logic_vector(0 to M-1)
      );
  end component;
  constant M: integer:=2;
  constant N_Addr:integer:=2;
  --signal in0_input: std_logic_vector(0 to M-1);
  --signal in1_input: std_logic_vector(0 to M-1);
  --signal in2_input: std_logic_vector(0 to M-1);
  -- signal in3_input: std_logic_vector(0 to M-1);
  --signal in0_enable: std_logic;
  --signal in1_enable: std_logic;
  --signal in2_enable: std_logic;
  --signal in3_enable: std_logic;
  signal dest: std_logic_vector(0 to N_Addr-1);
  signal out0_output: std_logic_vector(0 to M-1);
  signal out1_output: std_logic_vector(0 to M-1);
  signal out2_output: std_logic_vector(0 to M-1);
  signal out3_output: std_logic_vector(0 to M-1) ;
  type out_matrix is array (0 to 3) of std_logic_vector(0 to M-1); 
  signal outputs: out_matrix;
  type in_matrix is array (0 to 3) of std_logic_vector(0 to M-1); 
  signal inputs: in_matrix;  
  type enable_matrix is array (0 to 3) of std_logic; 
  signal enables: enable_matrix;  
begin
  outputs(0)<=out0_output;
  outputs(1)<=out1_output;
  outputs(2)<=out2_output;
  outputs(3)<=out3_output;
  --in0_input<=inputs(0);
  --in1_input<=inputs(1);
  --in2_input<=inputs(2);
  --in3_input<=inputs(3);
  uut: switch generic map ( M           =>M ,
                            N_Addr      =>N_Addr )
                 port map ( in0_input   => inputs(0),
                            in1_input   => inputs(1),
                            in2_input   => inputs(2),
                            in3_input   => inputs(3),
                            in0_enable  => enables(0),
                            in1_enable  => enables(1),
                            in2_enable  => enables(2),
                            in3_enable  => enables(3),
                            dest        => dest,
                            out0_output => out0_output,
                            out1_output => out1_output,
                            out2_output => out2_output,
                            out3_output => out3_output );
                            

  stimulus: process
  begin
  for j in 0 to 3 loop
        enables<=(others=>'0');
        wait for 10 ns;
        inputs(j)<="11";
        enables(j)<='1';
        for i in 0 to 3 loop
            dest<=std_logic_vector(to_unsigned(i,M));
            wait  for 10 ns;
            assert outputs(i)=inputs(j) severity failure;
        end loop;    
    end loop;
    -- Test di priorita'    
    for j in 3 downto 0 loop
       -- enables<=(others=>'0');
        wait for 10 ns;
        inputs(j)<=std_logic_vector(to_unsigned(3-j,M));
        enables(j)<='1';
        for i in 0 to 3 loop
            dest<=std_logic_vector(to_unsigned(i,M));
            wait  for 10 ns;
            assert outputs(i)=inputs(j) severity failure;
        end loop;    
    end loop;
    wait;
  end process;
end;
  