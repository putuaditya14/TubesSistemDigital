LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

entity state_mux is
    port(
        clk: in std_logic;
        state_in0: in std_logic_vector(383 downto 0);
        state_in1: in std_logic_vector(383 downto 0);
        state_in2: in std_logic_vector(383 downto 0);
        state_in3: in std_logic_vector(383 downto 0);
        state_out: out std_logic_vector(383 downto 0);
        mux_sel: in std_logic_vector(1 downto 0)
    );
end state_mux;

architecture statemux_arc of state_mux is
begin
    process(clk)
    begin
    if (clk'event) and (clk='1') then
        case mux_sel is
            when "00" => state_out<=state_in0;
            when "01" => state_out<=state_in1;
            when "10" => state_out<=state_in2;
            when others => state_out<=state_in3;
        end case;
    end if;
    end process;
end statemux_arc;